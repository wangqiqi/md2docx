#!/usr/bin/env bash
# 本地预检 ≈ GitHub Actions「Super Cursor Verify」+ VitePress（push 前必跑，避免反复烧 CI）
#
# 矩阵对应：
#   ubuntu +jq     → template-verify（默认）
#   macOS/Windows  → SC_FORCE_PYTHON=1 template-verify
#   ubuntu docs    → npm run docs:build
#   ubuntu         → link-cursor-ide + verify-secrets
set -euo pipefail

_start="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO=""
_w="$_start"
while [[ "$_w" != "/" ]]; do
  if [[ -f "$_w/install-super-cursor.sh" ]]; then
    REPO="$_w"
    break
  fi
  _w="$(dirname "$_w")"
done
[[ -n "$REPO" ]] || { echo "FAIL: repo root (install-super-cursor.sh) not found" >&2; exit 1; }
PACK="$REPO/.cursor"
cd "$REPO"

echo "=== ci-preflight (local) ==="

echo "--- secrets + IDE links (ubuntu job) ---"
bash "$PACK/harness/link-cursor-ide.sh" "$PACK" >/dev/null
bash "$PACK/bin/verify-secrets.sh"

if command -v jq >/dev/null 2>&1; then
  echo "--- template-verify (ubuntu +jq leg) ---"
  bash "$PACK/template-verify.sh"
else
  echo "SKIP template-verify (+jq leg): jq not installed"
fi

echo "--- template-verify (macOS / Windows leg: SC_FORCE_PYTHON=1) ---"
SC_FORCE_PYTHON=1 bash "$PACK/template-verify.sh"

if command -v npm >/dev/null 2>&1 && [[ -f "$REPO/package.json" ]]; then
  echo "--- VitePress (ubuntu docs leg) ---"
  npm run docs:build
else
  echo "SKIP docs:build: npm or package.json missing"
fi

echo "---"
echo "ci-preflight passed."
