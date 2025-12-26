"""
文本转换器单元测试
"""

from unittest.mock import MagicMock

import pytest
from docx import Document

from mddocx.converter.elements.text import TextConverter


def test_init():
    """测试初始化"""
    converter = TextConverter()
    assert converter is not None
    assert converter.document is None
    assert converter.base_converter is None

    # 测试带基础转换器的初始化
    base_converter = MagicMock()
    converter = TextConverter(base_converter)
    assert converter.base_converter == base_converter


def test_document_not_set():
    """测试文档未设置的情况"""
    converter = TextConverter()
    with pytest.raises(ValueError):
        converter.convert(MagicMock())


def test_convert_text():
    """测试文本转换"""
    # 创建转换器
    converter = TextConverter()
    converter.set_document(Document())

    # 创建模拟文本token
    paragraph_token = MagicMock()
    paragraph_token.type = "paragraph_open"

    text_token = MagicMock()
    text_token.type = "text"
    text_token.content = "这是一个简单的段落。"

    # 设置content_token有children
    content_token = MagicMock()
    content_token.children = [text_token]

    # 转换文本
    paragraph = converter.convert((paragraph_token, content_token))

    # 验证结果
    assert paragraph is not None
    assert "这是一个简单的段落。" in paragraph.text


def test_convert_strong_text():
    """测试粗体文本转换"""
    # 创建转换器
    converter = TextConverter()
    converter.set_document(Document())

    # 创建模拟粗体文本token
    paragraph_token = MagicMock()
    paragraph_token.type = "paragraph_open"

    strong_token = MagicMock()
    strong_token.type = "strong_open"

    text_token = MagicMock()
    text_token.type = "text"
    text_token.content = "粗体文本"

    # 设置content_token有children，包含粗体结构
    content_token = MagicMock()
    content_token.children = [strong_token, text_token, MagicMock(type="strong_close")]

    # 转换粗体文本
    paragraph = converter.convert((paragraph_token, content_token))

    # 验证结果
    assert paragraph is not None


def test_convert_emphasis_text():
    """测试斜体文本转换"""
    # 创建转换器
    converter = TextConverter()
    converter.set_document(Document())

    # 创建模拟斜体文本token
    paragraph_token = MagicMock()
    paragraph_token.type = "paragraph_open"

    em_token = MagicMock()
    em_token.type = "em_open"

    text_token = MagicMock()
    text_token.type = "text"
    text_token.content = "斜体文本"

    # 设置content_token有children，包含斜体结构
    content_token = MagicMock()
    content_token.children = [em_token, text_token, MagicMock(type="em_close")]

    # 转换斜体文本
    paragraph = converter.convert((paragraph_token, content_token))

    # 验证结果
    assert paragraph is not None
