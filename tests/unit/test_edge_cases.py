"""
test edge cases 测试
"""
"""
边界条件和特殊字符测试
测试系统对各种边缘情况的处理能力
"""




class TestEdgeCases:
    """边界条件测试类"""

    @pytest.fixture
    def converter(self):
        """创建转换器实例"""
        return BaseConverter()

    def test_unicode_characters(self, converter):
        """测试Unicode特殊字符"""
        unicode_content = """# Unicode测试

## 表情符号
🎉 庆祝 🎊 派对 🥳

## 国际字符
中文：你好世界
日本語：こんにちは世界
Русский：Привет мир
العربية：مرحبا بالعالم
Español：Hola mundo

## 特殊符号
™ ® © ℗ § ¶ † ‡ • ◦ ‣ ⁃

## 数学符号
∑ ∏ √ ∫ ∂ ∇ ∞ ≠ ≈ ≤ ≥ ⊂ ⊃ ∪ ∩ ∈ ∉
"""
        doc = converter.convert(unicode_content)
        assert doc is not None
        assert len(doc.paragraphs) > 5

    def test_empty_and_whitespace(self, converter):
        """测试空内容和空白内容"""
        # 完全空的Markdown
        empty_doc = converter.convert("")
        assert empty_doc is not None

        # 只有空白字符
        whitespace_doc = converter.convert("   \n\t  \n  ")
        assert whitespace_doc is not None

        # 大量空白行
        many_empty_lines = "\n" * 100
        empty_lines_doc = converter.convert(many_empty_lines)
        assert empty_lines_doc is not None

    def test_malformed_markdown(self, converter):
        """测试格式错误的Markdown"""
        malformed_content = """# 标题

这是一个段落，没有正确结束。

## 另一个标题
- 项目 1
  - 子项目
    - 深层子项目
- 项目 2

| 表格 | 缺少 | 分隔线 |

> 引用块
>> 嵌套引用
>>> 三层嵌套

```python
def function():
    # 缺少结束标记
"""

        # 不应该抛出异常
        doc = converter.convert(malformed_content)
        assert doc is not None

    def test_extreme_nesting(self, converter):
        """测试极端的嵌套结构"""
        # 生成极度嵌套的列表
        content = "# 极度嵌套测试\n\n"

        # 嵌套10层的列表
        for level in range(10):
            indent = "  " * level
            content += f"{indent}- 级别 {level + 1}\n"

        # 嵌套引用
        for level in range(1, 6):
            content += ">" * level + f" 引用级别 {level}\n"

        doc = converter.convert(content)
        assert doc is not None

    def test_very_long_lines(self, converter):
        """测试超长行"""
        # 生成超长的一行
        long_line = "这是一行非常长的文本，" * 1000  # 约15,000字符

        content = f"# 长行测试\n\n{long_line}\n\n## 正常段落\n\n这是正常的段落。"

        doc = converter.convert(content)
        assert doc is not None
        # 验证长行被正确处理（可能被自动换行）

    def test_special_html_entities(self, converter):
        """测试HTML实体"""
        html_entities_content = """# HTML实体测试

## 基本实体
& < > " '

## 扩展实体
&copy; &reg; &trade; &nbsp; &amp; &lt; &gt; &quot; &apos;

## 数值实体
&#169; &#8482; &#8364; &#8212; &#8230;
"""

        doc = converter.convert(html_entities_content)
        assert doc is not None

    def test_mixed_encodings(self, converter):
        """测试混合编码内容"""
        mixed_content = """# 混合编码测试

## 正常ASCII
Hello World!

## 中文
你好世界！

## 混合内容
Hello 世界！Mixing English and 中文 content.

## 特殊字符组合
café naïve résumé
"""

        doc = converter.convert(mixed_content)
        assert doc is not None

    def test_code_blocks_edge_cases(self, converter):
        """测试代码块的边界情况"""
        code_content = """# 代码块测试

## 空代码块
```
```

## 只有语言标记
```python
```

## 超长代码行
```python
very_long_variable_name_that_goes_on_and_on_and_on_and_on_and_on_and_on_and_on_and_on_and_on_and_on = "very long string"
```

## 特殊字符在代码中
```javascript
const emoji = "🎉🎊🥳";
const unicode = "你好世界";
const symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?";
```
"""

        doc = converter.convert(code_content)
        assert doc is not None

    def test_table_edge_cases(self, converter):
        """测试表格的边界情况"""
        table_content = """# 表格边界测试

## 空表格
| | |
|---|---|---|
| | | |

## 不规则表格
| 列1 | 列2 |
|------|------|
| 数据1 | 数据2 |
| 数据3 |

## 只有标题行
| 标题1 | 标题2 | 标题3 |
|--------|--------|--------|

## 极宽表格
| 非常长的列标题1 | 非常长的列标题2 | 非常长的列标题3 | 非常长的列标题4 | 非常长的列标题5 |
|------------------|------------------|------------------|------------------|------------------|
| 数据1 | 数据2 | 数据3 | 数据4 | 数据5 |
"""

        doc = converter.convert(table_content)
        assert doc is not None

    def test_link_edge_cases(self, converter):
        """测试链接的边界情况"""
        link_content = """# 链接边界测试

## 各种链接格式
[正常链接](https://example.com)
[相对链接](../relative/path)
[锚点链接](#anchor)
[空链接]()
[只有文本]

## URL自动链接
https://github.com
http://example.com
www.example.com

## 引用式链接
这是一个[引用链接][ref1]。

[ref1]: https://example.com "标题"
"""

        doc = converter.convert(link_content)
        assert doc is not None

    def test_image_edge_cases(self, converter):
        """测试图片的边界情况"""
        # 注意：这个测试可能需要mock，因为实际的图片下载可能失败
        image_content = """# 图片边界测试

## 各种图片格式
![正常图片](https://example.com/image.jpg)
![相对路径图片](./images/photo.png)
![空alt](https://example.com/pic.gif)
![只有alt]()

## 带标题的图片
![图片标题](https://example.com/img.jpg "这是图片标题")
"""

        doc = converter.convert(image_content)
        assert doc is not None  # 即使图片下载失败，文档结构应该正常
