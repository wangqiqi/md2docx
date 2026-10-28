#!/usr/bin/env bash
# WebUI 模板上传转换验收（SPRINT-STYLE-03）
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export MD2DOCX_ROOT="$ROOT"
PYTHONPATH="$ROOT/src" python3 - <<'PY'
import os
from io import BytesIO
from pathlib import Path

from docx import Document

from mddocx.webui.app import app
from mddocx.webui.rate_limit import reset_rate_limits

root = Path(os.environ["MD2DOCX_ROOT"])
template = root / "tests/samples/templates/minimal_company.docx"
assert template.is_file(), template

app.config["TESTING"] = True
app.config["WTF_CSRF_ENABLED"] = False
reset_rate_limits()
client = app.test_client()

with template.open("rb") as handle:
    response = client.post(
        "/convert",
        data={
            "markdown": "# Verify WebUI\n\nTemplate header check.",
            "template": (handle, "company.docx"),
        },
        content_type="multipart/form-data",
    )
assert response.status_code == 200, response.status_code
doc = Document(BytesIO(response.data))
header = doc.sections[0].header.paragraphs[0].text
assert "MD2DOCX-TEMPLATE-HEADER" in header, header
assert "Verify WebUI" in "\n".join(p.text for p in doc.paragraphs)
print("OK: verify_webui_template passed")
PY
