#!/usr/bin/env bash
# validate-commit-msg.sh — Conventional Commits check (optional, manual or CI)
set -euo pipefail

msg="${1:-}"
if [[ -z "$msg" ]]; then
  echo "用法: $0 \"commit message\"" >&2
  exit 2
fi

pattern='^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\([a-zA-Z0-9._-]+\))?: .{1,100}$'

if echo "$msg" | grep -qE "$pattern"; then
  echo "OK: conventional commit"
  exit 0
fi

echo "FAIL: expected type(scope): summary" >&2
echo "types: feat fix docs style refactor test chore perf ci build revert" >&2
exit 1
