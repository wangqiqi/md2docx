#!/usr/bin/env bash
# Smoke: install Harness Core into .dsh/ (temp dir).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CURSOR_DIR="$ROOT/.cursor"
# shellcheck source=../lib/temp-cleanup.sh
source "$CURSOR_DIR/lib/temp-cleanup.sh"
sc_temp_trap_cleanup
INSTALL_DSH="$CURSOR_DIR/bin/install-adaptor-dsh.sh"
[[ -f "$INSTALL_DSH" ]] || INSTALL_DSH="$CURSOR_DIR/harness/core/bin/install-adaptor-dsh.sh"

sc_mktemp_dir sc-verify-install-dsh
TMP="$SC_MKTEMP_LAST"

if ! bash "$INSTALL_DSH" "$TMP" --profile lite --skills-bundle core >/dev/null 2>&1; then
  echo "FAIL: install-adaptor-dsh exited non-zero" >&2
  exit 1
fi

for f in .dsh/skills .dsh/rules/core.mdc .dsh/bin/runner.sh .dsh/config/workflow.json; do
  [[ -e "$TMP/$f" ]] || { echo "FAIL: missing $f" >&2; exit 1; }
done

[[ -f "$TMP/.dsh/README.md" ]] || { echo "FAIL: missing .dsh/README.md" >&2; exit 1; }
[[ ! -e "$TMP/.dsh/hooks.json" ]] && [[ ! -d "$TMP/.dsh/hooks" ]] || {
  echo "FAIL: .dsh must not include Cursor hooks tree" >&2
  exit 1
}
[[ ! -d "$TMP/.dsh/adaptors" ]] || { echo "FAIL: .dsh must not include adaptors/" >&2; exit 1; }

core_n="$(find -L "$TMP/.dsh/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
[[ "$core_n" == "23" ]] || { echo "FAIL: .dsh skills=$core_n (expected 23 for core bundle)" >&2; exit 1; }

echo "OK: verify-install-dsh (.dsh core bundle skills=$core_n)"
