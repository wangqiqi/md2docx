#!/usr/bin/env bash
# 封面 + front matter 验收（SPRINT-STYLE-02）
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SAMPLE="$ROOT/tests/samples/style/cover_front_matter.md"
TEMPLATE="$ROOT/tests/samples/templates/minimal_company.docx"
export MD2DOCX_SAMPLE="$SAMPLE"
export MD2DOCX_TEMPLATE="$TEMPLATE"
export MD2DOCX_TMP_OUT="$(mktemp --suffix=.docx)"
cleanup() { rm -f "$MD2DOCX_TMP_OUT"; }
trap cleanup EXIT

PYTHONPATH="$ROOT/src" python3 - <<'PY'
import os
from pathlib import Path
from docx import Document
from mddocx.converter.base import BaseConverter

sample = Path(os.environ["MD2DOCX_SAMPLE"])
template = Path(os.environ["MD2DOCX_TEMPLATE"])
out_path = Path(os.environ["MD2DOCX_TMP_OUT"])

conv = BaseConverter()
doc = conv.convert_file(sample, template_path=str(template))
doc.save(out_path)
saved = Document(str(out_path))

header = saved.sections[0].header.paragraphs[0].text
assert "MD2DOCX-TEMPLATE-HEADER" in header, header
assert saved.paragraphs[0].text == "Cover Verify Doc", saved.paragraphs[0].text
body = "\n".join(p.text for p in saved.paragraphs)
assert "First Section" in body
assert "Verification paragraph" in body
print("OK: verify_cover_convert passed")
PY
