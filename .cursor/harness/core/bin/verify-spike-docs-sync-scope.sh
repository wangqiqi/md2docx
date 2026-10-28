#!/usr/bin/env bash
# SPIKE-004 SPRINT-DOCS-SYNC: docs SSOT audit archived.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ARCHIVE_DIR="$ROOT/.growing/archive/meta"

# 归档为本地私有（.growing/ 不入 git）→ 未引导时 SKIP；本地有 meta/ 仍严格校验
# shellcheck source=../lib/growth-archive.sh
source "$ROOT/.cursor/lib/growth-archive.sh"
sc_growth_archive_available "$ARCHIVE_DIR" "verify-spike-docs-sync-scope" || exit 0

shopt -s nullglob
files=("$ARCHIVE_DIR"/*_SPIKE_docs_sync_scope.md)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no archive meta/*_SPIKE_docs_sync_scope.md" >&2
  exit 1
fi
latest="$(printf '%s\n' "${files[@]}" | sort | tail -1)"
for needle in "docs-layout.json" "project-docs" "07_用户手册" "generated" "verify-docs-layout" "web-fullstack"; do
  grep -qF "$needle" "$latest" || { echo "FAIL: missing '$needle' in $latest" >&2; exit 1; }
done
echo "OK: docs sync scope spike archive $latest"
