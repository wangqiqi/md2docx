#!/usr/bin/env bash
set -euo pipefail
# 公共骨架（scripts/lib/_*.sh 只 source；分层约定见 scripts/README.md）
# shellcheck source=lib/_common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/_common.sh"
sc_root
if [[ -x ./gradlew ]]; then
  ./gradlew test --no-daemon
elif command -v gradle >/dev/null 2>&1; then
  gradle test --no-daemon
else
  echo "FAIL: need ./gradlew or gradle on PATH (run: gradle wrapper)" >&2
  exit 1
fi
