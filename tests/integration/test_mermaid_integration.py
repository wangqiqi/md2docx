"""
Mermaid 集成测试
"""

from unittest.mock import MagicMock, patch

from mddocx.converter.base import BaseConverter

FAKE_PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"
    b"\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f"
    b"\x00\x00\x01\x01\x00\x05\x18\xd8d\x00\x00\x00\x00IEND\xaeB`\x82"
)

GRAPH_MD = """# 流程图示例

```mermaid
graph TD
    A[开始] --> B{判断}
    B --> C[结束]
```
"""


@patch("mddocx.converter.elements.mermaid.requests.get")
def test_mermaid_integration_graph_td(mock_get, tmp_path):
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    doc = BaseConverter().convert(GRAPH_MD)
    output = tmp_path / "mermaid.docx"
    doc.save(str(output))

    assert output.exists()
    assert output.stat().st_size > 0
    assert mock_get.called
    assert "mermaid.ink" in mock_get.call_args[0][0]


SEQUENCE_MD = """# 时序图

```mermaid
sequenceDiagram
    A->>B: ping
```
"""

GANTT_MD = """# 甘特图

```mermaid
gantt
    title Demo
    section S
    T1 :2024-01-01, 3d
```
"""


@patch("mddocx.converter.elements.mermaid.requests.get")
def test_mermaid_integration_sequence(mock_get, tmp_path):
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    doc = BaseConverter().convert(SEQUENCE_MD)
    output = tmp_path / "sequence.docx"
    doc.save(str(output))

    assert output.exists()
    assert mock_get.called


@patch("mddocx.converter.elements.mermaid.requests.get")
def test_mermaid_integration_gantt(mock_get, tmp_path):
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    doc = BaseConverter().convert(GANTT_MD)
    output = tmp_path / "gantt.docx"
    doc.save(str(output))

    assert output.exists()
    assert mock_get.called


STATE_MD = """# 状态图

```mermaid
stateDiagram-v2
    [*] --> Done
    Done --> [*]
```
"""

CLASS_MD = """# 类图

```mermaid
classDiagram
    A <|-- B
```
"""

PIE_MD = """# 饼图

```mermaid
pie title Share
    "X" : 1
```
"""


@patch("mddocx.converter.elements.mermaid.requests.get")
def test_mermaid_integration_state(mock_get, tmp_path):
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    doc = BaseConverter().convert(STATE_MD)
    output = tmp_path / "state.docx"
    doc.save(str(output))
    assert output.exists()
    assert mock_get.called


@patch("mddocx.converter.elements.mermaid.requests.get")
def test_mermaid_integration_class(mock_get, tmp_path):
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    doc = BaseConverter().convert(CLASS_MD)
    output = tmp_path / "class.docx"
    doc.save(str(output))
    assert output.exists()
    assert mock_get.called


@patch("mddocx.converter.elements.mermaid.requests.get")
def test_mermaid_integration_pie(mock_get, tmp_path):
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.headers = {"Content-Type": "image/png"}
    mock_resp.iter_content.return_value = [FAKE_PNG]
    mock_get.return_value = mock_resp

    doc = BaseConverter().convert(PIE_MD)
    output = tmp_path / "pie.docx"
    doc.save(str(output))
    assert output.exists()
    assert mock_get.called
