#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/load.sh"
sc_cd_root

command -v node >/dev/null 2>&1 || { echo "SKIP: node 不可用"; exit 0; }
[[ -f scripts/verify/audit-dedup.config.json ]] || { echo "SKIP: no audit-dedup.config.json"; exit 0; }
node scripts/verify/audit-dedup.mjs
sc_pass "verify_test_dedup"
