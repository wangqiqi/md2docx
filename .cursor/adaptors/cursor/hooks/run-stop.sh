#!/usr/bin/env bash
# run-stop — chain next task when autonomous
set -euo pipefail

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/config-load.sh
source "$HOOKS_DIR/lib/config-load.sh"
# shellcheck source=lib/json-utils.sh
source "$HOOKS_DIR/lib/json-utils.sh"
_pack="$(sc_cursor_pack_from_dir "$HOOKS_DIR")"
CURSOR_DIR="${_pack:-$(cd "$HOOKS_DIR/../.." && pwd)}"

sc_resolve_project_root "$HOOKS_DIR"
sc_init_config "$CURSOR_DIR"

if [[ "$SC_HOOKS_ENABLED" != "true" || "$SC_WORKFLOW_ENABLED" != "true" ]]; then
  echo "{}"
  exit 0
fi

PLAN="$(sc_plan_path)"
# shellcheck source=lib/plan-parse.sh
source "$HOOKS_DIR/lib/plan-parse.sh" "$PLAN"

input="$(cat)"
status="$(json_get "$input" status)"
loop_count="$(json_get "$input" loop_count)"
loop_count="${loop_count:-0}"
max_loops="$(plan_max_loops)"

if [[ "$status" != "completed" ]]; then
  echo "{}"
  exit 0
fi

if [[ ! -f "$PLAN" ]] || plan_planning || ! plan_autonomous; then
  echo "{}"
  exit 0
fi

# 已闭合且无待办：无自治链可跑（先于 MAX_LOOPS / gate，避免收尾后反复 followup）
if plan_autonomous_chain_idle; then
  echo "{}"
  exit 0
fi

if [[ "$loop_count" -ge "$max_loops" ]]; then
  json_followup "run: MAX_LOOPS=${max_loops}. Review plan and continue manually."
  exit 0
fi

pending="$(plan_pending_count)"

gate="$(plan_gate_ok || true)"
if [[ "$gate" != "OK" ]]; then
  if [[ "$gate" == "NO_APPROVAL" ]]; then
    json_followup "run gate: missing PLAN_APPROVED. Run \`plan\` first."
  else
    json_followup "run gate: PLANNING=true. Complete plan handoff first."
  fi
  exit 0
fi

active="$(plan_active)"
active_status=""
if [[ -n "$active" ]]; then
  active_status="$(plan_task_status "$active")"
fi

roadmap_open="$(plan_roadmap_open)"

if [[ "$active_status" == "🔧" || "$active_status" == "⬜" ]]; then
  json_followup "AUTONOMOUS: continue ACTIVE \`${active}\` in this session — gate-check → implement → task-verify → commit. **Do not wait for user /run**."
  exit 0
fi

if grep -q '| ⚠️ |' "$PLAN" 2>/dev/null; then
  json_followup "run blocked (⚠️). Re-plan with \`plan\` before continuing."
  exit 0
fi

if [[ "$active_status" == "✅" && "$pending" -gt 0 ]]; then
  next="$(plan_next_task)"
  json_followup "AUTONOMOUS chain: \`${active}\` done → continue \`${next}\` immediately in this session. **No second /run** unless decision needed."
  exit 0
fi

last_done="$(plan_last_done)"
if [[ -z "$active" && -n "$last_done" && "$pending" -gt 0 ]]; then
  next="$(plan_next_task)"
  json_followup "AUTONOMOUS chain: after \`${last_done}\` → continue \`${next}\` immediately. **No second /run** unless decision needed."
  exit 0
fi

if [[ "$pending" -eq 0 ]]; then
  msg="AUTONOMOUS: sprint complete — verify, archive, reconcile plan. Ask user about /release if needed."
  if [[ "$roadmap_open" -gt 0 ]]; then
    msg="${msg} ROADMAP open — plan next sprint with \`plan\`."
  fi
  json_followup "$msg"
  exit 0
fi

echo "{}"
exit 0
