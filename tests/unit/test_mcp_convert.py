"""MCP conversion helper tests (no mcp package required)."""

from docx import Document

from mddocx.mcp.convert import convert_markdown_file, convert_markdown_text


class TestConvertMarkdownText:
    def test_success_writes_docx(self, tmp_path):
        out = tmp_path / "out.docx"
        result = convert_markdown_text("# Hello\n\nWorld", str(out))

        assert result["success"] is True
        assert result["output_path"] == str(out.resolve())
        assert out.is_file()
        assert result["input_bytes"] > 0
        assert result["duration_ms"] >= 0

        doc = Document(str(out))
        assert any("Hello" in p.text for p in doc.paragraphs)

    def test_empty_markdown_returns_error(self, tmp_path):
        out = tmp_path / "out.docx"
        result = convert_markdown_text("   \n", str(out))

        assert result["success"] is False
        assert result["error_code"] == "E_INPUT_INVALID"
        assert not out.exists()

    def test_creates_parent_directory(self, tmp_path):
        out = tmp_path / "nested" / "dir" / "out.docx"
        result = convert_markdown_text("# Nested", str(out))

        assert result["success"] is True
        assert out.is_file()


class TestConvertMarkdownFile:
    def test_success_default_output(self, tmp_path):
        md = tmp_path / "sample.md"
        md.write_text("# File\n\nFrom disk.", encoding="utf-8")

        result = convert_markdown_file(str(md))

        assert result["success"] is True
        out = tmp_path / "sample.docx"
        assert result["output_path"] == str(out.resolve())
        assert out.is_file()

    def test_custom_output_path(self, tmp_path):
        md = tmp_path / "sample.md"
        md.write_text("# Custom", encoding="utf-8")
        out = tmp_path / "custom.docx"

        result = convert_markdown_file(str(md), str(out))

        assert result["success"] is True
        assert out.is_file()

    def test_missing_input(self, tmp_path):
        result = convert_markdown_file(str(tmp_path / "missing.md"))

        assert result["success"] is False
        assert result["error_code"] == "E_INPUT_NOT_FOUND"
