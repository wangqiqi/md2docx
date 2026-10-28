#!/usr/bin/env bash
# Install core_rules_export → .kiro/ or .trae/ (Kiro · Trae adaptors).
set -euo pipefail

usage() {
  cat <<EOF
用法: $0 --adaptor kiro|trae <目标项目根> [选项]

将 harness/core/rules 导出到 .kiro/ 或 .trae/（见 docs/reference/core-rules-export.md）。

选项:
  --dry-run    只打印源/目标
  -h, --help

环境: SUPER_CURSOR_HOME / CURSOR_AI_HOME
EOF
}

resolve_source_root() {
  local candidate _walk
  for candidate in "${SUPER_CURSOR_HOME:-}" "${CURSOR_AI_HOME:-}"; do
    if [[ -n "$candidate" && -d "$candidate/.cursor/harness/core" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  _walk="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  while [[ "$_walk" != "/" ]]; do
    if [[ -d "$_walk/harness/core" ]]; then
      echo "$(cd "$_walk/.." && pwd)"
      return 0
    fi
    _walk="$(dirname "$_walk")"
  done
  echo "错误: 未找到母版 .cursor/harness/core" >&2
  return 1
}

write_rules_index() {
  local dest_root="$1"
  local rules_dir="$dest_root/rules"
  local out="$dest_root/RULES.md"
  {
    echo "# Super Cursor rules index"
    echo ""
    echo "自动生成 · 源：\`harness/core/rules\` · token：\`core_rules_export\`"
    echo ""
    if [[ -d "$rules_dir" ]]; then
      find "$rules_dir" -type f -name '*.mdc' | sort | while read -r f; do
        echo "- \`${f#"$dest_root"/}\`"
      done
    fi
  } > "$out"
}

ADAPTOR=""
TARGET=""
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dry-run) DRY_RUN="true"; shift ;;
    --adaptor)
      [[ $# -ge 2 ]] || { echo "错误: --adaptor 需要 kiro 或 trae" >&2; exit 1; }
      ADAPTOR="$2"
      shift 2
      ;;
    -*)
      echo "错误: 未知选项 $1" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$1"
      else
        echo "错误: 多余参数 $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

[[ -n "$ADAPTOR" ]] || { echo "错误: 需要 --adaptor kiro|trae" >&2; usage; exit 1; }
[[ -n "$TARGET" ]] || { echo "错误: 需要目标项目路径" >&2; usage; exit 1; }

case "$ADAPTOR" in
  kiro) INSTALL_DIR=".kiro" ;;
  trae) INSTALL_DIR=".trae" ;;
  *)
    echo "错误: 无效 adaptor: ${ADAPTOR}（仅 kiro · trae）" >&2
    exit 1
    ;;
esac

SOURCE="$(resolve_source_root)" || exit 1
PACK="$SOURCE/.cursor"
CORE_SRC="$PACK/harness/core"
RULES_SRC="$CORE_SRC/rules"
ADAPTOR_README="$PACK/adaptors/$ADAPTOR/README.md"
DEST="$TARGET/$INSTALL_DIR"

[[ -d "$RULES_SRC" ]] || { echo "错误: 缺少 $RULES_SRC" >&2; exit 1; }

if [[ "$DRY_RUN" == "true" ]]; then
  echo "DRY RUN: rules $RULES_SRC -> $DEST/rules (exclude rules/local)"
  echo "DRY RUN: README $ADAPTOR_README -> $DEST/README.md"
  echo "DRY RUN: generate $DEST/RULES.md"
  exit 0
fi

# shellcheck source=../lib/platform.sh
source "$CORE_SRC/lib/platform.sh"

mkdir -p "$TARGET" "$DEST"
sc_copy_tree "$RULES_SRC" "$DEST/rules" "local"
[[ -f "$ADAPTOR_README" ]] && cp -a "$ADAPTOR_README" "$DEST/README.md"
write_rules_index "$DEST"

mkdir -p "$TARGET/.growing/archive" "$TARGET/.growing/rules/local" 2>/dev/null || true

echo "OK: core_rules_export 已安装 → $DEST ($ADAPTOR)"
