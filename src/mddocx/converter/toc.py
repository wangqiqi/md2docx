"""Insert Word TOC field into a paragraph."""

from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.text.paragraph import Paragraph


def insert_toc_field(paragraph: Paragraph, levels: str = "1-3") -> None:
    """Append a TOC field (Word updates fields on open)."""
    instr = f' TOC \\o "{levels}" \\h \\z \\u '
    run = paragraph.add_run()
    r = run._r

    def _fld_char(field_type: str) -> None:
        fld = OxmlElement("w:fldChar")
        fld.set(qn("w:fldCharType"), field_type)
        r.append(fld)

    _fld_char("begin")
    instr_el = OxmlElement("w:instrText")
    instr_el.set(qn("xml:space"), "preserve")
    instr_el.text = instr
    r.append(instr_el)
    _fld_char("separate")
    _fld_char("end")
