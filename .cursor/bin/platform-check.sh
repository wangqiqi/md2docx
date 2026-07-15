#!/usr/bin/env bash
# Environment probe — Linux · macOS · Git Bash
set -euo pipefail

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/platform.sh
source "$CURSOR_DIR/lib/platform.sh"

WARN=0
FAIL=0

probe() {
  local name="$1" required="$2" note="${3:-}"
  if command -v "$name" >/dev/null 2>&1; then
    echo "OK   $name"
    return 0
  fi
  if [[ "$required" == "required" ]]; then
    echo "FAIL $name — $note"
    FAIL=$((FAIL + 1))
  else
    echo "MISS $name — $note"
    WARN=$((WARN + 1))
  fi
}

echo "=== Super Cursor platform check ==="
probe bash required "shell for hooks / runner / scaffold"
probe git optional "needed for tag / release workflow"

if command -v jq >/dev/null 2>&1; then
  echo "OK   jq"
elif py="$(sc_python 2>/dev/null || true)" && [[ -n "$py" ]]; then
  echo "OK   $py (jq fallback for JSON)"
else
  echo "FAIL jq/python — install jq or Python for JSON CLI"
  FAIL=$((FAIL + 1))
fi

probe rsync optional "install/hooks use cp -a when missing"
probe column optional "scaffold list uses awk when missing"

echo "--- smoke ---"
ts="$(iso8601_now)"
[[ -n "$ts" ]] && echo "OK   iso8601_now=$ts" || { echo "FAIL iso8601_now"; FAIL=$((FAIL + 1)); }

if sc_has_json_tool; then
  pf="$(json_cfg "$CURSOR_DIR/config/workflow.json" plan_file __missing__)"
  if [[ "$pf" == ".cursorGrowth/plan.md" ]]; then
    echo "OK   json_cfg plan_file=$pf"
  else
    echo "FAIL json_cfg plan_file=$pf (expected .cursorGrowth/plan.md)"
    FAIL=$((FAIL + 1))
  fi
  he="$(json_cfg "$CURSOR_DIR/config/workflow.json" workflow.enabled __missing__)"
  if [[ "$he" == "true" ]]; then
    echo "OK   json_cfg workflow.enabled=$he"
  else
    echo "FAIL json_cfg workflow.enabled=$he (expected true)"
    FAIL=$((FAIL + 1))
  fi
fi

echo "---"
if [[ "$FAIL" -gt 0 ]]; then
  echo "$FAIL required gap(s). See .cursor/docs/platforms.md"
  exit 1
fi
[[ "$WARN" -gt 0 ]] && echo "$WARN optional gap(s) — OK to proceed with fallbacks."
echo "Platform OK."
exit 0
