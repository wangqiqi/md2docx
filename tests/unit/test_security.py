"""
安全校验模块单元测试
"""

import tempfile
from pathlib import Path
from unittest.mock import patch

import pytest

from mddocx.converter.security import (
    is_private_ip,
    is_safe_remote_url,
    resolve_safe_local_path,
)


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
