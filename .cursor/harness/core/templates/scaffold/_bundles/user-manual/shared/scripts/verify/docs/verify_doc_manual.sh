#!/usr/bin/env bash
# L1 mechanical checks for user-guide manual (scaffold bundle).
# Set SKIP_MANUAL_ASSETS=1 until first walkthrough regen.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
DOC="${ROOT}/docs/user-guide.md"
CONTRACT="${ROOT}/config/manual.yaml"
ASSETS="${ROOT}/docs/assets/user-guide"
fail() { echo "FAIL: $*" >&2; exit 1; }

echo "==> manual L1 · contract + doc"
[[ -f "$CONTRACT" ]] || fail "missing config/manual.yaml"
[[ -f "$DOC" ]] || fail "missing docs/user-guide.md"
grep -q 'assets/user-guide' "$DOC" || fail 'doc missing assets/user-guide embed'

if [[ "${SKIP_MANUAL_ASSETS:-1}" == "1" ]]; then
  echo "SKIP: PNG assets (SKIP_MANUAL_ASSETS=1; unset after first regen)"
else
  echo "==> manual L1 · PNG assets"
  read -r -a KEYS <<< "${MANUAL_SHOT_KEYS:-01_home.png}"
  for k in "${KEYS[@]}"; do
    [[ -f "${ASSETS}/${k}" ]] || fail "missing ${ASSETS}/${k}"
    grep -q "$k" "$DOC" || fail "doc missing reference to $k"
  done
fi

echo "OK: verify_doc_manual"
