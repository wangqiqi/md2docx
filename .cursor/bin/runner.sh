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

PLAN_REL="$(sc_config '.plan_file' '.cursorGrowth/plan.md')"
PLAN="$ROOT/$PLAN_REL"
# Legacy: root plan.md before .cursorGrowth migration
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
  plan_default="$(plan_meta "VERSION_DEFAULT")"
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

bump_version() {
  local bump="${1:-patch}"
  local latest ver major minor patch tag_glob default_ver version_line
  version_line="$(plan_meta "VERSION_LINE")"
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
  local bump="${RELEASE_BUMP:-$(plan_meta RELEASE_BUMP)}"
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
  version_line="$(plan_meta "VERSION_LINE")"
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
      echo "OK: PLAN_APPROVED=$(plan_plan_approved) · SPRINT=$(plan_sprint) · ACTIVE=$(plan_active)"
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
    echo "FAIL: plan 不存在（config plan_file 或 .cursorGrowth/plan.md）"
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
  if [[ -z "$(plan_sprint)" ]]; then
    echo "WARN: <!-- SPRINT --> 未设置"
    issues=$((issues + 1))
  fi
  if plan_planning; then
    echo "INFO: PLANNING=true — 仅 plan"
  elif [[ -z "$(plan_plan_approved)" ]]; then
    echo "FAIL: <!-- PLAN_APPROVED --> 未设置（run 硬闸门）"
    issues=$((issues + 1))
  fi
  if ! grep -qE '^\*\*(执行顺序|Order)\*\*' "$PLAN" 2>/dev/null; then
    echo "WARN: 缺 **执行顺序** 行（兼容 **Order**；NEXT 回退靠表序）"
    issues=$((issues + 1))
  fi
  local line cols bad=0
  while IFS= read -r line; do
    [[ "$line" =~ \|[[:space:]]*(⬜|🔧)[[:space:]]*\| ]] || continue
    cols="$(echo "$line" | awk -F'|' '{print NF}')"
    if [[ "$cols" -lt 8 ]]; then
      bad=$((bad + 1))
    fi
  done < <(grep -E '\| (⬜|🔧) \|' "$PLAN" 2>/dev/null || true)
  if [[ "$bad" -gt 0 ]]; then
    echo "WARN: ${bad} 行活跃任务可能缺「验收」或「落点」"
    issues=$((issues + 1))
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
      echo "WARN: Sprint 标题仍为「进行中」— 收尾时改为 Completed/已完成（见 .cursorGrowth/learn/plan-conventions.md）"
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
  return 0
}

task_verify() {
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

  if [[ "$acc" =~ ^(\./|cd |npm |pnpm |npx |pytest |grep |cargo |go test|make |bash ) ]]; then
    echo "==> Running acceptance command"
    cd "$ROOT"
    # shellcheck disable=SC2086
    eval "$acc"
    return $?
  fi

  if [[ "$HEURISTICS_ENABLED" != "true" ]]; then
    echo "SKIP: heuristics disabled — run acceptance command in plan or verify manually"
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

  # Scaffold-aligned fallback (when acceptance is descriptive or empty)
  local test_script="${FALLBACK_TEST#./}"
  local verify_script="${FALLBACK_VERIFY#./}"
  if [[ -f "$ROOT/$test_script" ]]; then
    echo "==> heuristics fallback: $FALLBACK_TEST"
    cd "$ROOT"
    bash "$test_script"
    return $?
  fi
  if [[ -f "$ROOT/$verify_script" && "$acc" == *verify* ]]; then
    echo "==> heuristics fallback: $FALLBACK_VERIFY"
    cd "$ROOT"
    bash "$verify_script"
    return $?
  fi

  echo "SKIP: 验收列为描述性文字，请 Agent 按列手动执行；打版前须跑全量 VERIFY"
  echo "TIP: plan 验收列优先写 $FALLBACK_TEST 或 npm test / pytest 等可执行命令"
  return 0
}

print_status() {
  echo "=== run status ==="
  echo "PLANNING:   $(plan_meta PLANNING || echo false)"
  echo "SPRINT:     $(plan_sprint || echo '(none)')"
  echo "APPROVED:   $(plan_plan_approved || echo '(none)')"
  echo "AUTONOMOUS: $(plan_meta AUTONOMOUS || echo false)"
  echo "ACTIVE:     $(plan_active || echo '(none)')"
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
  echo "==> Full VERIFY: $verify_cmd"
  cd "$ROOT"
  # shellcheck disable=SC2086
  eval "$verify_cmd"
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

环境变量（跨项目 · 名称见 workflow.json `version_*_env`）:
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
