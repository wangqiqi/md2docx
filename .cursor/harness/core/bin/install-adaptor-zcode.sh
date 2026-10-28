#!/usr/bin/env bash
# Install Harness Core into target/.zcode/ (adaptor zcode · includes: core).
# 与 dsh 的差异：安装后整树做 .cursor/ → .zcode/ 运行时路径改写；
# hooks（源自 adaptors/cursor/hooks，通用实现）合并进 .zcode/config.json。
set -euo pipefail

usage() {
  cat <<EOF
用法: $0 <目标项目根> [选项]

将母版 harness/core 写入 <目标>/.zcode/（见 adaptors/zcode/docs/layout.md），
文本做 .cursor/ → .zcode/ 路径改写，hooks 写入 .zcode/config.json。

选项:
  --dry-run              只打印将拷贝的源/目标，不写磁盘
  --skills-bundle full|core   默认 full
  --profile full|lite|rules-only   合并 workflow profile（默认 full）
  --skip-hooks           不装 hooks，不写 .zcode/config.json
  --force-agents-md      目标根已有 AGENTS.md 时也覆盖写入（默认跳过）
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
SKIP_HOOKS="false"
FORCE_AGENTS_MD="false"

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
    --skip-hooks) SKIP_HOOKS="true"; shift ;;
    --force-agents-md) FORCE_AGENTS_MD="true"; shift ;;
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
ZCODE_README="$PACK/adaptors/zcode/README.md"
ZCODE_HOOKS_MANIFEST="$PACK/adaptors/zcode/hooks.json"
HOOKS_SRC="$PACK/adaptors/cursor/hooks"

[[ -d "$CORE_SRC" ]] || { echo "错误: 缺少 $CORE_SRC" >&2; exit 1; }
[[ -f "$ZCODE_HOOKS_MANIFEST" ]] || { echo "错误: 缺少 $ZCODE_HOOKS_MANIFEST" >&2; exit 1; }

# shellcheck source=../lib/platform.sh
source "$CORE_SRC/lib/platform.sh"

DEST="$TARGET/.zcode"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "DRY RUN: core $CORE_SRC -> $DEST"
  echo "DRY RUN: README $ZCODE_README -> $DEST/README.md"
  echo "DRY RUN: hooks $HOOKS_SRC -> $DEST/hooks (skip=$SKIP_HOOKS)"
  echo "DRY RUN: manifest $ZCODE_HOOKS_MANIFEST -> $DEST/config.json hooks 键"
  echo "DRY RUN: skills-bundle=$SKILLS_BUNDLE profile=$PROFILE"
  exit 0
fi

mkdir -p "$TARGET"
mkdir -p "$DEST"

sc_copy_tree "$CORE_SRC" "$DEST" "rules/local"
[[ -f "$ZCODE_README" ]] && cp -a "$ZCODE_README" "$DEST/README.md"

# hooks：cursor adaptor 的 hooks 实现与 Cursor 无耦合（pack 探测按目录特征），随 zcode 安装
if [[ "$SKIP_HOOKS" != "true" && -d "$HOOKS_SRC" ]]; then
  sc_copy_tree "$HOOKS_SRC" "$DEST/hooks" "state/*"
  mkdir -p "$DEST/hooks/state"
  if [[ -f "$HOOKS_SRC/state/README.md" ]]; then
    cp -a "$HOOKS_SRC/state/README.md" "$DEST/hooks/state/README.md"
  fi
fi

sc_apply_skills_bundle "$TARGET" "$SKILLS_BUNDLE" ".zcode" || exit 1

if sc_has_json_tool; then
  profile_file="$DEST/config/profiles/${PROFILE}.json"
  if [[ -f "$profile_file" ]]; then
    tmp="$(mktemp)"
    sc_json_merge_files "$DEST/config/workflow.json" "$profile_file" > "$tmp"
    mv "$tmp" "$DEST/config/workflow.json"
  fi
else
  echo "WARN: jq/python 未安装，跳过 .zcode profile 合并" >&2
fi

# 运行时路径改写：安装副本自洽，不依赖 .cursor/ 存在（layout.md §路径改写）
# 不用 `sed -i`（BSD/macOS 需要 -i ''）、不用 `xargs -r`（GNU only）——临时文件中转
while IFS= read -r -d '' f; do
  tmpf="$f.sctmp"
  sed 's|\.cursor/|.zcode/|g' "$f" > "$tmpf" && mv "$tmpf" "$f"
done < <(find "$DEST" -type f \( -name '*.md' -o -name '*.mdc' -o -name '*.sh' -o -name '*.json' \
  -o -name '*.py' -o -name '*.txt' -o -name '*.yaml' -o -name '*.yml' \) -print0)

# ZCode hook 输出协议翻译：Cursor 键由 json-utils.sh 单点产出，副本内以同签名函数覆盖
#   additional_context → additionalContext（SessionStart 上下文注入）
#   followup_message   → decision=block + reason（Stop 请求续跑；ZCode 上限 3 次）
if [[ "$SKIP_HOOKS" != "true" && -f "$DEST/hooks/lib/json-utils.sh" ]]; then
  cat >> "$DEST/hooks/lib/json-utils.sh" <<'SH'

# --- adaptor:zcode 协议翻译（install-adaptor-zcode.sh 追加；覆盖上方 Cursor 风格产出） ---
json_additional_context() {
  local text="$1"
  echo "{\"additionalContext\": $(json_string "$text")}"
}
json_followup() {
  local text="$1"
  echo "{\"decision\": \"block\", \"reason\": $(json_string "$text")}"
}
SH
fi

sc_chmod_scripts "$DEST"

# ZCode hooks：manifest（ZCode 原生 schema）合并进 .zcode/config.json 的 hooks 键
if [[ "$SKIP_HOOKS" != "true" ]]; then
  CFG="$DEST/config.json"
  if py="$(sc_python)"; then
    "$py" - "$ZCODE_HOOKS_MANIFEST" "$CFG" <<'PY'
import json, sys

man = json.load(open(sys.argv[1], encoding="utf-8"))
hooks = man.get("hooks")
if not hooks:
    sys.exit("manifest 缺少 hooks 键")
try:
    cfg = json.load(open(sys.argv[2], encoding="utf-8"))
except FileNotFoundError:
    cfg = {}
cfg["hooks"] = hooks
with open(sys.argv[2], "w", encoding="utf-8") as f:
    json.dump(cfg, f, ensure_ascii=False, indent=2)
    f.write("\n")
PY
  else
    echo "WARN: python 未安装，跳过 .zcode/config.json hooks 写入" >&2
  fi
fi

# 根 AGENTS.md（ZCode workspace 指令文件）：双工具并存薄入口；已存在则不覆盖
AGENTS_MD="$TARGET/AGENTS.md"
if [[ ! -f "$AGENTS_MD" || "$FORCE_AGENTS_MD" == "true" ]]; then
  cat > "$AGENTS_MD" <<'MD'
# AGENTS.md

本仓库装有 **Super Cursor harness**，双工具并存、互不引用：**Cursor → `.cursor/`** · **ZCode → `.zcode/`**（内容同源）。

- 改通用 SOP 先改母版 `.cursor/harness/core`，再对每个工具根分别重装；勿直接单边手改副本。
- 通用索引：所用工具根下 `AGENTS.md`（agent↔skill↔rules 地图）与 `rules/`（`core.mdc` + `workflow.mdc` 常驻，其余按需读）。
- 产出与项目特化一律进 `.growing/`（git 忽略）：plan · archive · learn · rules/local。
- 验收入口：`bash <工具根>/bin/runner.sh task-verify`。
MD
  echo "OK: 根 AGENTS.md 已写入（双工具薄入口）"
else
  echo "WARN: $AGENTS_MD 已存在，跳过（合并要点见 adaptors/zcode/docs/layout.md）"
fi

mkdir -p "$TARGET/.growing/archive" "$TARGET/.growing/rules/local" 2>/dev/null || true

echo "OK: Harness Core 已安装 → $DEST"
