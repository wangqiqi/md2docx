#!/usr/bin/env bash
# WebUI DOCX 版式预览验收（SPRINT-PREVIEW-01）
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PYTHONPATH="$ROOT/src" python3 - <<'PY'
from mddocx.webui.app import app
from mddocx.webui.rate_limit import reset_rate_limits

app.config["TESTING"] = True
app.config["WTF_CSRF_ENABLED"] = False
reset_rate_limits()
client = app.test_client()

response = client.post(
    "/preview/docx",
    data={"markdown": "# Verify Layout\n\nPreview via DOCX pipeline."},
)
assert response.status_code == 200, response.status_code
html = response.data.decode("utf-8")
assert "docx-preview-mode" in html
assert "Verify Layout" in html
print("OK: verify_webui_docx_preview passed")
PY
