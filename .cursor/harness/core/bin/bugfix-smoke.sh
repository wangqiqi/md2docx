#!/usr/bin/env bash
# Minimal smoke script for Super Cursor bugfix workflow (TASK-039).
set -euo pipefail

count_chars() {
  local s="$1"
  echo "${#s}"
}

result="$(count_chars "ok")"
[[ "$result" == "2" ]] || { echo "FAIL: expected 2, got $result"; exit 1; }
echo "bugfix-smoke passed"
