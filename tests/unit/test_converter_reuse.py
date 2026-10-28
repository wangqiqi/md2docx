"""BaseConverter 复用（_reset_state）等价性与状态清理测试。"""

from docx.oxml.ns import qn

from mddocx.converter import BaseConverter
from mddocx.converter.converter_pool import get_converter, reset_converter_pool

DOC_A = """# Title

Some **bold** and `code` text with a [link](https://example.com).

- bullet one
- bullet two

1. first
2. second

| a | b |
|---|---|
| 1 | 2 |

```python
print("hi")
```
"""

DOC_B = """## Second doc

1. alpha
2. beta

> quote
"""


def _dump(doc):
    rows = []
    for paragraph in doc.paragraphs:
        num_id = ilvl = None
        pPr = paragraph._element.find(qn("w:pPr"))
        if pPr is not None:
            numPr = pPr.find(qn("w:numPr"))
            if numPr is not None:
                num = numPr.find(qn("w:numId"))
                level = numPr.find(qn("w:ilvl"))
                num_id = num.get(qn("w:val")) if num is not None else None
                ilvl = level.get(qn("w:val")) if level is not None else None
        rows.append((paragraph.style.name, paragraph.text, num_id, ilvl))
    tables = [(len(table.rows), len(table.columns)) for table in doc.tables]
    return rows, tables


class TestConverterReuse:
    def test_reused_instance_matches_fresh_instance(self):
        reused = BaseConverter()
        reused_a = _dump(reused.convert(DOC_A))
        reused_b = _dump(reused.convert(DOC_B))

        assert reused_a == _dump(BaseConverter().convert(DOC_A))
        assert reused_b == _dump(BaseConverter().convert(DOC_B))

    def test_reset_clears_list_state(self):
        converter = BaseConverter()
        converter.convert("1. one\n2. two\n")
        list_converter = converter.converters["list"]
        assert list_converter._last_token_type is not None

        converter.convert("# plain\n\ntext\n")
        assert list_converter._last_token_type is None
        assert list_converter._current_numbers == {}
        assert list_converter._numbering_cache == {}

    def test_reset_clears_table_and_code_state(self):
        converter = BaseConverter()
        converter.convert("| a |\n|---|\n| **x** |\n\n```\ncode\n```\n")

        assert converter.converters["code"]._last_was_code is True

        # 手工制造跨文档残留，确认 reset 会清掉
        converter.converters["table"].current_style = {"bold": True}
        converter.convert("# next\n")

        assert converter.converters["table"].current_style == {}
        assert converter.converters["code"]._last_was_code is False

    def test_reset_clears_image_cache(self):
        converter = BaseConverter()
        image_converter = converter.converters["image"]
        image_converter._image_cache["cached"] = b"data"

        converter.convert("# next\n")

        assert image_converter._image_cache == {}

    def test_render_cache_survives_reset(self):
        """渲染缓存跨文档保留，WebUI 线程复用才有收益。"""
        converter = BaseConverter()
        converter.converters["mermaid"]._render_cache.put("graph TD; A-->B", b"png")

        converter.convert("# next\n")

        assert converter.converters["mermaid"]._render_cache.get("graph TD; A-->B") == b"png"

    def test_math_and_mermaid_share_render_cache(self):
        converter = BaseConverter()
        math_cache = converter.converters["math"]._render_cache
        mermaid_cache = converter.converters["mermaid"]._render_cache
        assert math_cache is mermaid_cache
        assert math_cache is converter._render_cache

    def test_get_converter_reuses_same_instance(self):
        reset_converter_pool()
        first = get_converter()
        second = get_converter()
        assert first is second
        reset_converter_pool()
