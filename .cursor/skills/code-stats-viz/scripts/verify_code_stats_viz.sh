#!/usr/bin/env bash
# code-stats-viz skill — smoke: --help + generate HTML in temp dir
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$SCRIPT_DIR/code_stats_viz.py"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

python3 "$PY" --help >/dev/null

# minimal git fixture
git -C "$TMP" init -q
mkdir -p "$TMP/src"
printf 'print("ok")\n' > "$TMP/src/main.py"
git -C "$TMP" add src/main.py
git -C "$TMP" -c user.email=verify@test -c user.name=verify commit -q -m "init"

OUT="$TMP/stats.html"
python3 "$PY" --dir "$TMP" --output "$OUT" --days 0 >/dev/null

if [[ ! -s "$OUT" ]]; then
  echo "FAIL: expected non-empty HTML at $OUT" >&2
  exit 1
fi

if ! grep -q 'echarts' "$OUT"; then
  echo "FAIL: HTML missing echarts reference" >&2
  exit 1
fi

echo "OK verify_code_stats_viz"
