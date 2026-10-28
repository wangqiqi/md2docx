#!/usr/bin/env bash
# Install --skills-bundle full|core smoke (temp dir only).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CURSOR_DIR="$ROOT/.cursor"
# shellcheck source=../lib/temp-cleanup.sh
source "$CURSOR_DIR/lib/temp-cleanup.sh"
sc_temp_trap_cleanup
INSTALL="$ROOT/install-super-cursor.sh"
# SSOT counts + exclude list (no install)
_ssot_line="$(bash "$CURSOR_DIR/bin/verify-skill-bundles-ssot.sh" 2>/dev/null | grep '^OK  skill-bundles SSOT:' || true)"
FULL_EXPECT="$(printf '%s' "$_ssot_line" | sed -n 's/.*full=\([0-9][0-9]*\).*/\1/p')"
CORE_EXPECT="$(printf '%s' "$_ssot_line" | sed -n 's/.*core=\([0-9][0-9]*\).*/\1/p')"
[[ -n "$FULL_EXPECT" && -n "$CORE_EXPECT" ]] || {
  echo "FAIL: could not parse counts from verify-skill-bundles-ssot" >&2
  exit 1
}
sc_mktemp_dir sc-verify-skills-bundle
TMP="$SC_MKTEMP_LAST"

count_skills() {
  find -L "$1/.cursor/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' '
}

[[ -x "$INSTALL" ]] || { echo "FAIL: install not executable" >&2; exit 1; }

FULL_DIR="$TMP/full"
CORE_DIR="$TMP/core"
"$INSTALL" "$FULL_DIR" --profile lite --skills-bundle full >/dev/null
"$INSTALL" "$CORE_DIR" --profile lite --skills-bundle core >/dev/null

full_n="$(count_skills "$FULL_DIR")"
core_n="$(count_skills "$CORE_DIR")"

if [[ "$full_n" != "$FULL_EXPECT" ]]; then
  echo "FAIL: full bundle skills=$full_n (expected $FULL_EXPECT from skill-bundles.json)" >&2
  exit 1
fi
if [[ "$core_n" != "$CORE_EXPECT" ]]; then
  echo "FAIL: core bundle skills=$core_n (expected $CORE_EXPECT from skill-bundles.json)" >&2
  exit 1
fi
for s in week disk maintain ops-deploy code-stats-viz; do
  [[ -d "$CORE_DIR/.cursor/skills/$s" ]] && {
    echo "FAIL: core install still has skills/$s" >&2
    exit 1
  }
done
echo "OK: install skills-bundle full=$full_n core=$core_n"
