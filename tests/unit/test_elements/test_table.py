"""
表格转换器单元测试
"""

from unittest.mock import MagicMock

import pytest
from docx import Document

from mddocx.converter.elements.table import TableConverter


def test_init():
    """测试初始化"""
    converter = TableConverter()
    assert converter is not None
    assert converter.document is None
    assert converter.base_converter is None
    assert converter.debug is False

    # 测试带基础转换器的初始化
    base_converter = MagicMock()
    base_converter.debug = True
    converter = TableConverter(base_converter)
    assert converter.base_converter == base_converter
    assert converter.debug is True


def test_document_not_set():
    """测试文档未设置的情况"""
    converter = TableConverter()
    with pytest.raises(ValueError):
        converter.convert(MagicMock())


def test_convert_table():
    """测试表格转换"""
    # 创建转换器
    converter = TableConverter()
    converter.set_document(Document())

    # 创建模拟表格token
    table_token = MagicMock()
    table_token.type = "table_open"

    # 模拟表头行
    thead_token = MagicMock()
    thead_token.type = "thead_open"

    tr_token = MagicMock()
    tr_token.type = "tr_open"

    th1_token = MagicMock()
    th1_token.type = "th_open"
    th1_token.children = [MagicMock()]
    th1_token.children[0].content = "表头1"

    th2_token = MagicMock()
    th2_token.type = "th_open"
    th2_token.children = [MagicMock()]
    th2_token.children[0].content = "表头2"

    # 模拟表体
    tbody_token = MagicMock()
    tbody_token.type = "tbody_open"

    tr2_token = MagicMock()
    tr2_token.type = "tr_open"

    td1_token = MagicMock()
    td1_token.type = "td_open"
    td1_token.children = [MagicMock()]
    td1_token.children[0].content = "单元格1"

    td2_token = MagicMock()
    td2_token.type = "td_open"
    td2_token.children = [MagicMock()]
    td2_token.children[0].content = "单元格2"

    # 设置token结构
    table_token.children = [thead_token, tbody_token]
    thead_token.children = [tr_token]
    tr_token.children = [th1_token, th2_token]
    tbody_token.children = [tr2_token]
    tr2_token.children = [td1_token, td2_token]

    # 创建tokens列表，模拟markdown-it的解析结果
    tokens = [
        table_token,
        thead_token,
        tr_token,
        th1_token,
        MagicMock(type="text", content="表头1"),
        MagicMock(type="th_close"),
        th2_token,
        MagicMock(type="text", content="表头2"),
        MagicMock(type="th_close"),
        MagicMock(type="tr_close"),
        MagicMock(type="thead_close"),
        tbody_token,
        tr2_token,
        td1_token,
        MagicMock(type="text", content="单元格1"),
        MagicMock(type="td_close"),
        td2_token,
        MagicMock(type="text", content="单元格2"),
        MagicMock(type="td_close"),
        MagicMock(type="tr_close"),
        MagicMock(type="tbody_close"),
        MagicMock(type="table_close"),
    ]

    # 转换表格
    table = converter.convert(table_token, tokens)

    # 验证结果
    assert table is not None
