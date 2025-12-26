"""
任务列表转换器单元测试
"""

from unittest.mock import MagicMock

import pytest
from docx import Document

from mddocx.converter.elements.task_list import TaskListConverter


def test_init():
    """测试初始化"""
    converter = TaskListConverter()
    assert converter is not None
    assert converter.document is None
    assert converter.base_converter is None

    # 测试带基础转换器的初始化
    base_converter = MagicMock()
    converter = TaskListConverter(base_converter)
    assert converter.base_converter == base_converter


def test_document_not_set():
    """测试文档未设置的情况"""
    converter = TaskListConverter()
    with pytest.raises(ValueError):
        converter.convert(MagicMock())


def test_convert_task_list():
    """测试任务列表转换"""
    # 创建转换器
    converter = TaskListConverter()
    converter.set_document(Document())

    # 创建模拟任务列表token
    task_token = MagicMock()
    task_token.type = "task_list_item"
    task_token.attrGet.return_value = "checked"

    # 模拟内容
    content_token = MagicMock()
    content_token.content = "任务内容"
    task_token.children = [content_token]

    # 转换任务列表项
    paragraph = converter.convert((task_token, task_token))

    # 验证结果
    assert paragraph is not None


def test_convert_task_list_unchecked():
    """测试未完成任务列表转换"""
    # 创建转换器
    converter = TaskListConverter()
    converter.set_document(Document())

    # 创建模拟任务列表token（未完成）
    task_token = MagicMock()
    task_token.type = "task_list_item"
    task_token.attrGet.return_value = None  # 未完成

    # 模拟内容
    content_token = MagicMock()
    content_token.content = "未完成任务"
    task_token.children = [content_token]

    # 转换任务列表项
    paragraph = converter.convert((task_token, task_token))

    # 验证结果
    assert paragraph is not None
