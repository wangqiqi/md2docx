#!/usr/bin/env bash
# Remove assembled flat runtime under .cursor/ (SSOT stays in harness/core + adaptors).
set -euo pipefail
PACK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PACK"

remove=(agents bin config docs hooks lib rules skills templates)
remove+=(AGENTS.md README.md hooks.json verify-super-cursor.sh verify-system.sh)

for name in "${remove[@]}"; do
  if [[ -e "$name" ]]; then
    rm -rf "$name"
    echo "removed .cursor/$name"
  fi
done
echo "OK: duplicate runtime trees removed — run .cursor/harness/link-cursor-ide.sh for IDE symlinks"
