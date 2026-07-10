"""
完整转换流程的集成测试
"""

from unittest.mock import MagicMock, patch

FAKE_PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"
    b"\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f"
    b"\x00\x00\x01\x01\x00\x05\x18\xd8d\x00\x00\x00\x00IEND\xaeB`\x82"
)


def _paragraph_text(doc) -> str:
    return "\n".join(p.text for p in doc.paragraphs)


def _first_h1_from_file(md_file):
    with open(md_file, "r", encoding="utf-8") as f:
        for line in f:
            if line.startswith("# "):
                return line[2:].strip()
    return None


def _assert_sample_converted(doc, md_file) -> None:
    """验证样例转换后含标题且文档非空"""
    assert doc is not None
    text = _paragraph_text(doc)
    assert len(doc.paragraphs) >= 1

    title = _first_h1_from_file(md_file)
    if title:
        assert title in text

    stem = md_file.stem
    if stem == "tables":
        assert len(doc.tables) >= 1
    elif stem == "image":
        assert len(text) > 0
        assert (md_file.parent / "1.png").is_file()
    elif stem == "code":
        assert "代码" in text or "python" in text.lower()


@patch("docx.text.run.Run.add_picture")
@patch("requests.get")
def test_convert_image_sample_embeds_local_png(mock_get, mock_add_picture, converter, samples_dir, tmp_path):
    """本地 1.png 端到端嵌入，不发起 HTTP（image.md 含在线图，此处仅用本地片段）"""
    image_md = samples_dir / "image.md"
    assert (samples_dir / "1.png").is_file()

    content = "# 本地图片\n\n![本地图片](1.png)\n"

    doc = converter.convert(content, base_path=str(image_md))
    assert len(doc.paragraphs) >= 1
    assert mock_add_picture.call_count >= 1
    mock_get.assert_not_called()

    output_file = tmp_path / "image.docx"
    doc.save(str(output_file))
    assert output_file.stat().st_size > 0


def test_convert_all_samples(converter, samples_dir, tmp_path):
    """测试转换所有基础样例并验证标题与结构（T-TEST-01-02）"""
    for md_file in samples_dir.glob("*.md"):
        with open(md_file, "r", encoding="utf-8") as f:
            content = f.read()

        doc = converter.convert(content, base_path=str(md_file))
        _assert_sample_converted(doc, md_file)

        output_file = tmp_path / f"{md_file.stem}.docx"
        doc.save(str(output_file))
        assert output_file.exists()
        assert output_file.stat().st_size > 0


@patch("docx.text.run.Run.add_picture")
@patch("mddocx.converter.elements.mermaid.requests.get")
def test_convert_advanced_samples(mock_get, mock_add_picture, converter, samples_advanced, tmp_path):
    """测试转换 advanced 样例（mermaid 走 mock）"""
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    for md_file in samples_advanced.glob("*.md"):
        with open(md_file, "r", encoding="utf-8") as f:
            content = f.read()

        doc = converter.convert(content, base_path=str(md_file))
        _assert_sample_converted(doc, md_file)

        if md_file.stem == "math":
            text = _paragraph_text(doc)
            assert "(5)" in text
            assert "由上式 (5)" in text

        output_file = tmp_path / f"advanced_{md_file.stem}.docx"
        doc.save(str(output_file))
        assert output_file.stat().st_size > 0


@patch("docx.text.run.Run.add_picture")
@patch("mddocx.converter.elements.math.requests.get")
def test_convert_math_sample_label_ref(mock_get, mock_add_picture, converter, samples_advanced, tmp_path):
    """tests/samples/advanced/math.md \\label/\\ref 端到端（T-TEST-03-04）"""
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    math_md = samples_advanced / "math.md"
    with open(math_md, "r", encoding="utf-8") as f:
        content = f.read()

    doc = converter.convert(content, base_path=str(math_md))
    text = _paragraph_text(doc)
    assert "(5)" in text
    assert "由上式 (5)" in text

    output_file = tmp_path / "advanced_math_ref.docx"
    doc.save(str(output_file))
    assert output_file.stat().st_size > 0


def test_convert_chunked_sample(converter, samples_root, tmp_path):
    """tests/samples/large/chunked.md 显式分块转换冒烟（T-TEST-03-06）"""
    chunked_md = samples_root / "large" / "chunked.md"
    assert chunked_md.is_file()

    with open(chunked_md, "r", encoding="utf-8") as f:
        content = f.read()

    doc = converter.convert(content, base_path=str(chunked_md), chunked=True)
    text = _paragraph_text(doc)
    assert "大文档分块样例" in text
    assert "第一节正文" in text
    assert "第三节结束" in text

    output_file = tmp_path / "chunked.docx"
    doc.save(str(output_file))
    assert output_file.stat().st_size > 0


def test_convert_root_test_md(converter, samples_root, tmp_path):
    """测试转换 samples/test.md 综合样例"""
    test_md = samples_root / "test.md"
    with open(test_md, "r", encoding="utf-8") as f:
        content = f.read()

    doc = converter.convert(content, base_path=str(test_md))
    _assert_sample_converted(doc, test_md)

    text = _paragraph_text(doc)
    assert "Markdown to DOCX" in text or "转换测试文档" in text

    output_file = tmp_path / "test.docx"
    doc.save(str(output_file))
    assert output_file.stat().st_size > 0


def test_converter_reuse_does_not_accumulate_content(converter):
    """同一转换器实例多次转换不应累积内容"""
    doc1 = converter.convert("# 第一次\n\n第一段。")
    doc2 = converter.convert("# 第二次\n\n第二段。")

    text1 = _paragraph_text(doc1)
    text2 = _paragraph_text(doc2)

    assert "第一次" in text1
    assert "第二次" not in text1
    assert "第二次" in text2
    assert "第一次" not in text2


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

    doc = converter.convert(content)
    assert doc is not None
    text = _paragraph_text(doc)
    assert "主标题" in text
    assert "粗体文本" in text

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
    text = _paragraph_text(doc)
    assert "粗体" in text


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
    text = _paragraph_text(doc)
    assert "外层引用" in text
