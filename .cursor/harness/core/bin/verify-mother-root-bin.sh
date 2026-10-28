#!/usr/bin/env bash
# Mother repo: root bin/ PATH wrappers (super-cursor-sync → install-super-cursor.sh).
set -euo pipefail

_walk="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT=""
while [[ "$_walk" != "/" ]]; do
  if [[ -f "$_walk/install-super-cursor.sh" ]]; then
    ROOT="$_walk"
    break
  fi
  _walk="$(dirname "$_walk")"
done
[[ -n "$ROOT" ]] || { echo "FAIL: repo root (install-super-cursor.sh) not found" >&2; exit 1; }

# shellcheck source=../lib/verify-common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/verify-common.sh" "verify-mother-root-bin"

echo "=== verify-mother-root-bin ==="

sync="$ROOT/bin/super-cursor-sync"
install="$ROOT/install-super-cursor.sh"

[[ -f "$sync" ]] && vc_ok "bin/super-cursor-sync exists" || vc_fail "missing $sync"
[[ -x "$sync" ]] && vc_ok "bin/super-cursor-sync executable" || vc_fail "bin/super-cursor-sync not executable"
grep -qF 'install-super-cursor.sh' "$sync" \
  && vc_ok "super-cursor-sync delegates to install-super-cursor.sh" \
  || vc_fail "super-cursor-sync must exec install-super-cursor.sh"
[[ -x "$install" ]] && vc_ok "install-super-cursor.sh executable" || vc_fail "install-super-cursor.sh not executable"
grep -qF 'super-cursor-sync' "$install" \
  && vc_ok "install-super-cursor.sh documents super-cursor-sync" \
  || vc_fail "install-super-cursor.sh help must mention super-cursor-sync"

vc_summary "verify-mother-root-bin passed."
