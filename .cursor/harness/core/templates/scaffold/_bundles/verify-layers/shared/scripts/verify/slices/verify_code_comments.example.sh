#!/usr/bin/env bash
# Example only — copy to verify_code_comments.sh and tune patterns for your repo.
# Guards: no sprint/task IDs in application source (traceability → CHANGELOG · archive).
set -euo pipefail
source "$(dirname "$0")/../../lib/load.sh"
sc_cd_root

# Directories to scan (adjust)
SCAN_DIRS=(src app lib server client)
# File extensions (bash 3+: space-separated globs via find)
PATTERN='(TASK-|SPRINT-|SPIKE-|REV-|DOC-)[0-9A-Z_-]+'

found=0
for dir in "${SCAN_DIRS[@]}"; do
  [[ -d "$dir" ]] || continue
  while IFS= read -r -d '' f; do
    if grep -qE "$PATTERN" "$f" 2>/dev/null; then
      echo "FAIL: traceability ID in app code: $f"
      grep -nE "$PATTERN" "$f" | head -3
      found=1
    fi
  done < <(find "$dir" -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.css' \) -print0 2>/dev/null)
done

[[ "$found" -eq 0 ]] || exit 1
sc_pass "verify_code_comments"
