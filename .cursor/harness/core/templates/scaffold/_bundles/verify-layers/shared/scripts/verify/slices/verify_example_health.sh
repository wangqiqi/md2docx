#!/usr/bin/env bash
# Example L2 slice — copy pattern for new verify_<feature>.sh scripts.
set -euo pipefail
source "$(dirname "$0")/../../lib/load.sh"
sc_cd_root

[[ -f README.md ]] || { echo "FAIL: README.md missing"; exit 1; }
[[ -f scripts/verify.sh ]] || { echo "FAIL: scripts/verify.sh missing"; exit 1; }
[[ -f scripts/lib/verify-layers.sh ]] || { echo "FAIL: scripts/lib/verify-layers.sh missing"; exit 1; }

sc_pass "verify_example_health"
