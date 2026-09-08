#!/usr/bin/env bash
# Collect suite logs per Report Contract (scaffold bundle).
# Override suites via config/test-report.yaml · full SOP: test-report skill.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
LOG_DIR="${ROOT}/data/tmp/test-report"
mkdir -p "$LOG_DIR"

run_suite() {
  local id="$1"
  local cmd="$2"
  local log="${LOG_DIR}/${id}.log"
  echo "==> collect: $id"
  local start end
  start=$(date +%s)
  set +e
  (cd "$ROOT" && eval "$cmd") >"$log" 2>&1
  local code=$?
  set -e
  end=$(date +%s)
  {
    echo ""
    echo "exit_code=$code"
    echo "wall_sec=$((end - start))"
  } >>"$log"
  return "$code"
}

fail=0
run_suite verify_l1 "bash scripts/verify.sh --l1" || fail=1
run_suite unit "bash scripts/test.sh" || fail=1

if [[ "$fail" -ne 0 ]]; then
  echo "WARN: one or more suites failed (see ${LOG_DIR}/*.log)" >&2
  exit 1
fi
echo "OK: logs in ${LOG_DIR}"
