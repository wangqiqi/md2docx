"""DOCX layout preview: Markdown → DOCX → HTML via mammoth."""

from __future__ import annotations

import io
from typing import Any, Callable

import mammoth


def docx_bytes_to_preview_html(docx_bytes: bytes, sanitize: Callable[[str], str]) -> str:
    """Convert DOCX bytes to sanitized HTML suitable for WebUI preview panel."""
    result = mammoth.convert_to_html(io.BytesIO(docx_bytes))
    html = result.value or ""
    safe = sanitize(html)
    return (
        '<div class="docx-layout-preview markdown-preview" '
        'style="font-family: \'Arial\', sans-serif; line-height: 1.6;">'
        f"{safe}"
        "</div>"
    )


def markdown_to_docx_preview_html(
    markdown_content: str,
    *,
    convert: Callable[[str], Any],
    sanitize: Callable[[str], str],
) -> str:
    """Full pipeline for layout preview."""
    document = convert(markdown_content)
    buffer = io.BytesIO()
    document.save(buffer)
    return docx_bytes_to_preview_html(buffer.getvalue(), sanitize)
