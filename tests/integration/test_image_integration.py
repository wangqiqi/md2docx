"""
图片转换集成测试
"""

from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from mddocx.converter.base import BaseConverter

FAKE_PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"
    b"\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f"
    b"\x00\x00\x01\x01\x00\x05\x18\xd8d\x00\x00\x00\x00IEND\xaeB`\x82"
)


def _mock_http_response(content: bytes = FAKE_PNG) -> MagicMock:
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.headers = {"Content-Type": "image/png"}
    mock_response.iter_content.return_value = [content]
    return mock_response


class TestImageIntegration:
    """图片转换集成测试"""

    @pytest.fixture
    def base_converter(self):
        return BaseConverter()

    @pytest.fixture
    def sample_dir(self, tmp_path: Path) -> Path:
        img = tmp_path / "local.png"
        img.write_bytes(FAKE_PNG)
        return tmp_path

    @patch("docx.text.run.Run.add_picture")
    def test_local_image_in_markdown(self, mock_add_picture, base_converter, sample_dir):
        """本地图片经 BaseConverter 端到端转换"""
        md = sample_dir / "doc.md"
        md.write_text("# 图\n\n![本地图](local.png)\n", encoding="utf-8")

        doc = base_converter.convert(md.read_text(encoding="utf-8"), base_path=str(md))

        assert doc is not None
        assert len(doc.paragraphs) >= 1
        mock_add_picture.assert_called()

    @patch("docx.text.run.Run.add_picture")
    @patch("requests.get")
    def test_remote_image_with_alt_text(
        self, mock_get, mock_add_picture, base_converter
    ):
        """远程图片与 alt 文本"""
        mock_get.return_value = _mock_http_response()

        content = '![替代文字](https://example.com/image.png "图片标题")\n'
        with patch(
            "mddocx.converter.elements.image.is_safe_remote_url", return_value=True
        ):
            doc = base_converter.convert(content)

        assert doc is not None
        mock_get.assert_called_once()
        mock_add_picture.assert_called()

    @patch("docx.text.run.Run.add_picture")
    @patch("requests.get")
    def test_remote_image_conversion(self, mock_get, mock_add_picture, base_converter):
        """远程图片下载并嵌入文档"""
        mock_get.return_value = _mock_http_response()

        content = "![在线](https://example.com/photo.png)\n"
        with patch(
            "mddocx.converter.elements.image.is_safe_remote_url", return_value=True
        ):
            doc = base_converter.convert(content)

        assert doc is not None
        assert mock_add_picture.call_count >= 1

    @patch("requests.get")
    def test_image_error_handling(self, mock_get, base_converter):
        """远程图片失败时不抛异常，仍产出文档"""
        mock_get.side_effect = ConnectionError("network down")

        content = "![坏链](https://example.com/missing.png)\n"
        with patch(
            "mddocx.converter.elements.image.is_safe_remote_url", return_value=True
        ):
            doc = base_converter.convert(content)

        assert doc is not None
        assert len(doc.paragraphs) >= 1
