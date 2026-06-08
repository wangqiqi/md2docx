#!/usr/bin/env bash
# jwrun — stop：自治模式下链式触发下一任务
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [[ ! -f "$ROOT/plan.md" ]]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
fi

PLAN="$ROOT/plan.md"
# shellcheck source=lib/plan-parse.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/plan-parse.sh" "$PLAN"

input="$(cat)"
status="$(echo "$input" | jq -r '.status // empty')"
loop_count="$(echo "$input" | jq -r '.loop_count // 0')"
max_loops="$(plan_max_loops)"

if [[ "$status" != "completed" ]]; then
  echo "{}"
  exit 0
fi

if plan_planning; then
  echo "{}"
  exit 0
fi

if ! plan_autonomous; then
  echo "{}"
  exit 0
fi

if [[ "$loop_count" -ge "$max_loops" ]]; then
  echo "{\"followup_message\": \"jwrun 已达 MAX_LOOPS=${max_loops}，请人工 review plan.md 后再继续。\"}"
  exit 0
fi

gate="$(plan_gate_ok || true)"
if [[ "$gate" != "OK" ]]; then
  if [[ "$gate" == "NO_APPROVAL" ]]; then
    echo "{\"followup_message\": \"jwrun 闸门：无 PLAN_APPROVED。请 /jwplan 确认规划后再执行。\"}"
  else
    echo "{\"followup_message\": \"jwrun 闸门：PLANNING=true。请 /jwplan 完成 handoff（PLANNING:false + PLAN_APPROVED）后再执行。\"}"
  fi
  exit 0
fi

active="$(plan_active)"
active_status=""
if [[ -n "$active" ]]; then
  active_status="$(plan_task_status "$active")"
fi

pending="$(plan_pending_count)"
roadmap_open="$(plan_roadmap_open)"

if [[ "$active_status" == "🔧" || "$active_status" == "⬜" ]]; then
  msg="继续 jwrun：ACTIVE \`${active}\`。加载 skill \`jwrun-skill\`：gate-check → 实现 → \`./.cursor/bin/dev_runner.sh task-verify\` → 更新 plan/CHANGELOG → **git commit**。"
  echo "{\"followup_message\": $(echo "$msg" | jq -Rs .)}"
  exit 0
fi

if grep -q '| ⚠️ |' "$PLAN" 2>/dev/null; then
  echo "{\"followup_message\": \"jwrun 遇 ⚠️ 阻塞，请 /jwplan 重拆任务或改闭合条件后再 /jwrun。\"}"
  exit 0
fi

if [[ "$active_status" == "✅" && "$pending" -gt 0 ]]; then
  next="$(plan_next_task)"
  msg="jwrun 链式继续：\`${active}\` 已完成。将 \`${next}\` 写入 ACTIVE/NEXT、标 🔧，执行 jwrun-skill 单轮（task-verify + commit）。"
  echo "{\"followup_message\": $(echo "$msg" | jq -Rs .)}"
  exit 0
fi

last_done="$(plan_last_done)"
if [[ -z "$active" && -n "$last_done" && "$pending" -gt 0 ]]; then
  next="$(plan_next_task)"
  msg="jwrun 链式继续：\`${last_done}\` 已提交。ACTIVE/NEXT → \`${next}\`，标 🔧，执行 jwrun-skill 单轮。"
  echo "{\"followup_message\": $(echo "$msg" | jq -Rs .)}"
  exit 0
fi

if [[ "$pending" -eq 0 ]]; then
  msg="jwrun Sprint 全部完成。执行 §7 闭合归档（全量 verify → archive）；打版应已在每任务 §6 完成。"
  if [[ "$roadmap_open" -gt 0 ]]; then
    msg="${msg} ROADMAP 尚有 ${roadmap_open} 项未立项 → 打版后请 **/jwplan** 规划下一 Sprint。"
  else
    msg="${msg} 建议关闭 <!-- AUTONOMOUS: true -->。"
  fi
  echo "{\"followup_message\": $(echo "$msg" | jq -Rs .)}"
  exit 0
fi

echo "{}"
exit 0
