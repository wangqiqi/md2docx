"""
大文件处理测试
测试系统对大型Markdown文件的处理能力
"""
import pytest
import tempfile
import os
from pathlib import Path
from src.converter import BaseConverter


class TestLargeFileHandling:
    """大文件处理测试类"""

    @pytest.fixture
    def converter(self):
        """创建转换器实例"""
        return BaseConverter()

    def generate_large_markdown(self, size_mb=1):
        """生成指定大小的Markdown内容"""
        # 估算每个段落的大小
        paragraph_template = """## 第{index}节

这是一个测试段落，包含了一些内容用于测试大文件处理能力。
这里有一些**粗体文本**和*斜体文本*，还有一些`内联代码`。

### 子标题 {index}.1

- 项目 1：这是一个列表项
- 项目 2：包含更多内容
- 项目 3：最后的项目

> 这是一个引用块，用于测试引用处理。

```python
def hello_world():
    print("Hello, World!")
    return "success"
```

---

"""
        content = ""
        paragraphs_needed = max(1, int(size_mb * 1024 * 1024 / len(paragraph_template.encode('utf-8'))))

        for i in range(1, paragraphs_needed + 1):
            content += paragraph_template.format(index=i)

        return content

    def test_large_file_1mb(self, converter):
        """测试1MB文件的处理"""
        large_content = self.generate_large_markdown(size_mb=1)

        # 验证内容大小
        content_size = len(large_content.encode('utf-8'))
        assert content_size > 500 * 1024  # 至少500KB

        # 执行转换
        doc = converter.convert(large_content)

        # 验证转换结果
        assert doc is not None
        assert len(doc.paragraphs) > 10  # 应该有多个段落

    def test_large_file_5mb(self, converter):
        """测试5MB文件的处理"""
        large_content = self.generate_large_markdown(size_mb=5)

        # 验证内容大小
        content_size = len(large_content.encode('utf-8'))
        assert content_size > 2 * 1024 * 1024  # 至少2MB

        # 执行转换（这个测试可能会较慢）
        doc = converter.convert(large_content)

        # 验证转换结果
        assert doc is not None
        assert len(doc.paragraphs) > 50  # 应该有大量段落

    def test_very_deep_nesting(self, converter):
        """测试深度嵌套的结构"""
        # 生成深度嵌套的内容
        content = "# 根标题\n\n"
        for level in range(1, 7):  # H1 到 H6
            content += "#" * level + f" 级别 {level} 标题\n\n"
            content += f"这是级别 {level} 的内容。\n\n"

            # 添加嵌套列表
            indent = "  " * (level - 1)
            for i in range(1, 4):
                content += f"{indent}{i}. 嵌套项目 {i}\n"
            content += "\n"

        doc = converter.convert(content)
        assert doc is not None
        assert len(doc.paragraphs) > 20

    def test_file_with_many_tables(self, converter):
        """测试包含多个表格的文件"""
        content = "# 表格测试文档\n\n"

        # 生成10个表格
        for table_idx in range(1, 11):
            content += f"## 表格 {table_idx}\n\n"
            content += "| 列1 | 列2 | 列3 |\n"
            content += "|-----|-----|-----|\n"

            for row in range(1, 6):  # 每张表5行
                content += f"| 数据{table_idx}-{row}-1 | 数据{table_idx}-{row}-2 | 数据{table_idx}-{row}-3 |\n"

            content += "\n"

        doc = converter.convert(content)
        assert doc is not None
        # 验证包含表格（通过段落数量估算）
        assert len(doc.paragraphs) > 50

    def test_mixed_content_large_file(self, converter):
        """测试混合内容的较大文件"""
        content_parts = []

        # 添加各种类型的元素
        content_parts.append("# 综合测试文档\n\n")

        # 文本段落
        for i in range(1, 21):
            content_parts.append(f"## 章节 {i}\n\n")
            content_parts.append(f"这是第{i}章的内容，包含**粗体**、*斜体*和`代码`。\n\n")
            content_parts.append(f"- 列表项 {i}.1\n- 列表项 {i}.2\n- 列表项 {i}.3\n\n")

            # 每5章添加一个表格
            if i % 5 == 0:
                content_parts.append("| A | B | C |\n| --- | --- | --- |\n| 1 | 2 | 3 |\n\n")

        large_content = "".join(content_parts)

        # 验证内容大小
        assert len(large_content.encode('utf-8')) > 50 * 1024  # 至少50KB

        doc = converter.convert(large_content)
        assert doc is not None
        assert len(doc.paragraphs) > 100  # 大量内容</contents>

