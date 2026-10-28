"""Quality-tier sample regression (SPRINT-QUAL-01 / SPRINT-QUAL-02)."""

import tempfile
import zipfile
from pathlib import Path

import pytest

QUALITY_DIR = Path(__file__).resolve().parent.parent / "samples" / "quality"


def _paragraph_text(doc) -> str:
    return "\n".join(p.text for p in doc.paragraphs)


def _list_paragraphs(doc):
    return [p for p in doc.paragraphs if p.style and p.style.name.startswith("List")]


def _table_cell_texts(table):
    rows = []
    for row in table.rows:
        rows.append([cell.text for cell in row.cells])
    return rows


@pytest.fixture
def samples_quality():
    assert QUALITY_DIR.is_dir()
    return QUALITY_DIR


def test_quality_nested_lists(converter, samples_quality):
    md = samples_quality / "nested_lists_quality.md"
    content = md.read_text(encoding="utf-8")
    doc = converter.convert(content, base_path=str(md))

    text = _paragraph_text(doc)
    assert "红富士" in text
    assert "用户需求" in text
    assert "重要" in text and "紧急" in text

    list_ps = _list_paragraphs(doc)
    assert len(list_ps) >= 10

    strike_runs = [
        r.font.strike
        for p in doc.paragraphs
        for r in p.runs
        if "已完成" in r.text
    ]
    assert any(strike_runs), "strikethrough list item expected"


def test_quality_tables(converter, samples_quality):
    md = samples_quality / "tables_quality.md"
    content = md.read_text(encoding="utf-8")
    doc = converter.convert(content, base_path=str(md))

    assert len(doc.tables) == 3

    empty_grid = _table_cell_texts(doc.tables[0])
    assert empty_grid[1][1] == ""
    assert empty_grid[1][2] == "3"
    assert empty_grid[2][0] == ""

    inline_table = doc.tables[2]
    br_cell = inline_table.rows[1].cells[1]
    br_text = br_cell.text
    assert "行一" in br_text and "行二" in br_text
    assert "行一" not in br_text.replace("行二", "") or "\n" in br_text or len(br_cell.paragraphs) >= 2

    style_cell = inline_table.rows[2].cells[1]
    runs = style_cell.paragraphs[0].runs
    assert any(r.italic for r in runs if r.text.strip())
    assert any(r.bold for r in runs if r.text.strip())

    code_cell = inline_table.rows[3].cells[1]
    assert 'print("hi")' in code_cell.text


def test_quality_footnotes(converter, samples_quality):
    md = samples_quality / "footnotes_quality.md"
    content = md.read_text(encoding="utf-8")
    doc = converter.convert(content, base_path=str(md))

    body = _paragraph_text(doc)
    assert "正文引用" in body

    with tempfile.NamedTemporaryFile(suffix=".docx") as tmp:
        doc.save(tmp.name)
        with zipfile.ZipFile(tmp.name) as zf:
            assert "word/footnotes.xml" in zf.namelist()
            foot_xml = zf.read("word/footnotes.xml").decode("utf-8")
            assert "脚注正文" in foot_xml
            doc_xml = zf.read("word/document.xml").decode("utf-8")
            assert "footnoteReference" in doc_xml


def test_quality_toc(converter, samples_quality):
    md = samples_quality / "toc_quality.md"
    content = md.read_text(encoding="utf-8")
    doc = converter.convert(content, base_path=str(md))

    assert "第一节正文" in _paragraph_text(doc)

    with tempfile.NamedTemporaryFile(suffix=".docx") as tmp:
        doc.save(tmp.name)
        with zipfile.ZipFile(tmp.name) as zf:
            doc_xml = zf.read("word/document.xml").decode("utf-8")
            assert "instrText" in doc_xml and "TOC" in doc_xml


def test_quality_pandoc_reference_links(converter, samples_quality):
    md = samples_quality / "pandoc_quality.md"
    content = md.read_text(encoding="utf-8")
    doc = converter.convert(content, base_path=str(md))

    text = _paragraph_text(doc)
    assert "See the spec" in text
    assert "read the guide before shipping" in text.replace("\n", " ")
    assert "prefix middle suffix" in text.replace("\n", " ")

    with tempfile.NamedTemporaryFile(suffix=".docx") as tmp:
        doc.save(tmp.name)
        with zipfile.ZipFile(tmp.name) as zf:
            rels = zf.read("word/_rels/document.xml.rels").decode("utf-8")
            doc_xml = zf.read("word/document.xml").decode("utf-8")
            assert "example.com/specification" in rels
            assert "docs.example.com/guide" in rels
            assert "hyperlink" in doc_xml
            assert "word/footnotes.xml" in zf.namelist()
