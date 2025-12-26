"""
test full conversion 测试
"""
"""
完整转换流程的集成测试
"""



def test_convert_all_samples(converter, samples_dir, tmp_path):
    """测试转换所有基础样例文件"""
    for md_file in samples_dir.glob("*.md"):
        # 读取 Markdown 文件
        with open(md_file, "r", encoding="utf-8") as f:
            content = f.read()

        # 转换文档
        doc = converter.convert(content)
        assert doc is not None

        # 保存并验证输出
        output_file = tmp_path / f"{md_file.stem}.docx"
        doc.save(str(output_file))
        assert output_file.exists()
        assert output_file.stat().st_size > 0


def test_convert_complex_document(converter, tmp_path):
    """测试转换包含多种元素的复杂文档"""
    content = """# 主标题

这是一段普通文本。

## 子标题

- 列表项 1
  - 嵌套列表项
- 列表项 2

> 这是一段引用
> 多行引用

```python
def hello():
    print("Hello World")
```

1. 有序列表 1
2. 有序列表 2
   - 混合列表
   - 另一个项目

### 三级标题

**粗体文本** 和 *斜体文本*

---

最后一段文本。
"""

    # 转换文档
    doc = converter.convert(content)
    assert doc is not None

    # 保存并验证输出
    output_file = tmp_path / "complex.docx"
    doc.save(str(output_file))
    assert output_file.exists()
    assert output_file.stat().st_size > 0


def test_convert_empty_elements(converter):
    """测试转换空元素"""
    content = """
#

>

```

```

-

1.
"""
    doc = converter.convert(content)
    assert doc is not None


def test_convert_mixed_styles(converter):
    """测试转换混合样式"""
    content = """# 带有 **粗体** 的标题

> 带有 *斜体* 的引用

- 带有 `代码` 的列表项
"""
    doc = converter.convert(content)
    assert doc is not None


def test_convert_nested_structures(converter):
    """测试转换嵌套结构"""
    content = """> 外层引用
> > 内层引用
> > > 最内层引用

- 外层列表
  - 内层列表
    - 最内层列表
      1. 混合有序列表
      2. 第二项
"""
    doc = converter.convert(content)
    assert doc is not None
