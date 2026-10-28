#!/usr/bin/env bash
# plan / run CLI
set -euo pipefail

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CURSOR_DIR/.." && pwd)"
CONFIG="$CURSOR_DIR/config/workflow.json"
# shellcheck source=../lib/platform.sh
source "$CURSOR_DIR/lib/platform.sh"

sc_config() {
  local key="$1"
  local default="${2:-}"
  local dotted="${key#.}"
  local val=""

  if [[ -f "$CONFIG" ]]; then
    val="$(json_cfg "$CONFIG" "$dotted" "")"
    [[ -n "$val" && "$val" != "null" ]] && { echo "$val"; return 0; }
  fi
  echo "$default"
}

sc_config_join() {
  local key="$1"
  local default="${2:-}"
  local dotted="${key#.}"
  local joined=""

  if [[ -f "$CONFIG" ]]; then
    joined="$(json_cfg_join "$CONFIG" "$dotted" "")"
    [[ -n "$joined" && "$joined" != "null" ]] && { echo "$joined"; return 0; }
  fi
  echo "$default"
}

PLAN_REL="$(sc_config '.plan_file' '.growing/plan.md')"
PLAN="$ROOT/$PLAN_REL"
# Legacy: root plan.md before .growing migration
if [[ ! -f "$PLAN" && -f "$ROOT/plan.md" ]]; then
  PLAN="$ROOT/plan.md"
  PLAN_REL="plan.md"
fi
FRONTEND_DIR="$(sc_config '.task_verify_heuristics.frontend_test_dir' '')"
BACKEND_DIR="$(sc_config '.task_verify_heuristics.backend_test_dir' '')"
FRONTEND_TEST_CMD="$(sc_config '.task_verify_heuristics.frontend_test_cmd' '')"
BACKEND_TEST_CMD="$(sc_config '.task_verify_heuristics.backend_test_cmd' '')"
HEURISTICS_ENABLED="$(sc_config '.task_verify_heuristics.enabled' 'false')"
FALLBACK_TEST="$(sc_config '.task_verify_heuristics.fallback_test_script' './scripts/test.sh')"
FALLBACK_VERIFY="$(sc_config '.task_verify_heuristics.fallback_verify_script' './scripts/verify.sh')"
VERSION_TAG_GLOB_ENV="$(sc_config 'version_tag_glob_env' 'VERSION_TAG_GLOB')"
VERSION_DEFAULT_ENV="$(sc_config 'version_default_env' 'RELEASE_VERSION_DEFAULT')"
SC_SKIP_PREFIXES="$(sc_config_join '.task_id.prefixes_skip' 'REV- SPIKE- DOC-')"
export SC_SKIP_PREFIXES
# shellcheck source=../hooks/lib/plan-parse.sh
source "$CURSOR_DIR/hooks/lib/plan-parse.sh" "$PLAN"

cmd="${1:-status}"

# 项目 /tmp 契约（.growing/temp-cleanup.json）— 测试/验收成功后回收 ephemeral；verify 后可 sweep persistent
project_tmp_cleanup() {
  local phase="$1"
  local flag dry rel script
  [[ "$(sc_config '.temp_cleanup.enabled' 'true')" == "true" ]] || return 0
  case "$phase" in
    test)
      [[ "$(sc_config '.temp_cleanup.after_test' 'true')" == "true" ]] || return 0 ;;
    verify)
      [[ "$(sc_config '.temp_cleanup.after_verify' 'true')" == "true" ]] || return 0 ;;
    task-verify)
      [[ "$(sc_config '.temp_cleanup.after_task_verify' 'true')" == "true" ]] || return 0 ;;
    sweep) ;;
    *) return 0 ;;
  esac
  script="$CURSOR_DIR/lib/project-tmp-cleanup.sh"
  [[ -f "$script" ]] || return 0
  rel="$(sc_config '.temp_cleanup.config' '.growing/temp-cleanup.json')"
  [[ -f "$ROOT/$rel" ]] || return 0
  dry=0
  [[ "$(sc_config '.temp_cleanup.dry_run' 'false')" == "true" ]] && dry=1
  if [[ "$dry" -eq 1 ]]; then
    bash "$script" --phase "$phase" --root "$ROOT" --config "$ROOT/$rel" --dry-run 2>/dev/null || true
  else
    bash "$script" --phase "$phase" --root "$ROOT" --config "$ROOT/$rel" 2>/dev/null || true
  fi
}

sc_env_get() {
  local name="$1"
  printf '%s' "${!name-}"
}

resolve_tag_glob() {
  local version_line="$1"
  local from_env
  from_env="$(sc_env_get "$VERSION_TAG_GLOB_ENV")"
  if [[ -n "$from_env" ]]; then
    echo "$from_env"
  elif [[ -n "$version_line" ]]; then
    echo "v${version_line}.*"
  else
    echo "v*"
  fi
}

resolve_version_default() {
  local version_line="$1"
  local plan_default env_default
  plan_default="$(version_default_value)"
  env_default="$(sc_env_get "$VERSION_DEFAULT_ENV")"
  if [[ -n "$version_line" ]]; then
    echo "${env_default:-${plan_default:-${version_line}.0}}"
  else
    echo "${env_default:-${plan_default:-0.1.0}}"
  fi
}

next_version() {
  bump_version patch
}

# 版本键归位：模板占位说明（"(optional · major.minor，如 4.22…)"）绝不是版本号。
# 非「数字点分」值一律视为未设置 —— 否则 release-tag 会拿垃圾 tag_glob 交给 git tag。
# 三个 helper 都显式 return 0：调用处是 `v="$(helper)"`，非零返回会在 set -e 下中断。
version_line_value() {
  local v
  v="$(plan_meta_value "VERSION_LINE")"
  if [[ "$v" =~ ^[0-9]+\.[0-9]+$ ]]; then
    printf '%s\n' "$v"
  fi
  return 0
}

version_default_value() {
  local v
  v="$(plan_meta_value "VERSION_DEFAULT")"
  if [[ "$v" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]]; then
    printf '%s\n' "$v"
  fi
  return 0
}

release_bump_value() {
  local v
  v="$(plan_meta_value "RELEASE_BUMP")"
  case "$v" in
    patch|minor|major) printf '%s\n' "$v" ;;
  esac
  return 0
}

bump_version() {
  local bump="${1:-patch}"
  local latest ver major minor patch tag_glob default_ver version_line
  version_line="$(version_line_value)"
  tag_glob="$(resolve_tag_glob "$version_line")"
  default_ver="$(resolve_version_default "$version_line")"
  latest="$(git -C "$ROOT" tag -l "$tag_glob" --sort=-v:refname 2>/dev/null | head -1 || true)"
  if [[ -z "$latest" ]]; then
    echo "$default_ver"
    return 0
  fi
  ver="${latest#v}"
  IFS='.' read -r major minor patch <<< "$ver"
  major="${major:-0}"
  minor="${minor:-0}"
  patch="${patch:-0}"
  case "$bump" in
    patch) echo "${major}.${minor}.$((patch + 1))" ;;
    minor) echo "${major}.$((minor + 1)).0" ;;
    major) echo "$((major + 1)).0.0" ;;
    *)
      echo "Unknown bump: $bump (patch|minor|major)" >&2
      return 1
      ;;
  esac
}

release_tag() {
  # 发版闸门（fail-closed）：tag 前须 verify 绿（与 release skill 一致；可 RELEASE_SKIP_VERIFY=1 显式跳过留痕）
  local verify_cmd="${RELEASE_VERIFY_CMD:-bash scripts/verify.sh --core}"
  if [[ "${RELEASE_SKIP_VERIFY:-}" == "1" ]]; then
    echo "WARN: RELEASE_SKIP_VERIFY=1 —— 此次 tag 未经验证（显式跳过，留痕）" >&2
  else
    echo "==> release gate: $verify_cmd"
    if ! ( cd "$ROOT" && eval "$verify_cmd" ); then
      echo "BLOCK: 发版前 verify 未通过（fail-closed）—— 修复后重试；确需跳过：RELEASE_SKIP_VERIFY=1" >&2
      return 1
    fi
  fi
  local bump="${RELEASE_BUMP:-$(release_bump_value)}"
  bump="${bump:-patch}"
  local release_config="$CURSOR_DIR/config/release.json"
  local auto_minor auto_major tag_prefix annotated version tag_name msg
  auto_minor="$(json_cfg "$release_config" "bump.auto_minor" "false" 2>/dev/null || echo false)"
  auto_major="$(json_cfg "$release_config" "bump.auto_major" "false" 2>/dev/null || echo false)"
  tag_prefix="$(json_cfg "$release_config" "tag_prefix" "v" 2>/dev/null || echo v)"
  annotated="$(json_cfg "$release_config" "annotated_tags" "true" 2>/dev/null || echo true)"

  if [[ "$bump" == "minor" && "$auto_minor" != "true" && "${RELEASE_ALLOW_MINOR:-}" != "true" ]]; then
    echo "BLOCK: minor 须评估并设 RELEASE_ALLOW_MINOR=true 或 plan <!-- RELEASE_BUMP: minor -->（见 release skill）" >&2
    return 1
  fi
  if [[ "$bump" == "major" && "$auto_major" != "true" && "${RELEASE_ALLOW_MAJOR:-}" != "true" ]]; then
    echo "BLOCK: major 须用户明确授权 RELEASE_ALLOW_MAJOR=true（见 release skill）" >&2
    return 1
  fi

  version="$(bump_version "$bump")"
  tag_name="${tag_prefix}${version}"

  if git -C "$ROOT" rev-parse "$tag_name" >/dev/null 2>&1; then
    echo "FAIL: tag $tag_name 已存在" >&2
    return 1
  fi

  msg="${RELEASE_TAG_MSG:-Release ${version}}"
  if [[ "$annotated" == "true" ]]; then
    git -C "$ROOT" tag -a "$tag_name" -m "$msg"
  else
    git -C "$ROOT" tag "$tag_name" -m "$msg"
  fi

  echo "OK: tagged $tag_name at $(git -C "$ROOT" rev-parse --short HEAD)"
  echo "version=$version"
  echo "tag=$tag_name"
  echo "bump=$bump"
}

release_check() {
  local p0_open tag_glob version_line latest
  p0_open="$(grep -E '\| P0 \|' "$PLAN" 2>/dev/null | grep -cv '| ✅ |' || true)"
  version_line="$(version_line_value)"
  tag_glob="$(resolve_tag_glob "$version_line")"
  latest="$(git -C "$ROOT" tag -l "$tag_glob" --sort=-v:refname 2>/dev/null | head -1 || true)"
  if [[ "$p0_open" -eq 0 ]]; then
    echo "ready"
    echo "latest_tag=${latest:-none}"
    echo "tag_glob=$tag_glob"
    echo "next_version=$(next_version)"
    echo "tag=v$(next_version)"
    return 0
  fi
  echo "pending_p0=$p0_open"
  return 1
}

gate_check() {
  local reason
  reason="$(plan_gate_ok || true)"
  echo "=== run gate-check ==="
  case "$reason" in
    OK)
      local gs ga
      gs="$(plan_sprint)"
      ga="$(plan_active)"
      echo "OK: PLAN_APPROVED=$(plan_plan_approved) · SPRINT=${gs:-(none)} · ACTIVE=${ga:-(none)}"
      return 0
      ;;
    PLANNING)
      echo "BLOCK: PLANNING=true — 请先 /plan 完成规划并设 PLANNING:false"
      return 1
      ;;
    NO_APPROVAL)
      echo "BLOCK: 无 PLAN_APPROVED — 请先 /plan 确认规划并写入日期"
      return 1
      ;;
    *)
      echo "BLOCK: 未知闸门状态"
      return 1
      ;;
  esac
}

plan_check() {
  local issues=0
  echo "=== plan / run plan-check ==="
  if [[ ! -f "$PLAN" ]]; then
    echo "FAIL: plan 不存在（config plan_file 或 .growing/plan.md）"
    return 1
  fi
  if ! grep -q '| ⬜ |' "$PLAN" 2>/dev/null && ! grep -q '| 🔧 |' "$PLAN" 2>/dev/null; then
    if ! plan_sprint_appears_closed; then
      echo "WARN: 无活跃 ⬜/🔧 任务"
      issues=$((issues + 1))
    fi
  fi
  if [[ -z "$(plan_active)" ]]; then
    if ! plan_sprint_appears_closed; then
      echo "WARN: <!-- ACTIVE --> 未设置"
      issues=$((issues + 1))
    fi
  fi
  if [[ -z "$(plan_sprint)" ]] && ! plan_sprint_appears_closed; then
    echo "WARN: <!-- SPRINT --> 未设置"
    issues=$((issues + 1))
  fi
  if [[ "$(plan_sprint_status)" == "active" ]] && plan_sprint_goal_ritual_only; then
    echo "WARN: Sprint Goal 似仪式/出口动作（非能力交付）— 改 /release 或并入功能 Sprint（plan reference/sprint-goal-gate.md）"
    echo "      Goal: $(plan_sprint_goal_text)"
    issues=$((issues + 1))
  fi
  if plan_planning; then
    echo "INFO: PLANNING=true — 仅 plan"
  elif [[ -z "$(plan_plan_approved)" ]]; then
    echo "FAIL: <!-- PLAN_APPROVED --> 未设置（run 硬闸门）"
    issues=$((issues + 1))
  fi
  if ! grep -qE '^\*\*(执行顺序|Order)\*\*' "$PLAN" 2>/dev/null && ! plan_sprint_appears_closed; then
    echo "WARN: 缺 **执行顺序** 行（兼容 **Order**；NEXT 回退靠表序）"
    issues=$((issues + 1))
  fi
  local line cols bad=0 plan_active_tmp
  plan_active_tmp="$(mktemp)"
  grep -E '\| (⬜|🔧) \|' "$PLAN" 2>/dev/null >"$plan_active_tmp" || true
  while IFS= read -r line; do
    [[ "$line" =~ \|[[:space:]]*(⬜|🔧)[[:space:]]*\| ]] || continue
    cols="$(echo "$line" | awk -F'|' '{print NF}')"
    if [[ "$cols" -lt 8 ]]; then
      bad=$((bad + 1))
    fi
  done <"$plan_active_tmp"
  if [[ "$bad" -gt 0 ]]; then
    echo "WARN: ${bad} 行活跃任务可能缺「验收」或「落点」"
    issues=$((issues + 1))
  fi
  # 验收列必须可判定：task-verify 是 fail-closed，prose 验收开工前就该发现
  local tid tacc prose_acc=0 plan_tid_tmp
  plan_tid_tmp="$(mktemp)"
  awk -F'|' '{gsub(/^[ \t*]+|[ \t*]+$/, "", $2); print $2}' "$plan_active_tmp" >"$plan_tid_tmp" 2>/dev/null || true
  while IFS= read -r tid; do
    [[ -z "$tid" ]] && continue
    tacc="$(plan_task_acceptance "$tid")"
    if [[ "$(acceptance_kind "$tacc")" == "prose" ]]; then
      echo "WARN: ${tid} 验收列不可执行 → task-verify 会 FAIL: ${tacc:-（空）}"
      prose_acc=$((prose_acc + 1))
    fi
  done <"$plan_tid_tmp"
  rm -f "$plan_active_tmp" "$plan_tid_tmp"
  if [[ "$prose_acc" -gt 0 ]]; then
    echo "      → 改成可执行命令，或写 manual: <步骤与证据要求>（见 templates/plan.md）"
    issues=$((issues + prose_acc))
  fi
  # Sprint 已闭合但 plan 正文未 reconciliation
  if plan_sprint_appears_closed; then
    local unchecked pending_tasks
    unchecked="$(plan_done_when_unchecked)"
    if [[ "${unchecked:-0}" -gt 0 ]]; then
      echo "WARN: Sprint 已闭合但 Done when 仍有 ${unchecked} 项未 [x] — 见 run skill · plan 正文 reconciliation"
      issues=$((issues + 1))
    fi
    if grep -qE '^##[[:space:]]+(活跃[[:space:]]+[Ss]print|Active[[:space:]]+[Ss]print)' "$PLAN" 2>/dev/null; then
      echo "WARN: Sprint 标题仍为「进行中」— 收尾时改为 Completed/已完成（见 .growing/learn/plan-conventions.md）"
      issues=$((issues + 1))
    fi
    if [[ "$(plan_sprint_status)" != "closed" ]]; then
      echo "WARN: <!-- SPRINT_STATUS --> 未设 closed（建议 Sprint 收尾时写入）"
      issues=$((issues + 1))
    fi
    pending_tasks="$(grep -cE '\| ⬜ \|' "$PLAN" 2>/dev/null || true)"
    pending_tasks="${pending_tasks:-0}"
    if [[ "$pending_tasks" -gt 0 ]]; then
      echo "WARN: Sprint 已闭合但 TASK 表仍有 ${pending_tasks} 行 ⬜"
      issues=$((issues + 1))
    fi
  fi
  local vmeta vpath
  vmeta="$(plan_verify)"
  if [[ "$vmeta" == *"runner.sh"* && "$vmeta" == *"verify"* ]]; then
    echo "FAIL: <!-- VERIFY --> 不得为 runner.sh verify（无限递归）；应写 ./scripts/verify.sh"
    issues=$((issues + 1))
  elif [[ "$vmeta" != *" "* && "$vmeta" == ./* ]]; then
    vpath="${vmeta#./}"
    if [[ ! -f "$ROOT/$vpath" ]]; then
      echo "WARN: VERIFY 脚本不存在: $vmeta"
      issues=$((issues + 1))
    fi
  fi
  if [[ "$issues" -eq 0 ]]; then
    echo "OK: handoff 就绪"
    return 0
  fi
  echo "CHECK: ${issues} 项待补齐"
  return 1
}

# 从验收列提取可执行命令（行首命令，或唯一一对反引号内的命令）
acceptance_extract_exec_cmd() {
  local acc="${1:-}"
  acc="${acc//$'\r'/}"
  local inner
  if [[ "$acc" =~ ^[[:space:]]*(\./|cd |npm |pnpm |npx |node |vitest |pytest |grep |cargo |go test|uv run |dotnet |mvn |make |bash ) ]]; then
    printf '%s' "${acc#"${acc%%[![:space:]]*}"}"
    return 0
  fi
  if [[ "$acc" =~ \`([^\`]+)\` ]]; then
    inner="${BASH_REMATCH[1]}"
    inner="${inner#"${inner%%[![:space:]]*}"}"
    inner="${inner%"${inner##*[![:space:]]}"}"
    if [[ "$inner" =~ ^(\./|cd |npm |pnpm |npx |node |vitest |pytest |grep |cargo |go test|uv run |dotnet |mvn |make |bash ) ]]; then
      printf '%s' "$inner"
      return 0
    fi
  fi
  return 1
}

# 验收列形态：exec（可执行命令）· manual（显式人工）· prose（不可判定）
# 单一真源 —— task_verify 与 plan_check 共用，避免两处漂移
acceptance_kind() {
  local acc="${1:-}"
  if acceptance_extract_exec_cmd "$acc" >/dev/null 2>&1; then
    echo "exec"
  elif [[ "$acc" == manual:* || "$acc" == "manual" || "$acc" == *"人工验收"* ]]; then
    echo "manual"
  else
    echo "prose"
  fi
}

# --- 摩擦可观测（B5）：交付后记一行，供 /learn 汇总 ---
json_escape() {
  local s="${1:-}"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

# archive 域分层门禁：根目录 flat 文件超阈值即 FAIL（growth-layout §Archive 布局）
archive_check() {
  local rel dir max flat
  rel="$(sc_config '.archive_dir' '.growing/archive')"
  dir="$ROOT/$rel"
  max="$(sc_config '.growth.archive_flat_max' '5')"
  [[ "$max" =~ ^[0-9]+$ ]] || max=5
  if [[ ! -d "$dir" ]]; then
    echo "OK: archive 目录尚未创建（${rel}）"
    return 0
  fi
  flat="$(find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' ')"
  echo "=== archive-check: $rel (flat=$flat · max=$max) ==="
  if [[ "$flat" -gt "$max" ]]; then
    echo "FAIL: archive 根目录有 ${flat} 个 flat 文件（>${max}）→ 按域归档：" >&2
    find "$dir" -maxdepth 1 -type f -exec basename {} \; | sed 's|^|  |' | sort
    echo "  域：sprint · spike · release · doc · ops（域表与扩展 → learn/plan-conventions.md）" >&2
    return 1
  fi
  echo "OK: 根目录 flat 文件 ${flat}/${max}（域目录：$(find "$dir" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ') 个）"
  return 0
}

docs_init() {
  local profile="" force="false" dry_run="false" all="false" slots=""
  local arg
  while [[ $# -gt 0 ]]; do
    arg="$1"
    case "$arg" in
      --profile) profile="${2:-}"; shift 2 ;;
      --slots) slots="${2:-}"; shift 2 ;;
      --all) all="true"; shift ;;
      --force) force="true"; shift ;;
      --dry-run) dry_run="true"; shift ;;
      -h|--help) docs_init_help; return 0 ;;
      *) echo "FAIL: unknown option: $arg" >&2; docs_init_help >&2; return 1 ;;
    esac
  done

  local cfg="$CURSOR_DIR/config/docs-layout.json"
  local tpl="$CURSOR_DIR/templates/project-docs"
  [[ -f "$cfg" ]] || { echo "FAIL: missing config/docs-layout.json" >&2; return 1; }
  [[ -d "$tpl" ]] || { echo "FAIL: missing templates/project-docs" >&2; return 1; }

  local dir chosen plan
  dir="$(sc_docs_get "$cfg" dir || true)"; dir="${dir%$'\r'}"; dir="${dir:-docs}"
  if [[ -n "$profile" ]]; then
    chosen="$profile"
  else
    chosen="$(sc_docs_get "$cfg" profile || true)"; chosen="${chosen%$'\r'}"; chosen="${chosen:-web-fullstack}"
  fi

  if ! plan="$(sc_docs_plan "$cfg" "$chosen")"; then
    echo "FAIL: unknown profile '$chosen'（见 config/docs-layout.json → profiles）" >&2
    return 1
  fi

  echo "=== docs-init: profile=$chosen dir=$dir (all=$all force=$force dry_run=$dry_run) ==="
  [[ -n "$slots" ]] && echo "  --slots=$slots"
  [[ "$dry_run" == "true" ]] && echo "  (dry-run：不写入)"

  local num name kind gen src dest created=0 skipped=0 missing=0 index=""
  while IFS=$'\t' read -r num name kind gen; do
    [[ -z "$num" ]] && continue
    local use="false"
    [[ "$kind" == "required" ]] && use="true"
    [[ "$all" == "true" ]] && use="true"
    case ",$slots," in *",$num,"*) use="true" ;; esac
    [[ "$use" == "true" ]] || continue

    src=""
    local f
    for f in "$tpl/$num"_*.md; do
      [[ -f "$f" ]] && { src="$f"; break; }
    done
    if [[ -z "$src" ]]; then
      echo "  WARN 无 $num 骨架（templates/project-docs 缺失）" >&2
      missing=$((missing + 1))
      continue
    fi

    dest="$ROOT/$dir/${num}_${name}.md"
    local mark=""
    [[ -n "$gen" ]] && mark=" ⚙$gen"
    if [[ -e "$dest" && "$force" != "true" ]]; then
      echo "  skip  $dir/${num}_${name}.md（已存在；--force 覆盖）"
      skipped=$((skipped + 1))
    elif [[ "$dry_run" == "true" ]]; then
      echo "  plan  $dir/${num}_${name}.md$mark"
    else
      mkdir -p "$ROOT/$dir"
      cp "$src" "$dest"
      echo "  new   $dir/${num}_${name}.md$mark"
      created=$((created + 1))
    fi
    index="${index}| [\`${num}_${name}.md\`](${num}_${name}.md) | ${kind}${mark} |
"
  done <<< "$plan"

  # ROADMAP（例外 · 不加序号）
  local roadmap
  roadmap="$(sc_docs_get "$cfg" roadmap_file || true)"; roadmap="${roadmap%$'\r'}"; roadmap="${roadmap:-ROADMAP.md}"
  local roadmap_dest="$ROOT/$dir/$roadmap"
  if [[ -f "$tpl/ROADMAP.md" ]]; then
    if [[ -e "$roadmap_dest" && "$force" != "true" ]]; then
      echo "  skip  $dir/${roadmap}（已存在）"
    elif [[ "$dry_run" == "true" ]]; then
      echo "  plan  $dir/$roadmap"
    else
      mkdir -p "$ROOT/$dir"
      cp "$tpl/ROADMAP.md" "$roadmap_dest"
      echo "  new   $dir/$roadmap"
      created=$((created + 1))
    fi
  fi

  # 索引（docs/README.md · allow_unnumbered 内）
  local index_dest="$ROOT/$dir/README.md"
  if [[ "$dry_run" != "true" && -n "$index" ]]; then
    if [[ ! -e "$index_dest" || "$force" == "true" ]]; then
      mkdir -p "$ROOT/$dir"
      {
        printf '# 项目文档索引\n\n'
        printf '> profile: `%s` · 号位=瀑布阶段 · 规则 → `.cursor/rules/execution/project-docs.mdc`\n\n' "$chosen"
        printf '| 文档 | 类型 |\n|------|------|\n'
        printf '%b' "$index"
        printf '| [`%s`](%s) | roadmap（例外不加序号） |\n\n' "$roadmap" "$roadmap"
        printf '门禁：`bash .cursor/bin/verify-docs-layout.sh`\n'
      } > "$index_dest"
      echo "  new   $dir/README.md（索引）"
      created=$((created + 1))
    else
      echo "  skip  $dir/README.md（已存在）"
    fi
  fi

  if [[ -n "$profile" && "$dry_run" != "true" ]]; then
    sc_docs_set_profile "$cfg" "$profile"
    echo "  set   config/docs-layout.json → profile=$profile"
  fi

  echo "---"
  echo "created=$created skipped=$skipped missing=$missing"
  if [[ "$dry_run" == "true" ]]; then
    echo "dry-run 完成；去掉 --dry-run 落地"
  else
    echo "下一步：填 01/02/06/08/10 内容 · 07 用 /manual · 08 用 /report · 然后 bash .cursor/bin/verify-docs-layout.sh"
  fi
  [[ "$missing" -eq 0 ]] || return 1
  return 0
}

docs_init_help() {
  cat <<'EOF'
docs-init — 按 profile 把 templates/project-docs 骨架铺到 docs/（号位=瀑布阶段）

  runner.sh docs-init [--profile <p>] [--slots 03,04] [--all] [--force] [--dry-run]

  默认：只铺**必选号位**（01 需求 · 02 架构 · 06 规范 · 08 测试报告 · 10 调优）+ ROADMAP.md + README.md 索引
  --profile  覆盖 config/docs-layout.json 的 profile，并写回该文件
  --slots    额外启用指定条件号位（逗号分隔，如 03,04,09）
  --all      启用全部 10 个号位
  --force    覆盖已存在文件（默认 skip，不破坏已有内容）
  --dry-run  只打印计划
EOF
}

friction_log() {
  shift || true
  local task="" rounds="0" rework="0" result="" note=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task) task="${2:-}"; shift 2 ;;
      --rounds) rounds="${2:-0}"; shift 2 ;;
      --rework) rework="${2:-0}"; shift 2 ;;
      --verify) result="${2:-}"; shift 2 ;;
      --note) note="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done
  [[ "$rounds" =~ ^[0-9]+$ ]] || rounds=0
  [[ "$rework" =~ ^[0-9]+$ ]] || rework=0
  local dir="$ROOT/.growing/logs"
  mkdir -p "$dir"
  printf '{"ts":"%s","task":"%s","sprint":"%s","rounds":%s,"rework":%s,"verify":"%s","note":"%s"}\n' \
    "$(iso8601_now)" \
    "$(json_escape "$task")" \
    "$(json_escape "$(plan_sprint)")" \
    "$rounds" "$rework" \
    "$(json_escape "${result:-unknown}")" \
    "$(json_escape "$note")" >> "$dir/friction.jsonl"
  echo "OK: friction logged (${task:-?} · rounds=$rounds · rework=$rework · verify=${result:-unknown})"
}

friction_report() {
  local f="$ROOT/.growing/logs/friction.jsonl"
  if [[ ! -f "$f" ]]; then
    echo "（无 friction 记录：交付后用 runner.sh friction-log 记一行）"
    return 0
  fi
  awk '
    {
      n++
      if ($0 ~ /"verify":"pass"/) ok++; else bad++
      if (match($0, /"rounds":[0-9]+/)) tr += substr($0, RSTART+9, RLENGTH-9)
      if (match($0, /"rework":[0-9]+/)) tw += substr($0, RSTART+9, RLENGTH-9)
    }
    END {
      if (n > 0)
        printf "tasks=%d · verify_pass=%d · verify_fail=%d · avg_rounds=%.1f · avg_rework=%.1f\n",
               n, ok+0, bad+0, tr/n, tw/n
    }
  ' "$f"
}

task_verify() {
  if _task_verify_body "${1:-}"; then
    project_tmp_cleanup task-verify
    return 0
  fi
  return 1
}

_task_verify_body() {
  local id="${1:-$(plan_active)}"
  local acc loc pattern test_py
  if [[ -z "$id" ]]; then
    echo "FAIL: 无 ACTIVE 任务 ID" >&2
    return 1
  fi
  acc="$(plan_task_acceptance "$id")"
  loc="$(plan_task_landing "$id")"
  echo "=== task-verify: ${id} ==="
  echo "验收: ${acc}"
  echo "落点: ${loc}"

  local exec_cmd=""
  if exec_cmd="$(acceptance_extract_exec_cmd "$acc" 2>/dev/null)"; then
    echo "==> Running acceptance command"
    cd "$ROOT"
    # shellcheck disable=SC2086
    eval "$exec_cmd"
    return $?
  fi

  # 显式人工验收 —— 唯一合法豁免（须在 plan / CHANGELOG 写清证据要求）
  if [[ "$(acceptance_kind "$acc")" == "manual" ]]; then
    echo "MANUAL: 验收列声明为人工验收"
    echo "        请在 plan/CHANGELOG 留下证据（命令输出 · 截图路径 · 复核人）"
    return 0
  fi

  if [[ "$acc" == *vitest* || "$loc" == *vitest* || "$loc" == *.test.ts* || "$loc" == *.test.tsx* ]]; then
    pattern="$(basename "$loc" .test.ts)"
    pattern="${pattern%.test.tsx}"
    if [[ -z "$pattern" || "$pattern" == "$loc" ]]; then
      pattern="$(echo "$acc $loc" | grep -oE '[A-Za-z0-9_-]+' | head -1)"
    fi
    if [[ -n "$FRONTEND_DIR" && -d "$ROOT/$FRONTEND_DIR" && -n "$FRONTEND_TEST_CMD" ]]; then
      echo "==> cd $FRONTEND_DIR && $FRONTEND_TEST_CMD -- ${pattern}"
      cd "$ROOT/$FRONTEND_DIR"
      # shellcheck disable=SC2086
      $FRONTEND_TEST_CMD -- "$pattern"
      return $?
    fi
  fi

  if [[ "$acc" == *contract* || "$acc" == *integration* || "$acc" == *test_* ]]; then
    test_py="$(echo "$acc $loc" | grep -oE 'test_[a-z_]+' | head -1)"
    if [[ -n "$test_py" && -n "$BACKEND_DIR" && -d "$ROOT/$BACKEND_DIR" && -n "$BACKEND_TEST_CMD" ]]; then
      echo "==> cd $BACKEND_DIR && $BACKEND_TEST_CMD ${test_py}"
      cd "$ROOT/$BACKEND_DIR"
      # shellcheck disable=SC2086
      $BACKEND_TEST_CMD -q --tb=short -k "${test_py#test_}" 2>/dev/null || $BACKEND_TEST_CMD -q --tb=short "$(find tests -name "${test_py}.py" 2>/dev/null | head -1)"
      return $?
    fi
  fi

  if [[ "$acc" == grep* ]]; then
    cd "$ROOT"
    # shellcheck disable=SC2086
    eval "$acc"
    return $?
  fi

  # Scaffold-aligned fallback（描述性验收 + 存在脚手架脚本）—— 受 heuristics 开关控制
  local test_script="${FALLBACK_TEST#./}"
  local verify_script="${FALLBACK_VERIFY#./}"
  if [[ "$HEURISTICS_ENABLED" == "true" && -f "$ROOT/$test_script" ]]; then
    echo "==> heuristics fallback: $FALLBACK_TEST"
    cd "$ROOT"
    bash "$test_script"
    return $?
  fi
  if [[ "$HEURISTICS_ENABLED" == "true" && -f "$ROOT/$verify_script" && "$acc" == *verify* ]]; then
    echo "==> heuristics fallback: $FALLBACK_VERIFY"
    cd "$ROOT"
    bash "$verify_script"
    return $?
  fi

  # fail-closed：描述性验收**不得静默通过**（此前打印 SKIP 却 return 0 = 假完成温床）
  echo "FAIL: 验收列不可自动判定（描述性文字）" >&2
  echo "      当前: ${acc:-（空）}" >&2
  echo "      修法一: 写成可执行命令（${FALLBACK_TEST} · npm test · pytest · bash scripts/verify_<feature>.sh）" >&2
  echo "      修法二: 显式声明人工验收 → manual: <步骤与证据要求>" >&2
  return 1
}

print_status() {
  echo "=== run status ==="
  echo "PLANNING:   $(plan_meta PLANNING || echo false)"
  local sprint_disp active_disp
  sprint_disp="$(plan_sprint)"
  echo "SPRINT:     ${sprint_disp:-(none)}"
  echo "APPROVED:   $(plan_plan_approved || echo '(none)')"
  echo "AUTONOMOUS: $(plan_meta AUTONOMOUS || echo false)"
  active_disp="$(plan_active)"
  echo "ACTIVE:     ${active_disp:-(none)}"
  local active
  active="$(plan_active)"
  if [[ -n "$active" ]]; then
    echo "STATUS:     $(plan_task_status "$active")"
    echo "ACCEPTANCE: $(plan_task_acceptance "$active")"
    echo "NEXT_TASK:  $(plan_next_task)"
  fi
  echo "VERIFY:     $(plan_verify)  (打版前全量)"
  echo "PENDING:    $(plan_pending_count) tasks"
  echo "MAX_LOOPS:  $(plan_max_loops)"
  echo "NEXT_VER:   v$(next_version)"
  if release_check >/dev/null 2>&1; then
    echo "RELEASE:    ready (P0 全部 ✅)"
  else
    echo "RELEASE:    pending"
  fi
  local gate
  gate="$(plan_gate_ok || true)"
  echo "GATE:       ${gate}"
}

verify_cmd_is_runner_recursion() {
  local cmd="$1"
  [[ "$cmd" == *"runner.sh"* && "$cmd" == *"verify"* ]]
}

run_verify() {
  local verify_cmd fallback
  verify_cmd="$(plan_verify)"
  if verify_cmd_is_runner_recursion "$verify_cmd"; then
    echo "FAIL: plan VERIFY 不得指向 runner.sh verify（会无限递归）" >&2
    echo "      CLI 入口: ./.cursor/bin/runner.sh verify" >&2
    echo "      plan 应设: ./scripts/verify.sh" >&2
    fallback="$(sc_config 'verify_default' './scripts/verify.sh')"
    if [[ -f "$ROOT/${fallback#./}" ]]; then
      echo "==> 回退执行: $fallback"
      verify_cmd="$fallback"
    else
      exit 1
    fi
  fi
  # runner.sh verify = Sprint/打版前 L3 全量
  if [[ "$verify_cmd" =~ ^\./scripts/verify\.sh([[:space:]]|$) ]] \
    && [[ "$verify_cmd" != *"--full"* ]] \
    && [[ "$verify_cmd" != *"--l3"* ]]; then
    verify_cmd="./scripts/verify.sh --full"
  fi
  echo "==> Full VERIFY (L3): $verify_cmd"
  cd "$ROOT"
  # shellcheck disable=SC2086
  if eval "$verify_cmd"; then
    project_tmp_cleanup verify
    if [[ "$(sc_config '.temp_cleanup.sweep_after_verify' 'true')" == "true" ]]; then
      project_tmp_cleanup sweep
    fi
    return 0
  fi
  return 1
}

case "$cmd" in
  status)
    print_status
    ;;
  verify)
    run_verify
    ;;
  task-verify)
    task_verify "${2:-}"
    ;;
  gate-check)
    gate_check
    ;;
  next-task)
    plan_next_task
    ;;
  active)
    plan_active
    ;;
  pending)
    plan_pending_count
    ;;
  next_version)
    next_version
    ;;
  release-check)
    release_check
    ;;
  release-tag)
    release_tag
    ;;
  plan-check)
    plan_check
    ;;
  friction-log)
    friction_log "$@"
    ;;
  friction-report)
    friction_report
    ;;
  archive-check)
    archive_check
    ;;
  tmp-cleanup)
    project_tmp_cleanup "${2:-sweep}"
    ;;
  docs-init)
    docs_init "${@:2}"
    ;;
  help|-h|--help)
    cat <<EOF
用法: $0 [status|gate-check|task-verify|verify|plan-check|next-task|...]

  status        run Sprint 状态（默认）
  gate-check    run 硬闸门（PLANNING / PLAN_APPROVED）
  task-verify   任务级验收（优先验收列；可传 TASK_ID）
  verify        全量 VERIFY（打版前 / P0 闭合）
  plan-check    plan handoff 结构检查
  next-task     按执行顺序解析下一 ⬜ ID
  release-check P0 是否全部 ✅
  release-tag   在当前 HEAD 打 annotated tag（默认 patch bump）
  next_version  下一 patch 版本号
  friction-log  记一行摩擦数据（--task --rounds --rework --verify --note）
  friction-report  汇总摩擦数据（tasks · verify 通过率 · 平均轮次/返工）
  archive-check archive 域分层检查（根目录 flat 文件超阈值即 FAIL）
  tmp-cleanup      按 .growing/temp-cleanup.json 回收 /tmp（phase: test|verify|task-verify|sweep）
  docs-init     按 profile 铺 docs/ 文档骨架（号位=瀑布阶段；默认只铺必选号位）

环境变量（跨项目 · 名称见 workflow.json \`version_*_env\`）:
  VERSION_TAG_GLOB      git tag 匹配 glob（优先于 plan VERSION_LINE）
  RELEASE_VERSION_DEFAULT  无 tag 时起始版本（默认 plan VERSION_DEFAULT 或 0.1.0）
  RELEASE_BUMP          patch（默认）| minor | major
  RELEASE_ALLOW_MINOR   minor 时须 true（除非 release.json bump.auto_minor）
  RELEASE_ALLOW_MAJOR   major 时须 true（除非 release.json bump.auto_major）
  RELEASE_TAG_MSG       tag message（默认 Release <version>）

配置: .cursor/config/workflow.json
EOF
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
