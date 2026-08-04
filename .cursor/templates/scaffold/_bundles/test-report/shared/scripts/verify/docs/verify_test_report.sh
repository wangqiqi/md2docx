#!/usr/bin/env bash
# L1 mechanical checks for test report doc (scaffold bundle).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
DOC="${ROOT}/docs/test-report.md"
CONTRACT="${ROOT}/config/test-report.yaml"
fail() { echo "FAIL: $*" >&2; exit 1; }

echo "==> test-report L1 · contract + doc"
[[ -f "$CONTRACT" ]] || fail "missing config/test-report.yaml"
[[ -f "$DOC" ]] || fail "missing docs/test-report.md"
grep -q 'benchmark' "$DOC" || fail 'doc missing benchmark anchor'
grep -q 'verify.sh' "$DOC" || fail 'doc missing verify.sh reference'
grep -q 'collect_test_report' "$DOC" || fail 'doc missing collect_test_report reference'

echo "OK: verify_test_report"
