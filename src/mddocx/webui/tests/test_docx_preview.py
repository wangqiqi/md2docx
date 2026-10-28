"""WebUI DOCX layout preview (SPRINT-PREVIEW-01)."""

from io import BytesIO

import pytest
from docx import Document

from mddocx.webui.app import app
from mddocx.webui.rate_limit import reset_rate_limits


@pytest.fixture
def client():
    app.config["TESTING"] = True
    app.config["WTF_CSRF_ENABLED"] = False
    reset_rate_limits()
    with app.test_client() as test_client:
        yield test_client
    reset_rate_limits()


def test_preview_docx_renders_converted_heading(client):
    response = client.post(
        "/preview/docx",
        data={"markdown": "# Layout Title\n\nBody **bold**."},
    )
    assert response.status_code == 200
    html = response.data.decode("utf-8")
    assert "docx-preview-mode" in html
    assert "docx-layout-preview" in html
    assert "Layout Title" in html


def test_preview_docx_table_from_markdown(client):
    md = "# T\n\n| A | B |\n|---|---|\n| 1 | 2 |\n"
    response = client.post("/preview/docx", data={"markdown": md})
    assert response.status_code == 200
    html = response.data.decode("utf-8")
    assert "<table" in html or "table" in html.lower()


def test_preview_docx_empty_content(client):
    response = client.post("/preview/docx", data={"markdown": ""})
    assert response.status_code == 200
    assert "请输入Markdown内容".encode("utf-8") in response.data


def test_preview_docx_still_matches_convert_path(client):
    md = "## Sub\n\nItem one."
    preview = client.post("/preview/docx", data={"markdown": md})
    convert = client.post("/convert", data={"markdown": md})
    assert preview.status_code == 200
    assert convert.status_code == 200
    doc = Document(BytesIO(convert.data))
    assert "Sub" in "\n".join(p.text for p in doc.paragraphs)
