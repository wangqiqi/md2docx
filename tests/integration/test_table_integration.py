"""
表格转换集成测试
"""

import pytest

from mddocx.converter.base import BaseConverter


class TestTableIntegration:
    """表格转换集成测试"""

    @pytest.fixture
    def base_converter(self):
        """创建基础转换器实例"""
        return BaseConverter()

    def test_basic_table_conversion(self, base_converter):
        """测试基本的表格转换"""
        md_text = """
| 表头1 | 表头2 |
|-------|-------|
| 数据1 | 数据2 |
| 数据3 | 数据4 |
"""
        doc = base_converter.convert(md_text)
        assert doc is not None
        assert len(doc.tables) >= 1

    def test_table_with_alignment(self, base_converter):
        """测试带对齐的表格"""
        md_text = """
| 左对齐 | 居中对齐 | 右对齐 |
|:-------|:--------:|-------:|
| 左     |   中     |     右 |
"""
        doc = base_converter.convert(md_text)
        assert doc is not None
        assert len(doc.tables) >= 1
