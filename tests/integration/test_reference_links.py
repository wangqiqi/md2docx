"""Reference-style Markdown links and inline spacing (SPRINT-QUAL-03 / TASK-042)."""

import tempfile
import zipfile

import pytest


def _docx_has_external_link(doc, url_part: str) -> bool:
    with tempfile.NamedTemporaryFile(suffix=".docx") as tmp:
        doc.save(tmp.name)
        with zipfile.ZipFile(tmp.name) as zf:
            rels = zf.read("word/_rels/document.xml.rels").decode("utf-8")
            doc_xml = zf.read("word/document.xml").decode("utf-8")
    return url_part in rels and "hyperlink" in doc_xml


@pytest.mark.parametrize(
    "markdown,link_text,url_part,expected_line",
    [
        (
            "[See docs][doc]\n\n[doc]: https://example.com/doc \"Title\"\n",
            "See docs",
            "example.com/doc",
            "See docs",
        ),
        (
            "Read [the manual][manual] now.\n\n[manual]: https://docs.example.com/page\n",
            "the manual",
            "docs.example.com/page",
            "Read the manual now.",
        ),
        (
            "Inline [ref][r] end.\n\n[r]: https://example.com/r\n",
            "ref",
            "example.com/r",
            "Inline ref end.",
        ),
    ],
    ids=["block_ref", "inline_ref", "inline_ref_short"],
)
def test_reference_link_renders_hyperlink(converter, markdown, link_text, url_part, expected_line):
    doc = converter.convert(markdown)
    assert len(doc.paragraphs) >= 1
    assert doc.paragraphs[0].text == expected_line
    xml = doc.paragraphs[0]._element.xml
    assert link_text in xml
    assert _docx_has_external_link(doc, url_part)


def test_reference_link_with_footnote_in_same_doc(converter):
    md = (
        "Body [link][L] and footnote[^n].\n\n"
        "[L]: https://example.com/l\n\n"
        "[^n]: Footnote text.\n"
    )
    doc = converter.convert(md)
    body = doc.paragraphs[0].text
    assert "link" in body and "footnote" in body.lower() or "Footnote" in body
    assert _docx_has_external_link(doc, "example.com/l")
    with tempfile.NamedTemporaryFile(suffix=".docx") as tmp:
        doc.save(tmp.name)
        with zipfile.ZipFile(tmp.name) as zf:
            assert "word/footnotes.xml" in zf.namelist()
