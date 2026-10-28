#!/usr/bin/env bash
# Install Harness Core into target/.dsh/ (adaptor dsh · includes: core).
set -euo pipefail

usage() {
  cat <<EOF
用法: $0 <目标项目根> [选项]

将母版 harness/core 写入 <目标>/.dsh/（见 adaptors/dsh/docs/layout.md）。

选项:
  --dry-run              只打印将拷贝的源/目标，不写磁盘
  --skills-bundle full|core   默认 full
  --profile full|lite|rules-only   合并 workflow profile（默认 full）
  -h, --help

环境: SUPER_CURSOR_HOME / CURSOR_AI_HOME（母版仓库根）
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

TARGET=""
DRY_RUN="false"
PROFILE="full"
SKILLS_BUNDLE="full"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dry-run) DRY_RUN="true"; shift ;;
    --profile)
      [[ $# -ge 2 ]] || { echo "错误: --profile 需要取值" >&2; exit 1; }
      PROFILE="$2"
      shift 2
      ;;
    --skills-bundle)
      [[ $# -ge 2 ]] || { echo "错误: --skills-bundle 需要取值" >&2; exit 1; }
      SKILLS_BUNDLE="$2"
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

[[ -n "$TARGET" ]] || { echo "错误: 需要目标项目路径" >&2; usage; exit 1; }

case "$PROFILE" in full|lite|rules-only) ;; *)
  echo "错误: 无效 profile: $PROFILE" >&2; exit 1 ;;
esac
case "$SKILLS_BUNDLE" in full|core) ;; *)
  echo "错误: 无效 skills-bundle: $SKILLS_BUNDLE" >&2; exit 1 ;;
esac

SOURCE="$(resolve_source_root)" || exit 1
PACK="$SOURCE/.cursor"
CORE_SRC="$PACK/harness/core"
DSH_README="$PACK/adaptors/dsh/README.md"

[[ -d "$CORE_SRC" ]] || { echo "错误: 缺少 $CORE_SRC" >&2; exit 1; }

# shellcheck source=../lib/platform.sh
source "$CORE_SRC/lib/platform.sh"

DEST="$TARGET/.dsh"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "DRY RUN: core $CORE_SRC -> $DEST"
  echo "DRY RUN: README $DSH_README -> $DEST/README.md"
  echo "DRY RUN: skills-bundle=$SKILLS_BUNDLE profile=$PROFILE"
  exit 0
fi

mkdir -p "$TARGET"
if [[ -d "$DEST" ]]; then
  :
else
  mkdir -p "$DEST"
fi

sc_copy_tree "$CORE_SRC" "$DEST" "rules/local"
if [[ -f "$DSH_README" ]]; then
  cp -a "$DSH_README" "$DEST/README.md"
fi

sc_apply_skills_bundle "$TARGET" "$SKILLS_BUNDLE" ".dsh" || exit 1

if sc_has_json_tool; then
  profile_file="$DEST/config/profiles/${PROFILE}.json"
  if [[ -f "$profile_file" ]]; then
    tmp="$(mktemp)"
    sc_json_merge_files "$DEST/config/workflow.json" "$profile_file" > "$tmp"
    mv "$tmp" "$DEST/config/workflow.json"
  fi
else
  echo "WARN: jq/python 未安装，跳过 .dsh profile 合并" >&2
fi

sc_chmod_scripts "$DEST"

mkdir -p "$TARGET/.growing/archive" "$TARGET/.growing/rules/local" 2>/dev/null || true

echo "OK: Harness Core 已安装 → $DEST"
