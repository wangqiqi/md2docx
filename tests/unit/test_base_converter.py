"""
BaseConverter token 路由边界测试
"""

from unittest.mock import MagicMock, patch

import pytest

from mddocx.converter.base import BaseConverter, ConvertError

FAKE_PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"
    b"\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f"
    b"\x00\x00\x01\x01\x00\x05\x18\xd8d\x00\x00\x00\x00IEND\xaeB`\x82"
)


class TestBaseConverterRouting:
    @patch("docx.text.run.Run.add_picture")
    @patch("mddocx.converter.elements.mermaid.requests.get")
    def test_fence_mermaid_routes_to_mermaid(self, mock_get, mock_add_picture):
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.headers = {"Content-Type": "image/png"}
        mock_resp.iter_content.return_value = [FAKE_PNG]
        mock_get.return_value = mock_resp

        md = "```mermaid\ngraph TD\n  A --> B\n```"
        BaseConverter().convert(md)
        assert mock_get.called

    def test_fence_python_routes_to_code(self):
        md = "```python\nprint('hi')\n```"
        doc = BaseConverter().convert(md)
        text = "\n".join(p.text for p in doc.paragraphs)
        assert "print('hi')" in text

    def test_fence_without_lang_routes_to_code(self):
        md = "```\nplain code\n```"
        doc = BaseConverter().convert(md)
        text = "\n".join(p.text for p in doc.paragraphs)
        assert "plain code" in text

    def test_html_block_routes_to_html_converter(self):
        md = "<div>块级 HTML</div>\n\n正文"
        doc = BaseConverter().convert(md)
        text = "\n".join(p.text for p in doc.paragraphs)
        assert "块级 HTML" in text or "正文" in text

    def test_html_inline_in_paragraph(self):
        md = "段落含 <strong>粗体</strong> 文本"
        doc = BaseConverter().convert(md)
        text = "\n".join(p.text for p in doc.paragraphs)
        assert "粗体" in text

    def test_convert_logs_duration(self, caplog):
        import logging

        caplog.set_level(logging.INFO, logger="mddocx.converter.base")
        BaseConverter().convert("# Hi")
        assert any("duration_ms=" in r.message for r in caplog.records)

    def test_convert_sets_last_metrics(self):
        from mddocx.converter.metrics import ConvertMetrics

        converter = BaseConverter()
        assert converter.last_metrics is None
        md = "# Hi\n\nbody"
        converter.convert(md)
        metrics = converter.last_metrics
        assert isinstance(metrics, ConvertMetrics)
        assert metrics.duration_ms >= 0
        assert metrics.input_bytes == len(md.encode("utf-8"))
        assert metrics.chunked is False

    def test_convert_file_sets_last_metrics(self, tmp_path):
        md = tmp_path / "doc.md"
        content = "# 文件标题\n"
        md.write_text(content, encoding="utf-8")
        converter = BaseConverter()
        converter.convert_file(md)
        metrics = converter.last_metrics
        assert metrics is not None
        assert metrics.input_bytes == len(content.encode("utf-8"))
        assert metrics.duration_ms >= 0
        assert metrics.chunked is False

    def test_convert_error_preserves_exception_type(self):
        """未知异常包装为 ConvertError 并保留 __cause__ 与类型名"""
        converter = BaseConverter()
        with patch.object(converter, "md") as mock_md:
            mock_md.parse.side_effect = RuntimeError("token boom")
            with pytest.raises(ConvertError, match="RuntimeError") as exc_info:
                converter.convert("# x")
            assert isinstance(exc_info.value.__cause__, RuntimeError)
            # finally 仍应写入指标
            assert converter.last_metrics is not None
            assert converter.last_metrics.chunked is False


class TestBaseConverterSizeAndFile:
    def test_convert_rejects_oversized_markdown(self):
        from mddocx.converter.security import MAX_MARKDOWN_BYTES, MarkdownTooLargeError

        huge = "x" * (MAX_MARKDOWN_BYTES + 1)
        with pytest.raises(MarkdownTooLargeError):
            BaseConverter().convert(huge)

    def test_convert_file_reads_markdown(self, tmp_path):
        md = tmp_path / "doc.md"
        md.write_text("# 文件标题\n\n正文\n", encoding="utf-8")
        doc = BaseConverter().convert_file(md)
        text = "\n".join(p.text for p in doc.paragraphs)
        assert "文件标题" in text
        assert "正文" in text

    def test_convert_file_missing_raises(self, tmp_path):
        missing = tmp_path / "nope.md"
        with pytest.raises(FileNotFoundError):
            BaseConverter().convert_file(missing)

    def test_convert_file_rejects_oversized_on_disk(self, tmp_path):
        from mddocx.converter.security import MAX_MARKDOWN_BYTES, MarkdownTooLargeError

        big = tmp_path / "big.md"
        with open(big, "wb") as handle:
            handle.write(b"#" + b"x" * MAX_MARKDOWN_BYTES)

        with pytest.raises(MarkdownTooLargeError):
            BaseConverter().convert_file(big)
