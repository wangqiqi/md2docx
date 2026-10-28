#!/usr/bin/env bash
# Smoke: install Harness Core into .opencode/ (temp dir).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CURSOR_DIR="$ROOT/.cursor"
# shellcheck source=../lib/temp-cleanup.sh
source "$CURSOR_DIR/lib/temp-cleanup.sh"
sc_temp_trap_cleanup
INSTALL_OC="$CURSOR_DIR/bin/install-adaptor-opencode.sh"
[[ -f "$INSTALL_OC" ]] || INSTALL_OC="$CURSOR_DIR/harness/core/bin/install-adaptor-opencode.sh"

sc_mktemp_dir sc-verify-install-opencode
TMP="$SC_MKTEMP_LAST"

if ! bash "$INSTALL_OC" "$TMP" --profile lite --skills-bundle core >/dev/null 2>&1; then
  echo "FAIL: install-adaptor-opencode exited non-zero" >&2
  exit 1
fi

for f in .opencode/skills .opencode/rules/core.mdc .opencode/bin/runner.sh .opencode/config/workflow.json; do
  [[ -e "$TMP/$f" ]] || { echo "FAIL: missing $f" >&2; exit 1; }
done

[[ -f "$TMP/.opencode/README.md" ]] || { echo "FAIL: missing .opencode/README.md" >&2; exit 1; }
[[ ! -e "$TMP/.opencode/hooks.json" ]] && [[ ! -d "$TMP/.opencode/hooks" ]] || {
  echo "FAIL: .opencode must not include Cursor hooks tree" >&2
  exit 1
}
[[ ! -d "$TMP/.opencode/adaptors" ]] || { echo "FAIL: .opencode must not include adaptors/" >&2; exit 1; }

core_n="$(find -L "$TMP/.opencode/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
[[ "$core_n" == "23" ]] || { echo "FAIL: .opencode skills=$core_n (expected 23 for core bundle)" >&2; exit 1; }

echo "OK: verify-install-opencode (.opencode core bundle skills=$core_n)"
