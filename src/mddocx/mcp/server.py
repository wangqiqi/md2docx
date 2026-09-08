"""MCP server exposing Markdown → DOCX conversion tools."""

from __future__ import annotations

from typing import Optional

from .convert import convert_markdown_file, convert_markdown_text

_MCP_IMPORT_ERROR: Optional[ImportError] = None

try:
    from mcp.server.mcpserver import MCPServer
except ImportError as exc:
    MCPServer = None  # type: ignore[misc, assignment]
    _MCP_IMPORT_ERROR = exc


def create_server() -> "MCPServer":
    """Build and register MCP tools. Requires ``pip install mddocx[mcp]`` (Python >=3.10)."""
    if MCPServer is None:
        raise ImportError(
            "MCP support requires: pip install 'mddocx[mcp]' (Python >=3.10). " f"Original error: {_MCP_IMPORT_ERROR}"
        ) from _MCP_IMPORT_ERROR

    app = MCPServer(
        "mddocx",
        instructions=(
            "Convert Markdown to DOCX using the mddocx engine. "
            "Mermaid and LaTeX blocks need outbound network (mermaid.ink, latex.codecogs.com). "
            "For editing existing DOCX structure, use a dedicated docx editor skill instead."
        ),
    )

    @app.tool(
        name="convert_md_to_docx",
        description=(
            "Convert Markdown text to a DOCX file. "
            "Use for inline or generated Markdown. "
            "Requires output_path (parent dirs are created). "
            "Not for editing existing DOCX files."
        ),
    )
    def convert_md_to_docx(
        markdown: str,
        output_path: str,
        debug: bool = False,
    ) -> dict:
        return convert_markdown_text(markdown, output_path, debug=debug)

    @app.tool(
        name="convert_md_file_to_docx",
        description=(
            "Convert a Markdown file on disk to DOCX. "
            "output_path is optional (defaults to same stem with .docx). "
            "Use when the source is already a .md file with local images."
        ),
    )
    def convert_md_file_to_docx(
        input_path: str,
        output_path: Optional[str] = None,
        debug: bool = False,
    ) -> dict:
        return convert_markdown_file(input_path, output_path, debug=debug)

    return app


def main() -> None:
    """Entry point for ``mddocx-mcp`` console script (stdio transport)."""
    create_server().run()


if __name__ == "__main__":
    main()
