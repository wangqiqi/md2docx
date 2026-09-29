"""Markdown 分块工具（按一级标题切分）。"""

from __future__ import annotations

import re
from typing import List

# 代码围栏起始行：最多 3 个前导空格 + 3 个以上 ` 或 ~（可带 info string）
_FENCE_RE = re.compile(r"^ {0,3}(`{3,}|~{3,})(.*)$")
# 一级标题（与原先的 split 语义保持一致：行首 "# "）
_ATX_H1_RE = re.compile(r"^# ")


def _is_fence_close(line: str, fence_char: str, fence_len: int) -> bool:
    """判断是否是对应围栏的结束行（同字符、不短于起始围栏、无 info string）。"""
    match = _FENCE_RE.match(line)
    if not match:
        return False
    marker, info = match.group(1), match.group(2)
    return marker[0] == fence_char and len(marker) >= fence_len and info.strip() == ""


def split_markdown_sections(md_text: str) -> List[str]:
    """按一级标题 ``# `` 切分 Markdown，保留标题行在各段内。

    切分时会跟踪代码围栏（``` / ~~~）：围栏内以 ``# `` 开头的行（例如 shell /
    Python 注释）不会被误判为标题，否则分块后会撕裂围栏、破坏整段渲染。未闭合
    的围栏会一直吞到文末，保证每一段自身仍是合法的 Markdown 片段。

    首段可无标题（前言）；空输入返回空列表。
    """
    if not md_text or not md_text.strip():
        return []

    sections: List[str] = []
    current: List[str] = []
    fence_char = ""
    fence_len = 0

    for line in md_text.splitlines(keepends=True):
        text = line.rstrip("\r\n")

        # 围栏内：只等结束围栏，绝不在 "# " 处切分
        if fence_char:
            current.append(line)
            if _is_fence_close(text, fence_char, fence_len):
                fence_char = ""
                fence_len = 0
            continue

        fence = _FENCE_RE.match(text)
        if fence:
            fence_char = fence.group(1)[0]
            fence_len = len(fence.group(1))
            current.append(line)
            continue

        if _ATX_H1_RE.match(line) and current:
            sections.append("".join(current))
            current = [line]
        else:
            current.append(line)

    if current:
        sections.append("".join(current))

    return [s for s in sections if s.strip()]
