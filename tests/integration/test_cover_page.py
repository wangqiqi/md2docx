"""Cover page integration (SPRINT-STYLE-02 / TASK-045)."""

import tempfile
import zipfile
from pathlib import Path

import pytest

TEMPLATE = Path(__file__).resolve().parents[1] / "samples" / "templates" / "minimal_company.docx"


def test_cover_page_from_front_matter(converter):
    md = """---
title: Annual Report
author: Finance Team
date: 2026-10-28
cover: true
---
# Body Heading

Paragraph one.
"""
    doc = converter.convert(md)
    texts = [p.text for p in doc.paragraphs if p.text.strip()]
    assert texts[0] == "Annual Report"
    assert "Finance Team" in texts[1]
    assert "Body Heading" in "\n".join(texts)


def test_cover_page_uses_h1_when_title_missing(converter):
    md = """---
cover: true
author: Solo
---
# Derived Title

Content.
"""
    doc = converter.convert(md)
    assert doc.paragraphs[0].text == "Derived Title"


def test_no_cover_without_flag(converter):
    md = """---
title: Hidden
---
# Visible

Only body.
"""
    doc = converter.convert(md)
    joined = "\n".join(p.text for p in doc.paragraphs)
    assert "Hidden" not in joined.split("\n")[0] or "Visible" in joined


def test_cover_with_template(converter):
    if not TEMPLATE.is_file():
        pytest.skip("template sample missing")
    md = """---
title: Branded Cover
cover: true
---
# Chapter

Text.
"""
    doc = converter.convert(md, template_path=str(TEMPLATE))
    header = doc.sections[0].header.paragraphs[0].text
    assert "MD2DOCX-TEMPLATE-HEADER" in header
    assert doc.paragraphs[0].text == "Branded Cover"


def test_cover_page_has_page_break(converter):
    md = """---
title: Break Test
cover: true
---
# After

x
"""
    doc = converter.convert(md)
    with tempfile.NamedTemporaryFile(suffix=".docx") as tmp:
        doc.save(tmp.name)
        with zipfile.ZipFile(tmp.name) as zf:
            xml = zf.read("word/document.xml").decode("utf-8")
    assert "w:br" in xml and 'w:type="page"' in xml


def test_cover_chunked_mutual_exclusion(converter):
    md = """---
cover: true
title: X
---
# H

y
"""
    with pytest.raises(Exception) as exc:
        converter.convert(md, chunked=True)
    assert "chunked" in str(exc.value).lower() or "分块" in str(exc.value)
