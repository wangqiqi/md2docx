#!/usr/bin/env bash
# pip-audit 门禁：与 CI quality job 同序（干净 venv · 升级 setuptools · -e .[dev,mcp]）
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PYTHON="${PYTHON:-python3}"
VENV="$(mktemp -d "${TMPDIR:-/tmp}/mddocx-pip-audit.XXXXXX")"
cleanup() { rm -rf "$VENV"; }
trap cleanup EXIT

echo "=== pip-audit (ephemeral venv) ==="
"$PYTHON" -m venv "$VENV"
# shellcheck disable=SC1091
source "$VENV/bin/activate"
python -m pip install -q -U pip setuptools wheel
pip install -q -e ".[dev,mcp]" pip-audit
pip-audit
echo "OK: check_pip_audit passed"
