#!/usr/bin/env bash
# manifest.tsv 机械完整性 + 可选 audit-dedup
set -euo pipefail
source "$(dirname "$0")/../../lib/load.sh"
sc_cd_root

MANIFEST="scripts/verify/manifest.tsv"
[[ -f "$MANIFEST" ]] || { echo "FAIL: missing $MANIFEST"; exit 1; }

ROWS=()
while IFS= read -r line; do
  ROWS+=("$line")
done < <(awk -F'\t' 'NF>=3 && $0 !~ /^#/ { print }' "$MANIFEST")
[[ ${#ROWS[@]} -gt 0 ]] || { echo "FAIL: manifest has no data rows"; exit 1; }

for row in "${ROWS[@]}"; do
  IFS=$'\t' read -r tier type target <<< "$row"
  case "$type" in
    bash)
      [[ -f "scripts/verify/$target" ]] || { echo "FAIL: missing bash slice scripts/verify/$target"; exit 1; }
      ;;
    command) ;;
    bundle-commands)
      f="scripts/verify/$target"
      [[ -f "$f" ]] || f="$target"
      [[ -f "$f" ]] || { echo "FAIL: missing bundle $target"; exit 1; }
      if ! grep -v '^[[:space:]]*#' "$f" | grep -q .; then
        echo "FAIL: empty bundle-commands $target"
        exit 1
      fi
      ;;
    *)
      echo "FAIL: unknown type=$type in row: $row"
      exit 1
      ;;
  esac
done

if command -v node >/dev/null 2>&1 && [[ -f scripts/verify/audit-dedup.config.json ]]; then
  node scripts/verify/audit-dedup.mjs
else
  echo "[i] skip audit-dedup (add scripts/verify/audit-dedup.config.json to enable)"
fi

sc_pass "verify_manifest_integrity"
