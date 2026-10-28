#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"
[[ -f design-tokens.json ]] || { echo "FAIL: design-tokens.json"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "SKIP: node 不可用（该 slice 需要 Node；非 Node 栈可忽略）"; exit 0; }
node scripts/color-audit.mjs
echo "[✓] verify_design_tokens"
