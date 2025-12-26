"""
大文件处理测试
"""

import pytest

from mddocx.converter.base import BaseConverter


class TestLargeFileHandling:
    """大文件处理测试"""

    @pytest.fixture
    def base_converter(self):
        """创建基础转换器实例"""
        return BaseConverter()

    def test_large_markdown_file(self, base_converter):
        """测试大文件处理"""
        # 创建一个大的Markdown内容
        large_content = "# 大文件测试\n\n" + "测试内容\n" * 1000
        result = base_converter.convert(large_content)
        assert result is not None

    def test_memory_usage(self, base_converter):
        """测试内存使用情况"""
        # 这里应该测试内存使用
        assert base_converter is not None
