#!/usr/bin/env bash
# run-stop — chain next task when autonomous
set -euo pipefail

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(cd "$HOOKS_DIR/.." && pwd)"
# shellcheck source=lib/config-load.sh
source "$HOOKS_DIR/lib/config-load.sh"
# shellcheck source=lib/json-utils.sh
source "$HOOKS_DIR/lib/json-utils.sh"

jw_resolve_project_root "$HOOKS_DIR"
jw_init_config "$CURSOR_DIR"

if [[ "$JW_HOOKS_ENABLED" != "true" || "$JW_WORKFLOW_ENABLED" != "true" ]]; then
  echo "{}"
  exit 0
fi

PLAN="$(jw_plan_path)"
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

if [[ "$loop_count" -ge "$max_loops" ]]; then
  json_followup "run: MAX_LOOPS=${max_loops}. Review plan and continue manually."
  exit 0
fi

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

pending="$(plan_pending_count)"
roadmap_open="$(plan_roadmap_open)"

if [[ "$active_status" == "🔧" || "$active_status" == "⬜" ]]; then
  json_followup "Continue run ACTIVE \`${active}\`: gate-check → implement → task-verify → commit."
  exit 0
fi

if grep -q '| ⚠️ |' "$PLAN" 2>/dev/null; then
  json_followup "run blocked (⚠️). Re-plan with \`plan\` before continuing."
  exit 0
fi

if [[ "$active_status" == "✅" && "$pending" -gt 0 ]]; then
  next="$(plan_next_task)"
  json_followup "run chain: \`${active}\` done. Set ACTIVE/NEXT to \`${next}\`."
  exit 0
fi

last_done="$(plan_last_done)"
if [[ -z "$active" && -n "$last_done" && "$pending" -gt 0 ]]; then
  next="$(plan_next_task)"
  json_followup "run chain: after \`${last_done}\`, continue with \`${next}\`."
  exit 0
fi

if [[ "$pending" -eq 0 ]]; then
  msg="run: sprint complete. Run verify and archive."
  if [[ "$roadmap_open" -gt 0 ]]; then
    msg="${msg} ROADMAP open — plan next sprint with \`plan\`."
  fi
  json_followup "$msg"
  exit 0
fi

echo "{}"
exit 0
