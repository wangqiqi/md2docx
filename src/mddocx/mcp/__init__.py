"""MCP server for Markdown → DOCX conversion (optional extra: pip install mddocx[mcp])."""

from __future__ import annotations

__all__ = ["convert_markdown_file", "convert_markdown_text"]

from .convert import convert_markdown_file, convert_markdown_text
