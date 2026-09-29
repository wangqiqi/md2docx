"""
安全校验模块单元测试
"""

import tempfile
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from mddocx.converter.security import fetch_remote_bytes, is_private_ip, is_safe_remote_url, resolve_safe_local_path

PUBLIC_DNS = [(2, 1, 6, "", ("93.184.216.34", 0))]


def _response(status=200, headers=None, chunks=(b"payload",)):
    response = MagicMock()
    response.status_code = status
    response.headers = headers if headers is not None else {}
    response.iter_content.return_value = list(chunks)
    return response


class TestPrivateIP:
    def test_loopback(self):
        assert is_private_ip("127.0.0.1") is True

    def test_public_ip(self):
        assert is_private_ip("8.8.8.8") is False

    def test_private_range(self):
        assert is_private_ip("10.0.0.1") is True
        assert is_private_ip("192.168.1.1") is True


class TestSafeRemoteURL:
    def test_blocks_localhost(self):
        assert is_safe_remote_url("http://localhost/secret") is False

    def test_blocks_private_ip_literal(self):
        assert is_safe_remote_url("http://127.0.0.1/") is False
        assert is_safe_remote_url("http://169.254.169.254/") is False

    def test_allows_public_https(self):
        with patch("socket.getaddrinfo", return_value=[(2, 1, 6, "", ("93.184.216.34", 0))]):
            assert is_safe_remote_url("https://example.com/image.png") is True

    def test_rejects_non_http_scheme(self):
        assert is_safe_remote_url("file:///etc/passwd") is False


class TestResolveSafeLocalPath:
    def test_allows_file_under_base_dir(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base = Path(tmpdir)
            image = base / "photo.png"
            image.write_bytes(b"png")
            result = resolve_safe_local_path("photo.png", base_dir=base)
            assert result == image.resolve()

    def test_blocks_path_traversal(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base = Path(tmpdir)
            assert resolve_safe_local_path("../../etc/passwd", base_dir=base) is None

    def test_blocks_absolute_path(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base = Path(tmpdir)
            assert resolve_safe_local_path("/etc/passwd", base_dir=base) is None

    def test_returns_none_without_base_dir(self):
        assert resolve_safe_local_path("image.png") is None


class TestMarkdownSize:
    def test_validate_markdown_size_within_limit(self):
        from mddocx.converter.security import validate_markdown_size

        assert validate_markdown_size("# hello") > 0

    def test_validate_markdown_size_exceeds_limit(self):
        from mddocx.converter.security import MAX_MARKDOWN_BYTES, MarkdownTooLargeError, validate_markdown_size

        with pytest.raises(MarkdownTooLargeError):
            validate_markdown_size("x" * (MAX_MARKDOWN_BYTES + 1))

    def test_stream_file_byte_size(self, tmp_path):
        from mddocx.converter.security import stream_file_byte_size

        md = tmp_path / "a.md"
        md.write_bytes(b"# test\n")
        assert stream_file_byte_size(md) == len(b"# test\n")


class TestFetchRemoteBytes:
    """受限下载：逐跳校验，重定向不能绕过 URL 白名单。"""

    @patch("mddocx.converter.security.requests.get")
    def test_blocks_redirect_to_metadata_ip(self, mock_get):
        mock_get.return_value = _response(302, {"Location": "http://169.254.169.254/latest/meta-data/"})

        result = fetch_remote_bytes("https://example.com/a.png", validator=is_safe_remote_url)

        assert result is None
        # 首跳之后被拦下，不会发出第二次请求
        assert mock_get.call_count == 1

    @patch("mddocx.converter.security.requests.get")
    def test_follows_redirect_when_each_hop_is_safe(self, mock_get):
        mock_get.side_effect = [
            _response(302, {"Location": "/real.png"}),
            _response(200, {"Content-Type": "image/png"}, [b"\x89PNGdata"]),
        ]

        with patch("socket.getaddrinfo", return_value=PUBLIC_DNS):
            result = fetch_remote_bytes("https://example.com/a.png", validator=is_safe_remote_url)

        assert result == b"\x89PNGdata"
        assert mock_get.call_count == 2
        # 自动重定向必须关闭，否则逐跳校验形同虚设
        for call in mock_get.call_args_list:
            assert call.kwargs["allow_redirects"] is False

    @patch("mddocx.converter.security.requests.get")
    def test_returns_none_when_validator_rejects(self, mock_get):
        result = fetch_remote_bytes("https://evil.com/a.png", validator=lambda url: False)

        assert result is None
        mock_get.assert_not_called()

    @patch("mddocx.converter.security.requests.get")
    def test_returns_none_on_non_200(self, mock_get):
        mock_get.return_value = _response(500)

        assert fetch_remote_bytes("https://example.com/a.png", validator=lambda url: True) is None

    @patch("mddocx.converter.security.requests.get")
    def test_returns_none_when_body_oversized(self, mock_get):
        chunk = b"x" * 8192
        mock_get.return_value = _response(200, {}, [chunk] * 5)

        result = fetch_remote_bytes(
            "https://example.com/a.png",
            validator=lambda url: True,
            max_bytes=16 * 1024,
        )

        assert result is None

    @patch("mddocx.converter.security.requests.get")
    def test_returns_none_when_content_length_oversized(self, mock_get):
        mock_get.return_value = _response(200, {"Content-Length": str(10 * 1024 * 1024)})

        result = fetch_remote_bytes(
            "https://example.com/a.png",
            validator=lambda url: True,
            max_bytes=1024,
        )

        assert result is None

    @patch("mddocx.converter.security.requests.get")
    def test_content_type_prefix_mismatch(self, mock_get):
        mock_get.return_value = _response(200, {"Content-Type": "text/html"})

        result = fetch_remote_bytes(
            "https://example.com/a.png",
            validator=lambda url: True,
            content_type_prefix="image",
        )

        assert result is None

    @patch("mddocx.converter.security.requests.get")
    def test_returns_none_after_too_many_redirects(self, mock_get):
        mock_get.return_value = _response(302, {"Location": "https://example.com/loop"})

        result = fetch_remote_bytes(
            "https://example.com/a.png",
            validator=lambda url: True,
            max_redirects=2,
        )

        assert result is None
        assert mock_get.call_count == 3
