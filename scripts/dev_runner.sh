#!/usr/bin/env bash
# 兼容包装 → .cursor/bin/dev_runner.sh
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$ROOT/.cursor/bin/dev_runner.sh" "$@"
