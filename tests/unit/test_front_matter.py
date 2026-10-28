"""Front matter parsing (SPRINT-STYLE-02 / TASK-044)."""

from mddocx.converter.front_matter import FrontMatter, first_markdown_h1, resolve_cover_title, split_front_matter


def test_no_front_matter():
    md = "# Hello\n\nBody."
    meta, body = split_front_matter(md)
    assert meta == FrontMatter()
    assert body == md


def test_front_matter_strip_and_fields():
    md = """---
title: Report
author: Ada
date: 2026-10-28
cover: true
---
# Section

Content.
"""
    meta, body = split_front_matter(md)
    assert meta.title == "Report"
    assert meta.author == "Ada"
    assert meta.date == "2026-10-28"
    assert meta.cover is True
    assert body.startswith("# Section")
    assert "---" not in body.splitlines()[0]


def test_cover_bool_variants():
    meta_yes, _ = split_front_matter("---\ncover: yes\n---\n")
    assert meta_yes.cover is True
    meta, _ = split_front_matter("---\ncover: false\n---\nx")
    assert meta.cover is False


def test_first_h1_and_resolve_title():
    body = "## not h1\n# Main Title\n"
    assert first_markdown_h1(body) == "Main Title"
    meta = FrontMatter(cover=True)
    assert resolve_cover_title(meta, body) == "Main Title"
    meta_t = FrontMatter(title="FM Title", cover=True)
    assert resolve_cover_title(meta_t, body) == "FM Title"
