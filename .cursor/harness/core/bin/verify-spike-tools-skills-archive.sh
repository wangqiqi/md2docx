#!/usr/bin/env bash
# SPIKE-001 SPRINT-MOTHER-LEAN: tools skills optional bundle decision archived.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ARCHIVE_DIR="$ROOT/.growing/archive/meta"

# 归档为本地私有（.growing/ 不入 git）→ 未引导时 SKIP；本地有 meta/ 仍严格校验
# shellcheck source=../lib/growth-archive.sh
source "$ROOT/.cursor/lib/growth-archive.sh"
sc_growth_archive_available "$ARCHIVE_DIR" "verify-spike-tools-skills-archive" || exit 0

shopt -s nullglob
files=("$ARCHIVE_DIR"/*_SPIKE_tools_skills_bundle.md)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no archive meta/*_SPIKE_tools_skills_bundle.md" >&2
  exit 1
fi
latest="$(printf '%s\n' "${files[@]}" | sort | tail -1)"
for needle in "week" "disk" "maintain" "ops-deploy" "code-stats-viz" "In · Defer" "Defer" "install profile"; do
  grep -q "$needle" "$latest" || { echo "FAIL: missing '$needle' in $latest" >&2; exit 1; }
done
echo "OK: tools skills bundle spike archive $latest"
