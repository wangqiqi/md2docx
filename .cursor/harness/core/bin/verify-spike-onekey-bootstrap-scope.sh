#!/usr/bin/env bash
# SPIKE-009 SPRINT-INSTALL-ONEKEY: onekey bootstrap scope archived.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ARCHIVE_DIR="$ROOT/.growing/archive/meta"

# shellcheck source=../lib/growth-archive.sh
source "$ROOT/.cursor/lib/growth-archive.sh"
sc_growth_archive_available "$ARCHIVE_DIR" "verify-spike-onekey-bootstrap-scope" || exit 0

shopt -s nullglob
files=("$ARCHIVE_DIR"/*_SPIKE_onekey_bootstrap_scope.md)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no archive meta/*_SPIKE_onekey_bootstrap_scope.md" >&2
  exit 1
fi
latest="$(printf '%s\n' "${files[@]}" | sort | tail -1)"
for needle in \
  "onekey_start.sh" \
  "project-onekey" \
  "growth-init" \
  "onekey_bootstrap" \
  "scripts/test.sh" \
  "scripts/verify.sh" \
  "idempotent" \
  "install-super-cursor" \
  "scaffold"; do
  grep -qF "$needle" "$latest" || { echo "FAIL: missing '$needle' in $latest" >&2; exit 1; }
done
echo "OK: onekey bootstrap scope spike archive $latest"
