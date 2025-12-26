"""
标题转换器测试模块
"""

import pytest
from docx import Document
from markdown_it import MarkdownIt

from mddocx.converter.base import BaseConverter
from mddocx.converter.elements.heading import HeadingConverter


def test_heading_conversion():
    """测试标题转换功能"""
    # 准备测试数据
    md_text = """# 一级标题
## 二级标题
### 三级标题
#### 四级标题
##### 五级标题
###### 六级标题"""

    # 初始化转换器
    converter = BaseConverter()
    converter.register_converter("heading", HeadingConverter())

    # 执行转换
    doc = converter.convert(md_text)

    # 验证结果
    paragraphs = doc.paragraphs
    assert len(paragraphs) == 6

    # 验证标题级别和内容
    expected_titles = [
        ("一级标题", "Heading 1"),
        ("二级标题", "Heading 2"),
        ("三级标题", "Heading 3"),
        ("四级标题", "Heading 4"),
        ("五级标题", "Heading 5"),
        ("六级标题", "Heading 6"),
    ]

    for i, (text, style) in enumerate(expected_titles):
        paragraph = paragraphs[i]
        assert paragraph.text == text
        assert paragraph.style.name == style


def test_invalid_heading_level():
    """测试无效的标题级别"""
    converter = HeadingConverter()
    converter.set_document(Document())

    # 创建一个无效的标题标记
    md = MarkdownIt()
    tokens = md.parse("# 测试")
    tokens[0].tag = "h7"  # 无效的标题级别

    with pytest.raises(ValueError, match="不支持的标题级别"):
        converter.convert((tokens[0], tokens[1]))


def test_document_not_set():
    """测试未设置文档实例的情况"""
    converter = HeadingConverter()
    tokens = MarkdownIt().parse("# 测试")

    with pytest.raises(ValueError, match="Document not set"):
        converter.convert((tokens[0], tokens[1]))
