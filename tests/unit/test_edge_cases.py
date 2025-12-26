"""
边缘情况测试
"""

import pytest

from mddocx.converter.base import BaseConverter


class TestEdgeCases:
    """边缘情况测试"""

    @pytest.fixture
    def base_converter(self):
        """创建基础转换器实例"""
        return BaseConverter()

    def test_empty_input(self, base_converter):
        """测试空输入"""
        result = base_converter.convert("")
        assert result is not None

    def test_whitespace_only(self, base_converter):
        """测试只有空白字符的输入"""
        result = base_converter.convert("   \n\t  ")
        assert result is not None

    def test_very_long_input(self, base_converter):
        """测试非常长的输入"""
        long_text = "测试文本\n" * 1000
        result = base_converter.convert(long_text)
        assert result is not None

    def test_special_characters(self, base_converter):
        """测试特殊字符"""
        special_text = "特殊字符: éñüñ 中文 🚀"
        result = base_converter.convert(special_text)
        assert result is not None
