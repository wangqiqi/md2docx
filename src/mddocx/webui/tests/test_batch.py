"""WebUI 批量转换 API 测试。"""

import io
import json
import zipfile
from io import BytesIO

import pytest
from docx import Document

from mddocx.webui.app import app
from mddocx.webui.config import get_config
from mddocx.webui.rate_limit import reset_rate_limits


@pytest.fixture
def client():
    app.config["TESTING"] = True
    app.config["WTF_CSRF_ENABLED"] = False
    reset_rate_limits()
    with app.test_client() as test_client:
        yield test_client
    reset_rate_limits()


def _read_zip(data: bytes) -> dict[str, bytes]:
    with zipfile.ZipFile(BytesIO(data)) as archive:
        return {name: archive.read(name) for name in archive.namelist()}


def _post_batch(client, files):
    return client.post(
        "/convert/batch",
        data={"files": files},
        content_type="multipart/form-data",
    )


class TestBatchConvert:
    def test_batch_converts_multiple_files(self, client):
        files = [
            (BytesIO(b"# One\n\nfirst."), "one.md"),
            (BytesIO(b"# Two\n\nsecond."), "two.md"),
        ]
        response = _post_batch(client, files)
        assert response.status_code == 200
        assert response.mimetype == "application/zip"

        contents = _read_zip(response.data)
        assert "one.docx" in contents
        assert "two.docx" in contents
        assert "batch_errors.json" not in contents

        doc = Document(BytesIO(contents["one.docx"]))
        text = "\n".join(paragraph.text for paragraph in doc.paragraphs)
        assert "One" in text

    def test_batch_partial_failure_includes_errors_json(self, client):
        files = [
            (BytesIO(b"# Good\n\nok."), "good.md"),
            (BytesIO(b""), "empty.md"),
            (BytesIO(b"binary"), "bad.exe"),
        ]
        response = _post_batch(client, files)
        assert response.status_code == 200

        contents = _read_zip(response.data)
        assert "good.docx" in contents
        assert "batch_errors.json" in contents

        payload = json.loads(contents["batch_errors.json"].decode("utf-8"))
        assert payload["summary"]["total"] == 3
        assert payload["summary"]["succeeded"] == 1
        assert payload["summary"]["failed"] == 2
        codes = {item["code"] for item in payload["errors"]}
        assert "E_CONTENT_EMPTY" in codes
        assert "E_FILE_TYPE_INVALID" in codes

    def test_batch_all_failures_still_returns_zip(self, client):
        files = [
            (BytesIO(b""), "empty.md"),
            (BytesIO(b"not-text"), "bad.exe"),
        ]
        response = _post_batch(client, files)
        assert response.status_code == 200

        contents = _read_zip(response.data)
        assert not any(name.endswith(".docx") for name in contents)
        payload = json.loads(contents["batch_errors.json"].decode("utf-8"))
        assert payload["summary"]["succeeded"] == 0
        assert payload["summary"]["failed"] == 2

    def test_batch_empty_upload_returns_400(self, client):
        response = _post_batch(client, [])
        assert response.status_code == 400
        payload = response.get_json()
        assert payload["code"] == "E_CONTENT_EMPTY"

    def test_batch_too_many_files_returns_413(self, client):
        config = get_config()
        limit = config.MAX_BATCH_FILES
        files = [(BytesIO(b"# ok"), f"file{i}.md") for i in range(limit + 1)]
        response = _post_batch(client, files)
        assert response.status_code == 413
        payload = response.get_json()
        assert payload["code"] == "E_CONTENT_TOO_LARGE"

    def test_batch_rate_limit_counts_once_per_request(self, client):
        reset_rate_limits()
        for _ in range(30):
            files = [(BytesIO(b"# ok"), "ok.md")]
            response = _post_batch(client, files)
            assert response.status_code == 200

        blocked = _post_batch(client, [(BytesIO(b"# ok"), "ok.md")])
        assert blocked.status_code == 429
        payload = blocked.get_json()
        assert payload["code"] == "E_RATE_LIMIT"
        reset_rate_limits()

    def test_batch_invalid_encoding_recorded_per_file(self, client):
        files = [
            (BytesIO(b"\xff\xfe"), "broken.md"),
            (BytesIO(b"# Fine"), "fine.md"),
        ]
        response = _post_batch(client, files)
        assert response.status_code == 200

        contents = _read_zip(response.data)
        assert "fine.docx" in contents
        payload = json.loads(contents["batch_errors.json"].decode("utf-8"))
        assert any(item["code"] == "E_INPUT_ENCODING" for item in payload["errors"])

    def test_batch_duplicate_filenames_get_unique_docx_names(self, client):
        files = [
            (BytesIO(b"# A"), "dup.md"),
            (BytesIO(b"# B"), "dup.md"),
        ]
        response = _post_batch(client, files)
        assert response.status_code == 200

        contents = _read_zip(response.data)
        docx_names = sorted(name for name in contents if name.endswith(".docx"))
        assert docx_names == ["dup.docx", "dup_2.docx"]
