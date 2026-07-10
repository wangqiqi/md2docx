#!/usr/bin/env bash
# 发布门面一致性门禁：pyproject / runtime / README / tag / license / CHANGELOG
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PYTHON="${PYTHON:-python3}"

resolve_expect_tag() {
  local raw="${EXPECT_TAG:-}"
  if [[ -z "$raw" && -n "${GITHUB_REF_NAME:-}" ]]; then
    if [[ "${GITHUB_REF_NAME}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      raw="${GITHUB_REF_NAME}"
    fi
  fi
  if [[ -n "$raw" && ! "$raw" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    raw=""
  fi
  printf '%s' "$raw"
}

EXPECT_TAG="$(resolve_expect_tag)"

echo "=== release alignment verify ==="
"$PYTHON" "$ROOT/scripts/verify_release_alignment.py" "$ROOT" "$EXPECT_TAG"
echo "OK: verify_release_alignment passed"
