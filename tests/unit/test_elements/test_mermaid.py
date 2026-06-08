"""
Mermaid 转换器单元测试
"""

from unittest.mock import MagicMock, patch

import pytest
from docx import Document

from mddocx.converter.base import BaseConverter
from mddocx.converter.elements.mermaid import (
    MermaidConverter,
    build_mermaid_ink_url,
    is_supported_mermaid_diagram,
)
from mddocx.converter.security import is_allowed_mermaid_ink_url

SAMPLE_GRAPH = """graph TD
    A[开始] --> B[结束]
"""

# 最小合法 1x1 PNG
FAKE_PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"
    b"\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f"
    b"\x00\x00\x01\x01\x00\x05\x18\xd8d\x00\x00\x00\x00IEND\xaeB`\x82"
)


class TestMermaidHelpers:
    def test_supported_graph_td(self):
        assert is_supported_mermaid_diagram(SAMPLE_GRAPH) is True

    def test_supported_flowchart(self):
        assert is_supported_mermaid_diagram("flowchart LR\n  A --> B") is True

    def test_unsupported_sequence(self):
        src = "sequenceDiagram\n  A->>B: hi"
        assert is_supported_mermaid_diagram(src) is False

    def test_build_url_uses_mermaid_ink(self):
        url = build_mermaid_ink_url(SAMPLE_GRAPH)
        assert url.startswith("https://mermaid.ink/img/")
        assert "type=png" in url


class TestMermaidSecurity:
    def test_allowed_mermaid_ink_url(self):
        url = build_mermaid_ink_url(SAMPLE_GRAPH)
        assert is_allowed_mermaid_ink_url(url) is True

    def test_rejects_arbitrary_host(self):
        assert is_allowed_mermaid_ink_url("https://evil.com/img/abc") is False

    def test_rejects_non_https(self):
        assert is_allowed_mermaid_ink_url("http://mermaid.ink/img/abc") is False


class TestMermaidConverter:
    @pytest.fixture
    def converter(self):
        base = BaseConverter()
        conv = base.converters["mermaid"]
        conv.set_document(Document())
        return conv

    def _make_token(self, content: str, lang: str = "mermaid"):
        token = MagicMock()
        token.content = content
        token.info = lang
        return token

    @patch("docx.text.run.Run.add_picture")
    @patch("mddocx.converter.elements.mermaid.requests.get")
    def test_render_graph_embeds_image(self, mock_get, mock_add_picture, converter):
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.headers = {"Content-Type": "image/png"}
        mock_resp.iter_content.return_value = [FAKE_PNG]
        mock_get.return_value = mock_resp

        converter.convert(self._make_token(SAMPLE_GRAPH))

        assert mock_get.called
        mock_add_picture.assert_called_once()

    @patch("mddocx.converter.elements.mermaid.requests.get")
    def test_render_failure_fallback(self, mock_get, converter):
        mock_get.side_effect = Exception("network error")

        converter.convert(self._make_token(SAMPLE_GRAPH))

        text = "\n".join(p.text for p in converter.document.paragraphs)
        assert "渲染失败" in text
        assert "graph TD" in text

    def test_unsupported_type_fallback(self, converter):
        converter.convert(self._make_token("sequenceDiagram\n  A->>B: x"))

        text = "\n".join(p.text for p in converter.document.paragraphs)
        assert "不支持" in text
        assert "sequenceDiagram" in text


class TestMermaidRouting:
    @patch("docx.text.run.Run.add_picture")
    @patch("mddocx.converter.elements.mermaid.requests.get")
    def test_base_converter_routes_mermaid_fence(self, mock_get, mock_add_picture):
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.headers = {"Content-Type": "image/png"}
        mock_resp.iter_content.return_value = [FAKE_PNG]
        mock_get.return_value = mock_resp

        md = f"```mermaid\n{SAMPLE_GRAPH}\n```"
        doc = BaseConverter().convert(md)
        assert mock_get.called
        assert len(doc.paragraphs) >= 1
