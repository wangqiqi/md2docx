#!/usr/bin/env bash
# SPIKE-007 SPRINT-MOTHER-HYGIENE: facade drift audit archived.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ARCHIVE_DIR="$ROOT/.growing/archive/meta"

# 归档为本地私有（.growing/ 不入 git）→ 未引导时只跳过归档段，计数门禁仍跑
# shellcheck source=../lib/growth-archive.sh
source "$ROOT/.cursor/lib/growth-archive.sh"

count="$(find -L "$ROOT/.cursor/bin" -maxdepth 1 -name 'verify-*.sh' 2>/dev/null | wc -l | tr -d ' ')"
[[ "$count" -ge 20 ]] || { echo "FAIL: expected >=20 verify-*.sh, got $count" >&2; exit 1; }

if sc_growth_archive_available "$ARCHIVE_DIR" "verify-spike-mother-hygiene-scope"; then
  shopt -s nullglob
  files=("$ARCHIVE_DIR"/*_SPIKE_mother_hygiene_scope.md)
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "FAIL: no archive meta/*_SPIKE_mother_hygiene_scope.md" >&2
    exit 1
  fi
  latest="$(printf '%s\n' "${files[@]}" | sort | tail -1)"
  for needle in "11 道门禁" "20" "migration-catalog" "三轨" "分组" "verify-super-cursor" "template-verify"; do
    grep -qF "$needle" "$latest" || { echo "FAIL: missing '$needle' in $latest" >&2; exit 1; }
  done
  echo "OK: mother hygiene scope spike archive $latest (verify_scripts=$count)"
else
  echo "OK: mother hygiene scope gates (verify_scripts=$count)"
fi
