#!/usr/bin/env bash
# Super Cursor 母版仓库完整验收（layout + scaffold + runner）
set -euo pipefail
CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"
cd "$ROOT"

echo "=== Bootstrap .cursorGrowth (mother repo) ==="
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

echo ""
echo "=== Scaffold integrity ==="
bash "$CUR/bin/scaffold-integrity.sh"

echo ""
echo "=== Runner smoke ==="
bash "$CUR/bin/runner-smoke.sh"

echo ""
echo "=== Install smoke ==="
bash "$CUR/bin/install-smoke.sh"

echo ""
echo "=== Platform check ==="
bash "$CUR/bin/platform-check.sh"

echo ""
echo "All template checks passed."
