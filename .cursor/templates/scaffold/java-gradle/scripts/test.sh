#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
if [[ ! -x ./gradlew ]]; then
  echo "FAIL: ./gradlew missing" >&2
  exit 1
fi
./gradlew test
