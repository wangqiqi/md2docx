"""Markdown 分块工具（按一级标题切分）。"""

from __future__ import annotations

from typing import List


def split_markdown_sections(md_text: str) -> List[str]:
    """按一级标题 ``# `` 切分 Markdown，保留标题行在各段内。

    首段可无标题（前言）；空输入返回空列表。
    """
    if not md_text or not md_text.strip():
        return []

    sections: List[str] = []
    current: List[str] = []

    for line in md_text.splitlines(keepends=True):
        if line.startswith("# ") and current:
            sections.append("".join(current))
            current = [line]
        else:
            current.append(line)

    if current:
        sections.append("".join(current))

    return [s for s in sections if s.strip()]
