#!/usr/bin/env bash
# week skill — collect-week.py fixture smoke (hyphen + em-dash headings)
set -euo pipefail

# Windows cp1252 stdout 会让 python 打印中文报 UnicodeEncodeError
export PYTHONIOENCODING="${PYTHONIOENCODING:-utf-8}"
export PYTHONUTF8="${PYTHONUTF8:-1}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Git Bash / Windows 可能只有 `python`；勿硬编码 python3
PYTHON_BIN="${PYTHON_BIN:-$(command -v python3 || command -v python || true)}"
[[ -n "$PYTHON_BIN" ]] || { echo "FAIL: 需要 python3 或 python" >&2; exit 1; }
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/hyphen-repo" "$TMP/emdash-repo"
cat > "$TMP/hyphen-repo/CHANGELOG.md" <<'EOF'
## [1.0.0] - 2026-06-17

### Added

- hyphen heading
EOF
cat > "$TMP/emdash-repo/CHANGELOG.md" <<'EOF'
## [2.0.0] — 2026-06-17

### Added

- em dash heading
EOF

count="$(
  "$PYTHON_BIN" "$SCRIPT_DIR/collect-week.py" \
    --workspace "$TMP" \
    --today 2026-06-17 \
    --format json \
    | "$PYTHON_BIN" -c "import json,sys; print(len(json.load(sys.stdin)['entries']))"
)"

if [[ "$count" != "2" ]]; then
  echo "FAIL: expected 2 changelog entries, got $count" >&2
  exit 1
fi

echo "OK verify_collect_week ($count fixture entries)"
