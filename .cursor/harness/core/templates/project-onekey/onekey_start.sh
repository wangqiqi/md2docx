#!/usr/bin/env bash
# Super Cursor · 项目根一键入口（薄模板 · install/growth-init 可 idempotent 复制）
# 契约：SPIKE-009 archive meta/*_SPIKE_onekey_bootstrap_scope.md
# 用法:
#   ./onekey_start.sh              交互菜单
#   ./onekey_start.sh test         → scripts/test.sh（存在时）
#   ./onekey_start.sh verify       → scripts/verify.sh（存在时）
#   ./onekey_start.sh help
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

usage() {
  cat <<'EOF'
onekey_start.sh — 开发循环与验收入口

  ./onekey_start.sh [test|verify|help]

菜单（无参数）:
  1  开发循环     scripts/test.sh
  2  任务验收     scripts/verify.sh
  h  帮助
  0  退出

无 scripts/ 时请先 scaffold 或自建 scripts/test.sh · scripts/verify.sh。
EOF
}

run_if_exists() {
  local rel="$1"
  if [[ -x "$ROOT/$rel" ]]; then
    exec bash "$ROOT/$rel"
  fi
  if [[ -f "$ROOT/$rel" ]]; then
    exec bash "$ROOT/$rel"
  fi
  echo "缺少 $rel — 请先 scaffold 或自建该脚本。" >&2
  return 1
}

cmd="${1:-}"
case "$cmd" in
  test) run_if_exists "scripts/test.sh" ;;
  verify) run_if_exists "scripts/verify.sh" ;;
  help|-h|--help) usage ;;
  "")
    usage
    echo
    while true; do
      read -r -p "选择 [1/2/h/0]: " choice || exit 0
      case "$choice" in
        1) run_if_exists "scripts/test.sh" || true ;;
        2) run_if_exists "scripts/verify.sh" || true ;;
        h|H) usage ;;
        0|q|Q) exit 0 ;;
        *) echo "无效选项" ;;
      esac
      echo
    done
    ;;
  *)
    echo "未知子命令: ${cmd}（试 help）" >&2
    exit 1
    ;;
esac
