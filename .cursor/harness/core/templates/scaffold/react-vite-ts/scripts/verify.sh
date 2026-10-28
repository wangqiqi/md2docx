#!/usr/bin/env bash
set -euo pipefail
# 公共骨架（scripts/lib/_*.sh 只 source；分层约定见 scripts/README.md）
# shellcheck source=lib/_frontend.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/_frontend.sh"
sc_root
sc_frontend_verify
