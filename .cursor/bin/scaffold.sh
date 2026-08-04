#!/usr/bin/env bash
# Scaffold CLI — list / detect / apply / audit
set -euo pipefail

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CURSOR_DIR/.." && pwd)"
TEMPLATE_ROOT="$CURSOR_DIR/templates/scaffold"
MANIFEST="$TEMPLATE_ROOT/manifest.json"
# shellcheck source=../lib/platform.sh
source "$CURSOR_DIR/lib/platform.sh"

IGNORE_DIRS='^\.(git|cursor|cursorGrowth)|^node_modules$|^dist$|^build$|^\.venv$|^target$|^bin$'

usage() {
  cat <<EOF
用法: $0 <command> [args]

命令:
  list              列出可用脚手架
  info <id>         查看脚手架详情与文件列表
  detect            检测仓库状态（empty / partial / established）
  apply <id>        应用脚手架到仓库根目录
  apply-bundle <id> 应用可选附加包（如 user-manual · test-report）
  audit             审计已有项目，输出改进建议
  files <id>        仅列出将创建的文件（等同 apply --dry-run）

选项（apply）:
  --dry-run         只打印将创建/跳过的文件
  --force           覆盖已存在文件（默认跳过冲突）

示例:
  $0 list
  $0 detect
  $0 info react-vite-ts
  $0 apply react-vite-ts --dry-run
  $0 apply go-api
  $0 apply-bundle user-manual --dry-run --stack react-vite-ts
  $0 apply-bundle test-report --dry-run --stack go-api
  $0 audit
EOF
}

require_manifest() {
  if [[ ! -f "$MANIFEST" ]]; then
    echo "FAIL: manifest not found: $MANIFEST" >&2
    exit 1
  fi
}

require_json_tool() {
  sc_require_json_tool
}

scaffold_exists() {
  local id="$1"
  [[ -d "$TEMPLATE_ROOT/$id" ]] && sc_manifest_scaffold_exists "$MANIFEST" "$id"
}

cmd_list() {
  require_manifest
  require_json_tool
  echo "=== Available scaffolds ==="
  sc_manifest_list "$MANIFEST" | sc_print_columns
  if jq -e '.bundles | length > 0' "$MANIFEST" >/dev/null 2>&1; then
    echo ""
    echo "=== Optional bundles (apply-bundle) ==="
    jq -r '.bundles[] | "\(.id)\t\(.category)\t\(.name)"' "$MANIFEST" | sc_print_columns
  fi
}

cmd_info() {
  local id="${1:-}"
  if [[ -z "$id" ]]; then
    echo "FAIL: usage: $0 info <id>" >&2
    exit 1
  fi
  require_manifest
  require_json_tool
  if ! scaffold_exists "$id"; then
    echo "FAIL: unknown scaffold: $id" >&2
    exit 1
  fi
  echo "=== $id ==="
  sc_manifest_scaffold_info "$MANIFEST" "$id"
  echo ""
  echo "Files:"
  (cd "$TEMPLATE_ROOT/$id" && find . -type f ! -path './.git/*' | sort | sed 's|^\./||')
}

cmd_files() {
  local id="${1:-}"
  if [[ -z "$id" ]]; then
    echo "FAIL: usage: $0 files <id>" >&2
    exit 1
  fi
  cmd_apply "$id" --dry-run
}

count_project_files() {
  local count=0
  local f
  while IFS= read -r -d '' f; do
    count=$((count + 1))
  done < <(find "$ROOT" -mindepth 1 -maxdepth 3 \( \
    -path "$ROOT/.git/*" -o \
    -path "$ROOT/.cursor/*" -o \
    -path "$ROOT/.cursorGrowth/*" -o \
    -name node_modules -o \
    -name .venv -o \
    -name build -o \
    -name dist \
    \) -prune -o -type f -print0 2>/dev/null)
  echo "$count"
}

detect_stack() {
  local hints=()
  if [[ -f "$ROOT/package.json" ]]; then
    hints+=("$(sc_detect_node_stack "$ROOT/package.json")")
  fi
  [[ -f "$ROOT/go.mod" ]] && hints+=("go")
  [[ -f "$ROOT/Cargo.toml" ]] && hints+=("rust")
  [[ -f "$ROOT/pyproject.toml" || -f "$ROOT/requirements.txt" ]] && hints+=("python")
  [[ -f "$ROOT/pom.xml" || -f "$ROOT/build.gradle" || -f "$ROOT/build.gradle.kts" ]] && hints+=("java")
  [[ -f "$ROOT/CMakeLists.txt" ]] && hints+=("cpp")
  if [[ ${#hints[@]} -eq 0 ]]; then
    echo "none"
  else
    printf '%s ' "${hints[@]}"
  fi
}

cmd_detect() {
  local count stack state
  count="$(count_project_files)"
  stack="$(detect_stack)"
  if [[ "$count" -le 2 ]]; then
    state="empty"
  elif [[ "$stack" == "none" ]]; then
    state="partial"
  else
    state="established"
  fi
  echo "state=$state"
  echo "file_count=$count"
  echo "detected_stack=$stack"
  echo "root=$ROOT"
  if [[ "$state" == "empty" ]]; then
    echo "hint=适合 /scaffold apply；或先 /plan 与用户确认后创建"
  elif [[ "$state" == "established" ]]; then
    echo "hint=运行 audit 获取改进建议，勿盲目 apply 覆盖"
  else
    echo "hint=仓库有文件但未识别主流栈；与用户确认是否补脚手架"
  fi
}

apply_file() {
  local src="$1" dest="$2" force="$3" dry_run="$4"
  if [[ -e "$dest" && "$force" != "true" ]]; then
    echo "SKIP  $dest (exists)"
    return 0
  fi
  if [[ "$dry_run" == "true" ]]; then
    echo "WOULD $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  if [[ "$dest" == *.sh ]]; then
    chmod +x "$dest"
  fi
  echo "CREATE $dest"
}

cmd_apply() {
  local id=""
  local dry_run="false"
  local force="false"
  local arg

  for arg in "$@"; do
    case "$arg" in
      --dry-run) dry_run="true" ;;
      --force) force="true" ;;
      -*) echo "FAIL: unknown option: $arg" >&2; exit 1 ;;
      *)
        if [[ -n "$id" ]]; then
          echo "FAIL: multiple scaffold ids: $id and $arg" >&2
          exit 1
        fi
        id="$arg"
        ;;
    esac
  done

  if [[ -z "$id" ]]; then
    echo "FAIL: usage: $0 apply <id> [--dry-run] [--force]" >&2
    exit 1
  fi

  if ! scaffold_exists "$id"; then
    echo "FAIL: unknown scaffold: $id" >&2
    exit 1
  fi

  local src_dir="$TEMPLATE_ROOT/$id"
  local rel src dest
  echo "=== apply: $id (dry_run=$dry_run force=$force) ==="
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    src="$src_dir/$rel"
    dest="$ROOT/$rel"
    apply_file "$src" "$dest" "$force" "$dry_run"
  done < <(cd "$src_dir" && find . -type f ! -path './.git/*' -print0)

  # Shared Cursor ignore (one file for all stacks)
  local shared_ignore="$TEMPLATE_ROOT/_shared.cursorignore"
  if [[ -f "$shared_ignore" ]]; then
    apply_file "$shared_ignore" "$ROOT/.cursorignore" "$force" "$dry_run"
  fi

  if [[ "$dry_run" != "true" ]]; then
    echo ""
    echo "=== post_apply (run manually) ==="
    sc_manifest_scaffold_post_apply "$MANIFEST" "$id" | sed 's/^/  /'
    echo ""
    echo "verify: ./$(sc_manifest_scaffold_field "$MANIFEST" "$id" verify)"
  fi
}

audit_check() {
  local label="$1" path="$2" suggestion="$3"
  if [[ ! -e "$ROOT/$path" ]]; then
    echo "MISSING  $label ($path) — $suggestion"
  else
    echo "OK       $label ($path)"
  fi
}

bundle_exists() {
  local id="$1"
  jq -e --arg id "$id" '.bundles[] | select(.id == $id)' "$MANIFEST" >/dev/null 2>&1
}

bundle_web_stack() {
  local bundle_id="$1" stack="$2"
  jq -e --arg id "$bundle_id" --arg s "$stack" \
    '.bundles[] | select(.id == $id) | .stacks_web[]? | select(. == $s)' "$MANIFEST" >/dev/null 2>&1
}

apply_bundle_layer() {
  local bundle_id="$1" layer_key="$2" force="$3" dry_run="$4"
  local bundle_path layer_sub src_dir rel src dest

  bundle_path="$(jq -r --arg id "$bundle_id" '.bundles[] | select(.id == $id) | .path' "$MANIFEST")"
  layer_sub="$(jq -r --arg id "$bundle_id" --arg k "$layer_key" \
    '.bundles[] | select(.id == $id) | .layers[$k]' "$MANIFEST")"
  [[ -n "$bundle_path" && "$bundle_path" != "null" ]] || {
    echo "FAIL: bundle path missing for $bundle_id" >&2
    exit 1
  }
  [[ -n "$layer_sub" && "$layer_sub" != "null" ]] || return 0

  src_dir="$TEMPLATE_ROOT/$bundle_path/$layer_sub"
  [[ -d "$src_dir" ]] || {
    echo "FAIL: bundle layer missing: $src_dir" >&2
    exit 1
  }

  echo "=== layer: $layer_key ($layer_sub) ==="
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    src="$src_dir/$rel"
    dest="$ROOT/$rel"
    apply_file "$src" "$dest" "$force" "$dry_run"
  done < <(cd "$src_dir" && find . -type f ! -path './.git/*' -print0)
}

should_apply_web_layer() {
  local bundle_id="$1" stack="$2"
  if [[ -n "$stack" ]]; then
    bundle_web_stack "$bundle_id" "$stack"
    return $?
  fi
  local detected
  detected="$(detect_stack)"
  case "$detected" in
    *react*|*vue*|*nextjs*) return 0 ;;
    *) return 1 ;;
  esac
}

cmd_apply_bundle() {
  local bundle_id=""
  local stack=""
  local dry_run="false"
  local force="false"
  local arg next_is_stack="false"

  while [[ $# -gt 0 ]]; do
    arg="$1"
    if [[ "$next_is_stack" == "true" ]]; then
      stack="$arg"
      next_is_stack="false"
      shift
      continue
    fi
    case "$arg" in
      --dry-run) dry_run="true" ;;
      --force) force="true" ;;
      --stack) next_is_stack="true" ;;
      --stack=*) stack="${arg#--stack=}" ;;
      -*) echo "FAIL: unknown option: $arg" >&2; exit 1 ;;
      *)
        if [[ -n "$bundle_id" ]]; then
          echo "FAIL: multiple bundle ids" >&2
          exit 1
        fi
        bundle_id="$arg"
        ;;
    esac
    shift
  done

  [[ "$next_is_stack" != "true" ]] || {
    echo "FAIL: --stack requires value" >&2
    exit 1
  }

  if [[ -z "$bundle_id" ]]; then
    echo "FAIL: usage: $0 apply-bundle <id> [--stack <scaffold-id>] [--dry-run] [--force]" >&2
    exit 1
  fi

  require_manifest
  require_json_tool

  if ! bundle_exists "$bundle_id"; then
    echo "FAIL: unknown bundle: $bundle_id" >&2
    exit 1
  fi

  echo "=== apply-bundle: $bundle_id (dry_run=$dry_run force=$force stack=${stack:-auto}) ==="
  apply_bundle_layer "$bundle_id" "shared" "$force" "$dry_run"

  if should_apply_web_layer "$bundle_id" "$stack"; then
    apply_bundle_layer "$bundle_id" "web" "$force" "$dry_run"
  else
    echo "SKIP  web layer (not a frontend stack; use --stack react-vite-ts to preview web files)"
  fi

  if [[ "$dry_run" != "true" ]]; then
    echo ""
    echo "=== post_apply (run manually) ==="
    jq -r --arg id "$bundle_id" '.bundles[] | select(.id == $id) | .post_apply[]' "$MANIFEST" | sed 's/^/  /'
  fi
}

cmd_audit() {
  local stack
  stack="$(detect_stack)"
  echo "=== Project audit ==="
  echo "stack: $stack"
  echo ""
  echo "--- Essentials ---"
  audit_check "verify script" "scripts/verify.sh" "添加可执行验收脚本，或在 plan.md 设 VERIFY"
  audit_check "README" "README.md" "补充安装、运行、验证说明"
  audit_check "gitignore" ".gitignore" "排除 .cursorGrowth/ · 构建产物与密钥"
  audit_check "cursorignore" ".cursorignore" "硬拦 Agent 读 .env 等；scaffold apply 会生成"
  audit_check "plan" ".cursorGrowth/plan.md" "可选：install --copy-plan 或 cp templates/plan.md → .cursorGrowth/plan.md"
  echo ""
  echo "--- Stack signals ---"
  audit_check "package.json" "package.json" "前端/Node 项目"
  audit_check "go.mod" "go.mod" "Go 模块"
  audit_check "pyproject.toml" "pyproject.toml" "Python 现代打包"
  audit_check "build.gradle.kts" "build.gradle.kts" "Java Gradle"
  audit_check "CMakeLists.txt" "CMakeLists.txt" "C++ CMake"
  echo ""
  echo "--- Super Cursor ---"
  audit_check ".cursor" ".cursor/rules/core.mdc" "运行 install-super-cursor.sh"
  audit_check "workflow config" ".cursor/config/workflow.json" "编辑 verify_default 等"
  echo ""
  echo "--- Suggestions ---"
  if [[ ! -f "$ROOT/scripts/verify.sh" ]]; then
    echo "  → 用 /scaffold 补 scripts/verify.sh，或从模板 manifest 选相近栈"
  fi
  if [[ ! -f "$ROOT/.cursorGrowth/plan.md" && -f "$ROOT/.cursor/templates/plan.md" ]]; then
    echo "  → mkdir -p .cursorGrowth && cp .cursor/templates/plan.md .cursorGrowth/plan.md 后 /plan"
  fi
  if [[ "$stack" != "none "* && "$stack" != "none" ]]; then
    echo "  → 已有栈检测：$stack — 运行 /learn 沉淀约定，勿盲目 apply 全量脚手架"
  fi
  if [[ ! -d "$ROOT/.cursorGrowth/learn" || -z "$(ls -A "$ROOT/.cursorGrowth/learn" 2>/dev/null || true)" ]]; then
    echo "  → 运行 /learn 写入 dev-conventions 与 module-map"
  fi
}

main() {
  local cmd="${1:-}"
  case "$cmd" in
    list) cmd_list ;;
    info) shift; cmd_info "$@" ;;
    detect) cmd_detect ;;
    apply) shift; cmd_apply "$@" ;;
    apply-bundle) shift; cmd_apply_bundle "$@" ;;
    files) shift; cmd_files "$@" ;;
    audit) cmd_audit ;;
    -h|--help|help|"") usage ;;
    *) echo "FAIL: unknown command: $cmd" >&2; usage; exit 1 ;;
  esac
}

main "$@"
