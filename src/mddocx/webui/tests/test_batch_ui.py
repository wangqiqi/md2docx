"""WebUI 批量选择、进度与结果面板测试。"""

import json
from io import BytesIO
from urllib.parse import unquote

import pytest

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


def test_index_exposes_batch_controls(client):
    response = client.get("/")
    html = response.get_data(as_text=True)

    assert response.status_code == 200
    assert 'id="batch-file-input"' in html
    assert 'multiple' in html
    assert 'id="batch-convert-button"' in html
    assert 'id="batch-progress-bar"' in html
    assert 'id="batch-progress-count"' in html
    assert 'id="batch-result"' in html


def test_batch_javascript_uses_fetch_progress_and_safe_result_rendering(client):
    response = client.get("/static/js/app.js")
    script = response.get_data(as_text=True)

    assert response.status_code == 200
    assert "fetch('/convert/batch'" in script
    assert "new FormData()" in script
    assert "progressCount.textContent" in script
    assert "downloadBatchZip(blob)" in script
    assert "error.filename" in script
    assert "error.code" in script
    assert "item.textContent" in script


def test_batch_styles_include_progress_and_error_states(client):
    response = client.get("/static/css/styles.css")
    stylesheet = response.get_data(as_text=True)

    assert response.status_code == 200
    assert ".batch-panel" in stylesheet
    assert ".batch-progress progress" in stylesheet
    assert ".batch-error-item" in stylesheet


def test_batch_response_exposes_summary_and_per_file_errors(client):
    response = client.post(
        "/convert/batch",
        data={
            "files": [
                (BytesIO(b"# Good"), "good.md"),
                (BytesIO(b""), "empty.md"),
            ]
        },
        content_type="multipart/form-data",
    )

    assert response.status_code == 200
    summary = json.loads(unquote(response.headers["X-Batch-Summary"]))
    errors = json.loads(unquote(response.headers["X-Batch-Errors"]))
    assert summary == {"total": 2, "succeeded": 1, "failed": 1}
    assert errors == [
        {
            "filename": "empty.md",
            "code": "E_CONTENT_EMPTY",
            "message": "请输入 Markdown 内容或上传文件",
        }
    ]
