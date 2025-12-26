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

    def test_malformed_markdown(self, base_converter):
        """测试格式错误的Markdown"""
        malformed_text = """# 标题

这是一个段落

- 列表项1
  - 嵌套列表项
- 列表项2

```python
print("hello")
```

[链接文本](http://example.com

**粗体文本*
*斜体文本**

"""
        result = base_converter.convert(malformed_text)
        assert result is not None

    def test_empty_headers(self, base_converter):
        """测试空标题"""
        empty_headers = """
#

##

###

####

"""
        result = base_converter.convert(empty_headers)
        assert result is not None

    def test_nested_lists_complex(self, base_converter):
        """测试复杂的嵌套列表"""
        complex_lists = """
- 项目1
  - 子项目1.1
    - 子子项目1.1.1
    - 子子项目1.1.2
  - 子项目1.2
- 项目2
  1. 编号子项目2.1
  2. 编号子项目2.2
     - 混合子项目2.2.1
- 项目3

1. 编号项目1
   - 子项目1.1
   - 子项目1.2
2. 编号项目2
   1. 嵌套编号2.1
   2. 嵌套编号2.2
"""
        result = base_converter.convert(complex_lists)
        assert result is not None

    def test_tables_with_formatting(self, base_converter):
        """测试带格式的表格"""
        formatted_table = """
| 表头1 | 表头2 | 表头3 |
|--------|--------|--------|
| 普通文本 | **粗体** | *斜体* |
| `代码` | [链接](http://example.com) | 普通文本 |
| 多行<br>文本 | 表情符号 🚀 | 特殊字符 &lt;&gt;&amp; |
"""
        result = base_converter.convert(formatted_table)
        assert result is not None

    def test_mixed_content_types(self, base_converter):
        """测试混合内容类型"""
        mixed_content = """
# 主标题

这是介绍段落，包含**粗体**和*斜体*文本。

## 列表部分

- 项目1
- 项目2
  - 子项目2.1
  - 子项目2.2

## 代码部分

```python
def hello_world():
    print("Hello, World!")
    return True
```

## 表格部分

| 功能 | 状态 | 说明 |
|------|------|------|
| 转换 | ✅ | 支持Markdown到DOCX |
| 样式 | ✅ | 保持格式样式 |
| 图片 | ✅ | 支持图片插入 |

## 引用部分

> 这是一个引用块
> 包含多行内容
>
> > 嵌套引用

## 最后段落

这是文档的结尾。
"""
        result = base_converter.convert(mixed_content)
        assert result is not None

    def test_unicode_and_emojis(self, base_converter):
        """测试Unicode字符和表情符号"""
        unicode_content = """
# Unicode测试 🎉

## 各种语言
- English: Hello World
- Español: ¡Hola Mundo!
- Français: Bonjour le monde
- Deutsch: Hallo Welt
- 中文: 你好世界
- 日本語: こんにちは世界
- 한국어: 안녕하세요 세계
- العربية: مرحبا بالعالم
- Русский: Привет мир

## 表情符号
🎨 🖌️ 📚 💻 🔬 ⚡ 🌟 ✨ 💫 ⭐ 🌙 🌞

## 数学符号
∑ ∏ √ ∫ ∂ ∇ ∞ ≈ ≠ ≡ ≤ ≥ ⊂ ⊃ ∪ ∩ ∈ ∉ ∀ ∃ ∄

## 货币符号
$ € ¥ £ ₽ ₩ ₿

"""
        result = base_converter.convert(unicode_content)
        assert result is not None

    def test_hr_alternatives(self, base_converter):
        """测试分隔线替代语法"""
        hr_variants = """
内容1

---

内容2

***

内容3

___

内容4

===

内容5
"""
        result = base_converter.convert(hr_variants)
        assert result is not None

    def test_task_lists_variations(self, base_converter):
        """测试任务列表变体"""
        task_variations = """
# 任务列表

- [ ] 未完成任务1
- [x] 已完成任务1
- [X] 已完成任务2（大写X）
- [ ] 未完成任务2
  - [x] 子任务完成
  - [ ] 子任务未完成
- [ ] 复杂任务
  包含多行描述
  和更多内容

## 混合列表

1. [ ] 编号任务1
2. [x] 编号任务2
   - [ ] 子任务
   - [x] 另一个子任务

"""
        result = base_converter.convert(task_variations)
        assert result is not None

    def test_base_converter_error_handling(self):
        """测试基础转换器错误处理"""
        from unittest.mock import patch

        from mddocx.converter.base import BaseConverter, MD2DocxError, ParseError

        converter = BaseConverter()

        # 测试MD2DocxError直接抛出
        with patch.object(converter.md, "parse", side_effect=MD2DocxError("测试错误")):
            try:
                converter.convert("# 测试")
                assert False, "应该抛出MD2DocxError"
            except MD2DocxError:
                pass  # 正确行为

        # 测试其他异常转换为ParseError
        with patch.object(converter.md, "parse", side_effect=ValueError("测试异常")):
            try:
                converter.convert("# 测试")
                assert False, "应该抛出ParseError"
            except ParseError as e:
                assert "Markdown解析失败" in str(e)

    def test_base_converter_debug_mode(self):
        """测试基础转换器调试模式"""
        from unittest.mock import patch

        from mddocx.converter.base import BaseConverter

        # 测试启用调试模式
        converter = BaseConverter(debug=True)

        with patch("builtins.print") as mock_print:
            result = converter.convert("# 测试标题")
            assert result is not None
            # 调试模式应该有输出
            assert mock_print.called

    def test_base_converter_empty_document_handling(self):
        """测试基础转换器空文档处理"""
        from mddocx.converter.base import BaseConverter

        converter = BaseConverter()

        # 测试空内容
        result = converter.convert("")
        assert result is not None

        # 测试只有空白字符
        result = converter.convert("   \n\t  ")
        assert result is not None
