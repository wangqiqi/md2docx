#!/usr/bin/env bash
set -euo pipefail
# 公共骨架（scripts/lib/_*.sh 只 source；分层约定见 scripts/README.md）
# shellcheck source=lib/_common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/_common.sh"
sc_root
go test ./internal/... ./tests/...
