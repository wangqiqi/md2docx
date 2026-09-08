"""Conversion helpers shared by the MCP server (no mcp dependency)."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, Optional

from ..converter import BaseConverter
from ..errors import error_from_exception


def _metrics_dict(converter: BaseConverter) -> Dict[str, Any]:
    metrics = converter.last_metrics
    if metrics is None:
        return {"duration_ms": 0.0, "input_bytes": 0, "chunked": False}
    return {
        "duration_ms": round(metrics.duration_ms, 1),
        "input_bytes": metrics.input_bytes,
        "chunked": metrics.chunked,
    }


def _ensure_parent_dir(path: Path) -> None:
    parent = path.parent
    if parent and not parent.exists():
        parent.mkdir(parents=True, exist_ok=True)


def _success_result(output_path: Path, converter: BaseConverter) -> Dict[str, Any]:
    return {
        "success": True,
        "output_path": str(output_path),
        **_metrics_dict(converter),
    }


def _error_result(exc: Exception) -> Dict[str, Any]:
    info = error_from_exception(exc)
    return {
        "success": False,
        "error_code": info.code,
        "message": info.format_user(),
    }


def convert_markdown_text(
    markdown: str,
    output_path: str,
    *,
    debug: bool = False,
    base_path: Optional[str] = None,
) -> Dict[str, Any]:
    """Convert Markdown text to a DOCX file on disk."""
    if not markdown or not markdown.strip():
        return _error_result(ValueError("Markdown 内容不能为空"))

    out = Path(output_path).expanduser().resolve()
    try:
        _ensure_parent_dir(out)
        converter = BaseConverter(debug=debug)
        doc = converter.convert(markdown, base_path=base_path)
        doc.save(str(out))
        return _success_result(out, converter)
    except Exception as exc:
        return _error_result(exc)


def convert_markdown_file(
    input_path: str,
    output_path: Optional[str] = None,
    *,
    debug: bool = False,
) -> Dict[str, Any]:
    """Convert a Markdown file to DOCX."""
    inp = Path(input_path).expanduser().resolve()
    if not inp.is_file():
        return _error_result(FileNotFoundError(f"输入文件不存在: {inp}"))

    out = Path(output_path).expanduser().resolve() if output_path else inp.with_suffix(".docx")

    try:
        _ensure_parent_dir(out)
        converter = BaseConverter(debug=debug)
        doc = converter.convert_file(inp)
        doc.save(str(out))
        return _success_result(out, converter)
    except Exception as exc:
        return _error_result(exc)
