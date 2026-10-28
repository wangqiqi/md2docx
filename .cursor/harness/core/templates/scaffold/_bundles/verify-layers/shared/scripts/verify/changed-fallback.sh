#!/usr/bin/env bash
# verify:changed without Node — conservative layer fallback (see README-verify-layers.md)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
VERIFY_SH="$ROOT/scripts/verify.sh"

fb="${VERIFY_CHANGED_FALLBACK:---core}"
fb="${fb#"${fb%%[![:space:]]*}"}"
fb="${fb%"${fb##*[![:space:]]}"}"

echo "[i] verify:changed: Node 不可用，跳过 changed-plan；回退: verify.sh ${fb}"
echo "    安装 Node 可启用全功能增量规划；或设置 VERIFY_CHANGED_FALLBACK=--l1 等"

case "$fb" in
  --l1|--fast|-f|"") fb_args=() ;;
  --core|--l2-core|-c) fb_args=(--core) ;;
  --l2|--standard|-s) fb_args=(--standard) ;;
  --full|--l3|-F) fb_args=(--full) ;;
  *)
    echo "FAIL: unknown VERIFY_CHANGED_FALLBACK=$fb" >&2
    exit 1
    ;;
esac

if [[ "${VERIFY_CHANGED_DRY:-}" == "1" ]]; then
  echo "[dry-run] would run: bash scripts/verify.sh ${fb_args[*]:-（无参 L1）}"
  exit 0
fi

exec bash "$VERIFY_SH" ${fb_args[@]+"${fb_args[@]}"}
