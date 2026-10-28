"""OOXML footnotes support for python-docx (no upstream API)."""

from __future__ import annotations

from typing import Optional

from docx.opc.constants import RELATIONSHIP_TYPE as RT
from docx.opc.packuri import PackURI
from docx.opc.part import XmlPart
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn
from docx.text.paragraph import Paragraph

_FOOTNOTES_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml"

_FOOTNOTES_XML = """<w:footnotes {ns}>
  <w:footnote w:type="separator" w:id="-1">
    <w:p><w:r><w:separator/></w:r></w:p>
  </w:footnote>
  <w:footnote w:type="continuationSeparator" w:id="0">
    <w:p><w:r><w:continuationSeparator/></w:r></w:p>
  </w:footnote>
</w:footnotes>""".format(
    ns=nsdecls("w")
)


class FootnoteManager:
    """Create footnote bodies and reference markers in a Document."""

    def __init__(self) -> None:
        self._bodies: dict[int, str] = {}
        self._footnotes_part: Optional[XmlPart] = None
        self._footnotes_el: Optional[OxmlElement] = None
        self._document_part = None

    def reset(self) -> None:
        self._bodies.clear()
        self._footnotes_part = None
        self._footnotes_el = None
        self._document_part = None

    def register_body(self, mdit_id: int, text: str) -> None:
        self._bodies[mdit_id] = text.strip()

    def bind_document(self, document) -> None:
        self._document_part = document.part

    def add_reference(self, paragraph: Paragraph, mdit_id: int) -> None:
        text = self._bodies.get(mdit_id, "")
        docx_id = mdit_id + 1
        self._ensure_part()
        assert self._footnotes_el is not None
        if not self._footnote_exists(docx_id):
            self._append_footnote_body(docx_id, text)

        run = paragraph.add_run()
        r = run._r
        r_pr = OxmlElement("w:rPr")
        r_style = OxmlElement("w:rStyle")
        r_style.set(qn("w:val"), "FootnoteReference")
        r_pr.append(r_style)
        r.insert(0, r_pr)
        ref = OxmlElement("w:footnoteReference")
        ref.set(qn("w:id"), str(docx_id))
        r.append(ref)

    def _ensure_part(self) -> None:
        if self._footnotes_part is not None:
            return
        if self._document_part is None:
            raise RuntimeError("FootnoteManager.bind_document() required")

        doc_part = self._document_part
        for rel in doc_part.rels.values():
            if rel.reltype == RT.FOOTNOTES:
                self._footnotes_part = rel.target_part
                self._footnotes_el = rel.target_part.element
                return

        footnotes_el = parse_xml(_FOOTNOTES_XML)
        footnotes_part = XmlPart(
            PackURI("/word/footnotes.xml"),
            _FOOTNOTES_CT,
            footnotes_el,
            doc_part.package,
        )
        doc_part.relate_to(footnotes_part, RT.FOOTNOTES)
        self._footnotes_part = footnotes_part
        self._footnotes_el = footnotes_el

    def _append_footnote_body(self, docx_id: int, text: str) -> None:
        assert self._footnotes_el is not None
        fn = OxmlElement("w:footnote")
        fn.set(qn("w:id"), str(docx_id))
        p = OxmlElement("w:p")
        p_pr = OxmlElement("w:pPr")
        p_style = OxmlElement("w:pStyle")
        p_style.set(qn("w:val"), "FootnoteText")
        p_pr.append(p_style)
        p.append(p_pr)

        ref_run = OxmlElement("w:r")
        ref_rpr = OxmlElement("w:rPr")
        ref_style = OxmlElement("w:rStyle")
        ref_style.set(qn("w:val"), "FootnoteReference")
        ref_rpr.append(ref_style)
        ref_run.append(ref_rpr)
        ref_run.append(OxmlElement("w:footnoteRef"))
        p.append(ref_run)

        text_run = OxmlElement("w:r")
        t = OxmlElement("w:t")
        t.set(qn("xml:space"), "preserve")
        t.text = f" {text}" if text else " "
        text_run.append(t)
        p.append(text_run)

        fn.append(p)
        self._footnotes_el.append(fn)

    def _footnote_exists(self, docx_id: int) -> bool:
        assert self._footnotes_el is not None
        for fn in self._footnotes_el:
            if fn.tag == qn("w:footnote") and fn.get(qn("w:id")) == str(docx_id):
                return True
        return False


def extract_footnote_text(tokens, start_index: int) -> tuple[int, str]:
    i = start_index + 1
    parts: list[str] = []
    while i < len(tokens):
        tok = tokens[i]
        if tok.type == "footnote_close":
            return i, " ".join(parts).strip()
        if tok.type == "inline" and hasattr(tok, "children"):
            for child in tok.children:
                if child.type == "text" and child.content:
                    parts.append(child.content)
                elif child.type == "softbreak":
                    parts.append(" ")
        i += 1
    return start_index, " ".join(parts).strip()
