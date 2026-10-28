#!/usr/bin/env bash
# Example hygiene slice — extend with project-specific forbidden paths/strings.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $*"; exit 1; }

# Do not commit local agent growth paths into tracked docs
if [[ -d docs ]]; then
  if grep -rq '\.growing' docs 2>/dev/null; then
    fail 'docs/ must not reference .growing (local-only paths)'
  fi
fi

# README should mention verify entry
[[ -f README.md ]] || fail 'README.md missing'
grep -q 'verify' README.md || fail 'README.md should mention verify.sh'

echo "[✓] verify_hygiene_example"
