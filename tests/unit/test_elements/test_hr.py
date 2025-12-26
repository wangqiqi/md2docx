"""
分隔线转换器单元测试
"""

from unittest.mock import MagicMock

import pytest
from docx import Document

from mddocx.converter.elements.hr import HRConverter


def test_init():
    """测试初始化"""
    converter = HRConverter()
    assert converter is not None
    assert converter.document is None
    assert converter.debug is False

    # 测试带基础转换器的初始化
    base_converter = MagicMock()
    base_converter.debug = True
    converter = HRConverter(base_converter)
    assert converter.debug is True


def test_document_not_set():
    """测试文档未设置的情况"""
    converter = HRConverter()
    with pytest.raises(ValueError):
        converter.convert(MagicMock())


def test_convert():
    """测试分隔线转换"""
    # 创建转换器
    converter = HRConverter()
    converter.set_document(Document())

    # 创建模拟分隔线token
    hr_token = MagicMock()
    hr_token.type = "hr"
    hr_token.markup = "---"

    # 转换分隔线
    paragraph = converter.convert(hr_token)

    # 验证结果
    assert paragraph is not None
    assert paragraph.alignment == 1  # 居中对齐

    # 验证段落中包含水平线
    # 注意：由于水平线是通过XML元素添加的，无法直接验证
    # 这里只能验证段落存在
    assert paragraph._element is not None
