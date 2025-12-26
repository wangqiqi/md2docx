"""
任务列表转换集成测试
"""

import pytest

from mddocx.converter.base import BaseConverter


class TestTaskListIntegration:
    """任务列表转换集成测试"""

    @pytest.fixture
    def base_converter(self):
        """创建基础转换器实例"""
        return BaseConverter()

    def test_basic_task_list(self, base_converter):
        """测试基本任务列表转换"""
        md_text = """
- [ ] 未完成任务
- [x] 已完成任务
- [ ] 另一个未完成任务
"""
        doc = base_converter.convert(md_text)
        assert doc is not None

    def test_nested_task_list(self, base_converter):
        """测试嵌套任务列表"""
        md_text = """
- [x] 主要任务1
  - [ ] 子任务1.1
  - [x] 子任务1.2
- [ ] 主要任务2
  - [ ] 子任务2.1
"""
        doc = base_converter.convert(md_text)
        assert doc is not None
