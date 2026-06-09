"""
数学公式集成测试
"""

from unittest.mock import MagicMock, patch

from mddocx.converter.base import BaseConverter

FAKE_PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"
    b"\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f"
    b"\x00\x00\x01\x01\x00\x05\x18\xd8d\x00\x00\x00\x00IEND\xaeB`\x82"
)

MATH_MD = """# 公式示例

行内：$E = mc^2$

块级：

$$
\\frac{1}{2}
$$
"""

NUMBERED_MATH_MD = r"""# 编号公式

$$
E=mc^2 \label{eq:emc}
$$

见式 \ref{eq:emc}。
"""


@patch("docx.text.run.Run.add_picture")
@patch("mddocx.converter.elements.math.requests.get")
def test_math_integration_numbered_ref(mock_get, mock_add_picture, tmp_path):
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    doc = BaseConverter().convert(NUMBERED_MATH_MD)
    output = tmp_path / "math_numbered.docx"
    doc.save(str(output))

    assert output.exists()
    text = "\n".join(p.text for p in doc.paragraphs)
    assert "(1)" in text
    assert "见式 (1)" in text


@patch("docx.text.run.Run.add_picture")
@patch("mddocx.converter.elements.math.requests.get")
def test_math_integration(mock_get, mock_add_picture, tmp_path):
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    doc = BaseConverter().convert(MATH_MD)
    output = tmp_path / "math.docx"
    doc.save(str(output))

    assert output.exists()
    assert output.stat().st_size > 0
    assert mock_get.called
    assert "latex.codecogs.com" in mock_get.call_args[0][0]
