#!/usr/bin/env bash
# jwplan / jwrun CLI — 解析 plan.md、闸门、分层验收、Sprint 状态
set -euo pipefail

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CURSOR_DIR/.." && pwd)"
PLAN="$ROOT/plan.md"
# shellcheck source=../hooks/lib/plan-parse.sh
source "$CURSOR_DIR/hooks/lib/plan-parse.sh" "$PLAN"

cmd="${1:-status}"

next_version() {
  local latest ver major minor patch tag_glob default_ver version_line
  version_line="$(plan_meta "VERSION_LINE")"
  version_line="${version_line:-0.4}"
  tag_glob="${JW_VERSION_TAG_GLOB:-v${version_line}.*}"
  default_ver="${JW_VERSION_DEFAULT:-${version_line}.0}"
  latest="$(git -C "$ROOT" tag -l "$tag_glob" --sort=-v:refname 2>/dev/null | head -1 || true)"
  if [[ -z "$latest" ]]; then
    echo "$default_ver"
    return 0
  fi
  ver="${latest#v}"
  IFS='.' read -r major minor patch <<< "$ver"
  patch="${patch:-0}"
  echo "${major}.${minor}.$((patch + 1))"
}

release_check() {
  local p0_open
  p0_open="$(grep -E '\| P0 \|' "$PLAN" 2>/dev/null | grep -cv '| ✅ |' || true)"
  if [[ "$p0_open" -eq 0 ]]; then
    echo "ready"
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
  echo "=== jwrun gate-check ==="
  case "$reason" in
    OK)
      echo "OK: PLAN_APPROVED=$(plan_plan_approved) · SPRINT=$(plan_sprint) · ACTIVE=$(plan_active)"
      return 0
      ;;
    PLANNING)
      echo "BLOCK: PLANNING=true — 请先 /jwplan 完成规划并设 PLANNING:false"
      return 1
      ;;
    NO_APPROVAL)
      echo "BLOCK: 无 PLAN_APPROVED — 请先 /jwplan 确认规划并写入日期"
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
  echo "=== jwplan / jwrun plan-check ==="
  if [[ ! -f "$PLAN" ]]; then
    echo "FAIL: plan.md 不存在"
    return 1
  fi
  if ! grep -q '| ⬜ |' "$PLAN" 2>/dev/null && ! grep -q '| 🔧 |' "$PLAN" 2>/dev/null; then
    echo "WARN: 无活跃 ⬜/🔧 任务"
    issues=$((issues + 1))
  fi
  if [[ -z "$(plan_active)" ]]; then
    echo "WARN: <!-- ACTIVE --> 未设置"
    issues=$((issues + 1))
  fi
  if [[ -z "$(plan_sprint)" ]]; then
    echo "WARN: <!-- SPRINT --> 未设置"
    issues=$((issues + 1))
  fi
  if plan_planning; then
    echo "INFO: PLANNING=true — 仅 jwplan"
  elif [[ -z "$(plan_plan_approved)" ]]; then
    echo "FAIL: <!-- PLAN_APPROVED --> 未设置（jwrun 硬闸门）"
    issues=$((issues + 1))
  fi
  if ! grep -q '^\*\*执行顺序\*\*' "$PLAN" 2>/dev/null; then
    echo "WARN: 缺 **执行顺序** 行（NEXT 回退靠表序）"
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
  if [[ "$issues" -eq 0 ]]; then
    echo "OK: handoff 就绪"
    return 0
  fi
  echo "CHECK: ${issues} 项待补齐"
  return 0
}

task_verify() {
  local id="${1:-$(plan_active)}"
  local acc loc test_py test_path
  if [[ -z "$id" ]]; then
    echo "FAIL: 无 ACTIVE 任务 ID" >&2
    return 1
  fi
  acc="$(plan_task_acceptance "$id")"
  loc="$(plan_task_landing "$id")"
  echo "=== task-verify: ${id} ==="
  echo "验收: ${acc}"
  echo "落点: ${loc}"

  if [[ "$acc" =~ ^(\./|cd |python |pytest |grep |! grep |flake8 |black ) ]]; then
    echo "==> Running acceptance command"
    cd "$ROOT"
    # shellcheck disable=SC2086
    eval "$acc"
    return $?
  fi

  if [[ "$acc" == *pytest* || "$loc" == tests/* || "$loc" == *test_*.py* ]]; then
    test_py="$(echo "$acc $loc" | grep -oE 'test_[a-z_0-9]+' | head -1)"
    if [[ -z "$test_py" && "$loc" == *test_*.py* ]]; then
      test_py="$(basename "$loc" .py)"
    fi
    cd "$ROOT"
    if [[ "$loc" == tests/* && -f "$loc" ]]; then
      echo "==> pytest -q ${loc}"
      pytest -q "$loc"
      return $?
    fi
    if [[ -n "$test_py" ]]; then
      echo "==> pytest -q -k ${test_py#test_}"
      pytest -q -k "${test_py#test_}"
      return $?
    fi
    test_path="$(find tests -name "test_*.py" 2>/dev/null | head -1)"
    if [[ -n "$test_path" ]]; then
      echo "==> pytest -q ${test_path}"
      pytest -q "$test_path"
      return $?
    fi
  fi

  if [[ "$acc" == grep* ]]; then
    cd "$ROOT"
    # shellcheck disable=SC2086
    eval "$acc"
    return $?
  fi

  echo "SKIP: 验收列为描述性文字，请 Agent 按列手动执行；打版前须跑全量 VERIFY"
  echo "TIP: jwplan 验收列优先写可执行命令（如 pytest -q tests/unit/test_cli.py）"
  return 0
}

print_status() {
  echo "=== jwrun status ==="
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

run_verify() {
  local verify_cmd
  verify_cmd="$(plan_verify)"
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
  plan-check)
    plan_check
    ;;
  help|-h|--help)
    cat <<EOF
用法: $0 [status|gate-check|task-verify|verify|plan-check|next-task|...]

  status        jwrun Sprint 状态（默认）
  gate-check    jwrun 硬闸门（PLANNING / PLAN_APPROVED）
  task-verify   任务级验收（优先验收列；可传 TASK_ID）
  verify        全量 VERIFY（打版前 / P0 闭合）
  plan-check    jwplan handoff 结构检查
  next-task     按执行顺序解析下一 ⬜ ID
  release-check P0 是否全部 ✅
  next_version  下一 patch 版本号

环境变量:
  JW_VERSION_TAG_GLOB   git tag 匹配（默认读 plan VERSION_LINE，如 v0.4.*）
  JW_VERSION_DEFAULT    无 tag 时起始版本（默认 {VERSION_LINE}.0）
EOF
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
