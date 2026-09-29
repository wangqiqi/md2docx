"""
大文件处理测试
"""

import pytest

from mddocx.converter.base import BaseConverter
from mddocx.converter.chunking import split_markdown_sections
from mddocx.converter.security import (
    CHUNKED_THRESHOLD,
    MAX_MARKDOWN_BYTES,
    MarkdownTooLargeError,
    validate_markdown_size,
)


class TestLargeFileHandling:
    """大文件处理测试"""

    @pytest.fixture
    def base_converter(self):
        return BaseConverter()

    def test_large_markdown_file(self, base_converter):
        large_content = "# 大文件测试\n\n" + "测试内容\n" * 1000
        result = base_converter.convert(large_content)
        assert result is not None

    def test_chunked_conversion_explicit(self, base_converter):
        md = "# 第一节\n\n段落一\n\n# 第二节\n\n段落二\n"
        doc = base_converter.convert(md, chunked=True)
        text = "\n".join(p.text for p in doc.paragraphs)
        assert "段落一" in text
        assert "段落二" in text

    def test_chunked_auto_threshold(self, base_converter):
        """超过 CHUNKED_THRESHOLD 时自动分块（与单次 parse 结果一致）"""
        body = "x" * 600
        sections = [f"# Part {i}\n\n{body}\n" for i in range(900)]
        md = "".join(sections)
        assert len(md.encode("utf-8")) >= CHUNKED_THRESHOLD

        doc_chunked = base_converter.convert(md, chunked=True)
        doc_single = base_converter.convert(md, chunked=False)
        assert len(doc_chunked.paragraphs) == len(doc_single.paragraphs)

    def test_split_markdown_sections(self):
        md = "前言\n\n# A\n\none\n\n# B\n\ntwo\n"
        parts = split_markdown_sections(md)
        assert len(parts) == 3
        assert parts[0].startswith("前言")
        assert parts[1].startswith("# A")
        assert parts[2].startswith("# B")

    def test_rejects_oversized_markdown(self, base_converter):
        huge = "a" * (MAX_MARKDOWN_BYTES + 1)
        with pytest.raises(MarkdownTooLargeError):
            base_converter.convert(huge)

    def test_validate_markdown_size_ok(self):
        assert validate_markdown_size("# hi") > 0

    def test_memory_usage_same_output_small_doc(self, base_converter):
        """小文档分块与不分块输出段落数一致"""
        md = "# T\n\nhello\n"
        a = base_converter.convert(md, chunked=False)
        b = base_converter.convert(md, chunked=True)
        assert len(a.paragraphs) == len(b.paragraphs)


class TestChunkingFenceAwareness:
    """围栏内的 "# " 不能被当作一级标题切分（否则分块后渲染会撕裂）。"""

    FENCED = """# Title

```bash
# this is a comment
echo hi
```

More text.
"""

    def test_no_split_inside_backtick_fence(self):
        sections = split_markdown_sections(self.FENCED)
        assert len(sections) == 1
        assert sections[0] == self.FENCED

    def test_no_split_inside_tilde_fence(self):
        md = "# T\n\n~~~python\n# not a heading\n~~~\n"
        assert len(split_markdown_sections(md)) == 1

    def test_splits_again_after_fence_closes(self):
        md = "# A\n\n```\n# not heading\n```\n\n# B\n\ntext\n"
        sections = split_markdown_sections(md)
        assert len(sections) == 2
        assert sections[0].startswith("# A")
        assert sections[1].startswith("# B")
        assert "# not heading" in sections[0]

    def test_indented_fence_marker_ignored(self):
        """4 空格缩进是缩进代码块，不是围栏。"""
        md = "# A\n\n    ```\n# B\n"
        sections = split_markdown_sections(md)
        assert len(sections) == 2

    def test_chunked_matches_unchunked_for_fenced_code(self, base_converter):
        """含 "# " 注释的代码块，分块与不分块渲染一致。"""
        md = self.FENCED + "\n" + "filler\n\n" * 20
        normal = base_converter.convert(md, chunked=False)
        chunked = base_converter.convert(md, chunked=True)

        normal_paras = [(p.style.name, p.text) for p in normal.paragraphs]
        chunked_paras = [(p.style.name, p.text) for p in chunked.paragraphs]
        assert chunked_paras == normal_paras
        assert ("Code", "# this is a comment\necho hi") in chunked_paras
