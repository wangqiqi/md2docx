"""MCP server registration tests (requires mcp extra)."""

import asyncio

import pytest

pytest.importorskip("mcp")

from mddocx.mcp.server import create_server  # noqa: E402


def test_tools_registered():
    app = create_server()
    tools = asyncio.run(app.list_tools())
    names = {t.name for t in tools}
    assert names == {"convert_md_to_docx", "convert_md_file_to_docx"}


def test_convert_md_to_docx_tool(tmp_path):
    app = create_server()
    out = tmp_path / "tool.docx"
    result = asyncio.run(
        app.call_tool(
            "convert_md_to_docx",
            {"markdown": "# Tool\n\nOK", "output_path": str(out)},
        )
    )
    assert result.is_error is False
    assert out.is_file()
    assert "success" in (result.content[0].text if result.content else "")


def test_convert_md_file_to_docx_tool(tmp_path):
    md = tmp_path / "a.md"
    md.write_text("# From file", encoding="utf-8")
    app = create_server()
    result = asyncio.run(
        app.call_tool(
            "convert_md_file_to_docx",
            {"input_path": str(md)},
        )
    )
    assert result.is_error is False
    assert (tmp_path / "a.docx").is_file()
