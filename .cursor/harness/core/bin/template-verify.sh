#!/usr/bin/env bash
# Super Cursor 母版仓库完整验收（layout + scaffold + runner）
set -euo pipefail
PACK="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
ROOT="$(cd "$PACK/.." && pwd)"
CUR="$PACK"
cd "$ROOT"

if [[ ! -f "$CUR/bin/runner.sh" ]]; then
  echo "FAIL: run .cursor/template-verify.sh or .cursor/harness/link-cursor-ide.sh first" >&2
  exit 1
fi

echo "=== Bootstrap .growing (mother repo) ==="
bash "$CUR/bin/bootstrap-growth.sh"

echo ""
echo "=== Super Cursor template verify ==="
bash "$CUR/verify-super-cursor.sh"

echo ""
echo "=== Cursor coherence ==="
bash "$CUR/bin/cursor-coherence.sh"

echo ""
echo "=== Scaffold CLI smoke ==="
bash "$CUR/bin/scaffold.sh" list >/dev/null
bash "$CUR/bin/scaffold.sh" detect >/dev/null
bash "$CUR/bin/scaffold.sh" apply-bundle user-manual --dry-run --stack react-vite-ts >/dev/null
bash "$CUR/bin/scaffold.sh" apply-bundle test-report --dry-run --stack go-api >/dev/null

echo "  -- python 回退腿（SC_FORCE_PYTHON=1）"
SC_FORCE_PYTHON=1 bash "$CUR/bin/scaffold.sh" list >/dev/null
SC_FORCE_PYTHON=1 bash "$CUR/bin/scaffold.sh" apply-bundle user-manual --dry-run --stack react-vite-ts >/dev/null

echo ""
echo "=== Scaffold integrity ==="
bash "$CUR/bin/scaffold-integrity.sh"

echo ""
echo "=== Runner smoke ==="
bash "$CUR/bin/runner-smoke.sh"

echo ""
echo "=== Install smoke ==="
if [[ -f "$ROOT/install-super-cursor.sh" ]]; then
  bash "$CUR/bin/install-smoke.sh"
else
  echo "OK  skip install-smoke (target project — no install-super-cursor.sh)"
fi

echo ""
echo "=== Consumer smoke（目标项目端到端）==="
bash "$CUR/bin/consumer-smoke.sh"

echo ""
echo "=== Platform check ==="
bash "$CUR/bin/platform-check.sh"

echo ""
echo "All template checks passed."
