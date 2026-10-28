#!/usr/bin/env bash
# 模板转换验收：页眉保留 + 正文写入
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export MD2DOCX_TEMPLATE="$ROOT/tests/samples/templates/minimal_company.docx"
export MD2DOCX_TMP_MD="$(mktemp --suffix=.md)"
export MD2DOCX_TMP_OUT="$(mktemp --suffix=.docx)"
cleanup() { rm -f "$MD2DOCX_TMP_MD" "$MD2DOCX_TMP_OUT"; }
trap cleanup EXIT

cat >"$MD2DOCX_TMP_MD" <<'EOF'
# Template verify

Converted body line.
EOF

PYTHONPATH="$ROOT/src" python3 - <<'PY'
import os
from pathlib import Path
from docx import Document
from mddocx.converter.base import BaseConverter

template = Path(os.environ["MD2DOCX_TEMPLATE"])
md_path = Path(os.environ["MD2DOCX_TMP_MD"])
out_path = Path(os.environ["MD2DOCX_TMP_OUT"])
doc = BaseConverter().convert_file(md_path, template_path=str(template))
doc.save(out_path)
saved = Document(str(out_path))
header = saved.sections[0].header.paragraphs[0].text
assert "MD2DOCX-TEMPLATE-HEADER" in header, header
body = "\n".join(p.text for p in saved.paragraphs)
assert "Template verify" in body, body
assert "Converted body line" in body, body
print("OK: verify_template_convert passed")
PY
