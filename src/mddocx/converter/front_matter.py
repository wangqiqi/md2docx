"""YAML front matter (minimal subset) for Markdown sources."""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Optional, Tuple

_FRONT_MATTER_OPEN = re.compile(r"^---[ \t]*\r?\n", re.MULTILINE)


@dataclass(frozen=True)
class FrontMatter:
    """Parsed document metadata from leading YAML block."""

    title: Optional[str] = None
    author: Optional[str] = None
    date: Optional[str] = None
    cover: bool = False

    @property
    def wants_cover(self) -> bool:
        return self.cover


def _parse_bool(value: str) -> bool:
    return value.strip().lower() in ("true", "yes", "1", "on")


def _strip_quotes(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in ('"', "'"):
        return value[1:-1]
    return value


def _parse_block(block: str) -> FrontMatter:
    title: Optional[str] = None
    author: Optional[str] = None
    date: Optional[str] = None
    cover = False
    for line in block.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if ":" not in stripped:
            continue
        key, _, raw_val = stripped.partition(":")
        key = key.strip().lower()
        val = _strip_quotes(raw_val.strip())
        if key == "title":
            title = val or None
        elif key == "author":
            author = val or None
        elif key == "date":
            date = val or None
        elif key == "cover":
            cover = _parse_bool(val) if val else False
    return FrontMatter(title=title, author=author, date=date, cover=cover)


def split_front_matter(md_text: str) -> Tuple[FrontMatter, str]:
    """Return metadata and body. No leading block → empty metadata and original text."""
    if not md_text.startswith("---"):
        return FrontMatter(), md_text

    match = _FRONT_MATTER_OPEN.match(md_text)
    if not match:
        return FrontMatter(), md_text

    rest = md_text[match.end() :]
    close = rest.find("\n---")
    if close == -1:
        return FrontMatter(), md_text

    block = rest[:close]
    body = rest[close + len("\n---") :]
    if body.startswith("\r\n"):
        body = body[2:]
    elif body.startswith("\n"):
        body = body[1:]
    return _parse_block(block), body


def first_markdown_h1(body: str) -> Optional[str]:
    """First ATX h1 line in body (after front matter removed)."""
    for line in body.splitlines():
        m = re.match(r"^#\s+(.+?)\s*$", line.strip())
        if m:
            return m.group(1).strip()
    return None


def resolve_cover_title(meta: FrontMatter, body: str) -> Optional[str]:
    if meta.title:
        return meta.title
    return first_markdown_h1(body)
