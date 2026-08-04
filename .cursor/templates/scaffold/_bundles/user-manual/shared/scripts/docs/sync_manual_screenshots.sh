#!/usr/bin/env bash
# Copy manual walkthrough PNGs into docs/assets (see config/manual.yaml).
#
# Usage:
#   MANUAL_WALKTHROUGH_ENABLED=1 npm run test:e2e:manual
#   bash scripts/docs/sync_manual_screenshots.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="${MANUAL_INTERMEDIATE_DIR:-${ROOT}/test-results/manual-walkthrough}"
DST="${ROOT}/docs/assets/user-guide"

# Override: MANUAL_SHOT_KEYS="01_home.png 02_detail.png"
read -r -a KEYS <<< "${MANUAL_SHOT_KEYS:-01_home.png}"

[[ -d "$SRC" ]] || {
  echo "FAIL: screenshot source missing: $SRC (run walkthrough first)" >&2
  exit 1
}
mkdir -p "$DST"

for k in "${KEYS[@]}"; do
  base="${k%.png}"
  [[ -f "${SRC}/${base}.png" ]] || {
    echo "FAIL: missing ${SRC}/${base}.png" >&2
    exit 1
  }
  cp "${SRC}/${base}.png" "${DST}/${base}.png"
done

echo "OK: synced ${#KEYS[@]} screenshot(s) → docs/assets/user-guide/"
