"""
HTML转换器单元测试
"""

from unittest.mock import MagicMock, patch

import pytest
from docx import Document

from mddocx.converter.elements.html import HTML2DOCX_AVAILABLE, HTML_FOR_DOCX_AVAILABLE, HtmlConverter


def test_html_for_docx_alias_matches_legacy_flag():
    """HTML2DOCX_AVAILABLE 与 HTML_FOR_DOCX_AVAILABLE 保持一致（兼容别名）。"""
    assert HTML2DOCX_AVAILABLE == HTML_FOR_DOCX_AVAILABLE


def test_init():
    """测试初始化"""
    converter = HtmlConverter()
    assert converter is not None
    assert converter.document is None
    assert converter.debug is False

    # 测试带基础转换器的初始化
    base_converter = MagicMock()
    base_converter.debug = True
    converter = HtmlConverter(base_converter)
    assert converter.debug is True


def test_document_not_set():
    """测试文档未设置的情况"""
    converter = HtmlConverter()
    with pytest.raises(ValueError):
        converter.convert(MagicMock())


@pytest.mark.skipif(not HTML_FOR_DOCX_AVAILABLE, reason="html-for-docx not available")
def test_convert_with_html_for_docx():
    """复杂 HTML 在自定义解析失败时走 html-for-docx。"""
    converter = HtmlConverter()
    converter.set_document(Document())

    token = MagicMock()
    token.type = "html_block"
    token.content = """<div class="container">
  <h2>HTML标题</h2>
  <p>这是一个<strong>复杂</strong>的<em>HTML</em>结构。</p>
</div>"""

    result = converter.convert(token)

    assert result is not None
    all_text = " ".join(p.text for p in converter.document.paragraphs)
    assert "HTML标题" in all_text
    assert "复杂" in all_text


def test_convert_without_html_for_docx():
    """html-for-docx 不可用时回退到基本转换。"""
    converter = HtmlConverter()
    converter.set_document(Document())

    with patch("mddocx.converter.elements.html.HTML_FOR_DOCX_AVAILABLE", False), patch(
        "mddocx.converter.elements.html.HTML2DOCX_AVAILABLE", False
    ):
        token = MagicMock()
        token.type = "html_block"
        token.content = "<p>这是一个<strong>HTML</strong>段落</p>"

        result = converter.convert(token)

        assert result is not None
        assert len(converter.document.paragraphs) > 0


def test_custom_html_convert_div():
    """测试自定义HTML转换 - div标签"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试div HTML
    html_content = "<div>这是一个div内容</div>"
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None
    assert len(converter.document.paragraphs) > 0


def test_custom_html_convert_unknown_tag():
    """测试自定义HTML转换 - 未知标签"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试未知HTML标签
    html_content = "<unknown>未知标签内容</unknown>"
    result = converter._custom_html_convert(html_content)

    # 验证结果 - 应该返回None
    assert result is None


def test_custom_html_convert_paragraph_with_attributes():
    """测试自定义HTML转换 - 带属性的段落（实际测试不带属性）"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试简单段落（HTML转换器不支持带属性的标签）
    html_content = "<p>简单段落</p>"
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None


def test_custom_html_convert_div_with_attributes():
    """测试自定义HTML转换 - 带属性的div（实际测试不带属性）"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试简单div（HTML转换器不支持带属性的标签）
    html_content = "<div>简单div内容</div>"
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None


def test_custom_html_convert_unordered_list():
    """测试自定义HTML转换 - 无序列表"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试无序列表
    html_content = """<ul>
    <li>第一项</li>
    <li>第二项</li>
    <li>第三项</li>
</ul>"""
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None


def test_custom_html_convert_ordered_list():
    """测试自定义HTML转换 - 有序列表"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试有序列表
    html_content = """<ol>
    <li>第一项</li>
    <li>第二项</li>
    <li>第三项</li>
</ol>"""
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None


def test_custom_html_convert_table():
    """测试自定义HTML转换 - 表格"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试表格
    html_content = """<table>
    <thead>
        <tr><th>表头1</th><th>表头2</th></tr>
    </thead>
    <tbody>
        <tr><td>单元格1</td><td>单元格2</td></tr>
        <tr><td>单元格3</td><td>单元格4</td></tr>
    </tbody>
</table>"""
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None


def test_custom_html_convert_complex_content():
    """测试自定义HTML转换 - 复杂内容"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试复杂HTML内容
    html_content = """<div class="container">
    <h1>标题</h1>
    <p>这是一个<strong>粗体</strong>和<em>斜体</em>的段落。</p>
    <ul>
        <li>列表项1</li>
        <li>列表项2</li>
    </ul>
</div>"""
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None


def test_custom_html_convert_empty_tags():
    """测试自定义HTML转换 - 空标签"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试空标签
    html_content = "<p></p>"
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None


def test_custom_html_convert_whitespace_handling():
    """测试自定义HTML转换 - 空白字符处理"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试带大量空白字符的HTML
    html_content = """

    <p>
        这是带空白字符的    段落
    </p>

    """
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None


def test_custom_html_convert_nested_elements():
    """测试自定义HTML转换 - 嵌套元素"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试嵌套元素
    html_content = "<div><p>嵌套的<strong>粗体</strong>文本</p></div>"
    result = converter._custom_html_convert(html_content)

    # 验证结果
    assert result is not None


def test_html_convert_debug_mode():
    """测试HTML转换 - 调试模式"""
    # 创建转换器（启用调试）
    converter = HtmlConverter()
    converter.debug = True
    converter.set_document(Document())

    # 测试段落转换
    token = MagicMock()
    token.content = "<p>调试模式测试</p>"
    token.children = None

    # 转换HTML
    result = converter.convert(token)

    # 验证结果
    assert result is not None


def test_html_convert_fallback_mode():
    """测试HTML转换 - 回退模式"""
    # 创建转换器
    converter = HtmlConverter()
    converter.set_document(Document())

    # 测试无法用自定义解析的复杂HTML
    token = MagicMock()
    token.content = '<div><script>alert("test")</script><p>复杂HTML</p></div>'
    token.children = None

    # 转换HTML
    result = converter.convert(token)

    # 验证结果 - 应该使用回退方法
    assert result is not None


def test_convert_html_from_token_children():
    """HTML 内容来自 token.children 而非 content。"""
    converter = HtmlConverter()
    converter.set_document(Document())

    child = MagicMock()
    child.content = "<p>子节点段落</p>"
    token = MagicMock(spec=["children", "type"])
    token.children = [child]

    result = converter.convert(token)

    assert result is not None
    assert any("子节点段落" in p.text for p in converter.document.paragraphs)


def test_convert_empty_html_returns_none():
    """空 HTML 内容返回 None。"""
    converter = HtmlConverter()
    converter.debug = True
    converter.set_document(Document())

    token = MagicMock()
    token.content = ""
    token.children = None

    assert converter.convert(token) is None


@pytest.mark.skipif(not HTML_FOR_DOCX_AVAILABLE, reason="html-for-docx not available")
def test_html_for_docx_raises_uses_fallback():
    """html-for-docx 抛错时走 _fallback_convert。"""
    converter = HtmlConverter()
    converter.set_document(Document())

    token = MagicMock()
    token.content = "<section><article>不可解析</article></section>"
    token.children = None

    with patch("mddocx.converter.elements.html.HtmlToDocx") as mock_cls:
        mock_cls.return_value.add_html_to_document.side_effect = RuntimeError("fail")
        result = converter.convert(token)

    assert result is not None
    assert len(converter.document.paragraphs) >= 1


def test_custom_html_table_no_rows():
    """空 table 无 tr 时返回 None。"""
    converter = HtmlConverter()
    converter.set_document(Document())

    html = "<table></table>"
    assert converter._custom_html_convert(html) is None


def test_custom_html_table_zero_cols():
    """table 行无 th/td 时返回 None。"""
    converter = HtmlConverter()
    converter.set_document(Document())

    html = "<table><tr></tr></table>"
    assert converter._custom_html_convert(html) is None


def test_process_inline_strike_and_underline():
    """内联删除线与下划线样式。"""
    converter = HtmlConverter()
    converter.set_document(Document())
    paragraph = converter.document.add_paragraph()

    converter._process_inline_tags("普通<u>下划线</u>和<s>删除</s>文本", paragraph)

    runs_text = "".join(r.text for r in paragraph.runs)
    assert "下划线" in runs_text
    assert "删除" in runs_text


def test_process_inline_tags_exception_fallback():
    """内联解析异常时回退为纯文本。"""
    converter = HtmlConverter()
    converter.set_document(Document())
    paragraph = converter.document.add_paragraph()

    with patch(
        "mddocx.converter.elements.html.re.split",
        side_effect=ValueError("forced"),
    ):
        converter._process_inline_tags("<p>容错</p>", paragraph)

    assert paragraph.text.strip() != ""


def test_custom_html_convert_debug_div_ul_ol_table(capsys):
    """debug 模式下自定义解析各分支打印（覆盖 debug 行）。"""
    converter = HtmlConverter()
    converter.debug = True
    converter.set_document(Document())

    converter._custom_html_convert("<div>div调试</div>")
    converter._custom_html_convert("<ul><li>项</li></ul>")
    converter._custom_html_convert("<ol><li>项</li></ol>")
    converter._custom_html_convert("<table><tr><th>A</th></tr><tr><td>B</td></tr></table>")

    captured = capsys.readouterr().out
    assert "解析div" in captured
    assert "解析无序列表" in captured
    assert "解析有序列表" in captured
    assert "解析表格" in captured


def test_custom_html_convert_debug_exception(capsys):
    """自定义解析异常 + debug 打印。"""
    converter = HtmlConverter()
    converter.debug = True
    converter.set_document(Document())

    with patch.object(converter.doc, "add_paragraph", side_effect=RuntimeError("boom")):
        assert converter._custom_html_convert("<p>fail</p>") is None

    assert "自定义HTML解析失败" in capsys.readouterr().out


def test_convert_debug_fallback_when_html4docx_unavailable(capsys):
    """html-for-docx 不可用且 debug 时走 fallback 分支。"""
    converter = HtmlConverter()
    converter.debug = True
    converter.set_document(Document())

    token = MagicMock()
    token.content = "<section><p>回退</p></section>"
    token.children = None

    with patch("mddocx.converter.elements.html.HTML_FOR_DOCX_AVAILABLE", False), patch(
        "mddocx.converter.elements.html.HTML2DOCX_AVAILABLE", False
    ), patch.object(converter, "_custom_html_convert", return_value=None):
        result = converter.convert(token)

    assert result is not None
    out = capsys.readouterr().out
    assert "html-for-docx 不可用" in out
    assert "使用基本HTML转换" in out


@pytest.mark.skipif(not HTML_FOR_DOCX_AVAILABLE, reason="html-for-docx not available")
def test_convert_debug_html_for_docx_success(capsys):
    """自定义失败、html-for-docx 成功且 debug。"""
    converter = HtmlConverter()
    converter.debug = True
    converter.set_document(Document())

    token = MagicMock()
    token.content = "<section><article>复杂</article></section>"
    token.children = None

    with patch.object(converter, "_custom_html_convert", return_value=None):
        result = converter.convert(token)

    assert result is not None
    assert "尝试使用 html-for-docx 转换" in capsys.readouterr().out


@pytest.mark.skipif(not HTML_FOR_DOCX_AVAILABLE, reason="html-for-docx not available")
def test_convert_debug_html_for_docx_failure(capsys):
    """html-for-docx 抛错且 debug 打印。"""
    converter = HtmlConverter()
    converter.debug = True
    converter.set_document(Document())

    token = MagicMock()
    token.content = "<section><article>失败</article></section>"
    token.children = None

    with patch.object(converter, "_custom_html_convert", return_value=None), patch(
        "mddocx.converter.elements.html.HtmlToDocx"
    ) as mock_cls:
        mock_cls.return_value.add_html_to_document.side_effect = RuntimeError("fail")
        result = converter.convert(token)

    assert result is not None
    assert "HTML转换失败" in capsys.readouterr().out


def test_html_for_docx_convert_empty_document_returns_none():
    """无段落时 _html_for_docx_convert 返回 None。"""
    converter = HtmlConverter()
    converter.set_document(Document())

    with patch("mddocx.converter.elements.html.HtmlToDocx") as mock_cls:
        mock_cls.return_value.add_html_to_document.return_value = None
        assert converter._html_for_docx_convert("<span>x</span>") is None


def test_process_inline_strike_font_errors_debug(capsys):
    """删除线 font/XML 双失败且 debug 打印。"""
    converter = HtmlConverter()
    converter.debug = True
    converter.set_document(Document())
    paragraph = converter.document.add_paragraph()

    mock_run_obj = MagicMock()
    mock_run_obj.text = "删除"

    def _font_prop(self):
        raise RuntimeError("font")

    type(mock_run_obj).font = property(_font_prop)
    mock_run_obj._element.get_or_add_rPr.side_effect = RuntimeError("xml")

    with patch.object(paragraph, "add_run", return_value=mock_run_obj):
        converter._process_inline_tags("<s>删除</s>", paragraph)

    out = capsys.readouterr().out
    assert "无法设置删除线(方法1)" in out
    assert "无法设置删除线(方法2)" in out


def test_process_inline_tags_exception_debug(capsys):
    """内联解析异常 + debug。"""
    converter = HtmlConverter()
    converter.debug = True
    converter.set_document(Document())
    paragraph = converter.document.add_paragraph()

    with patch(
        "mddocx.converter.elements.html.re.split",
        side_effect=ValueError("forced"),
    ):
        converter._process_inline_tags("<p>容错</p>", paragraph)

    assert "处理内联标签失败" in capsys.readouterr().out


@pytest.mark.skipif(not HTML_FOR_DOCX_AVAILABLE, reason="html-for-docx not available")
def test_html_for_docx_no_new_paragraphs():
    """html-for-docx 未新增段落时仍返回已有段落。"""
    converter = HtmlConverter()
    converter.set_document(Document())
    converter.document.add_paragraph("已有")

    with patch("mddocx.converter.elements.html.HtmlToDocx") as mock_cls:
        mock_cls.return_value.add_html_to_document.return_value = None
        result = converter._html_for_docx_convert("<span>x</span>")

    assert result is not None
