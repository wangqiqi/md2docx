#!/usr/bin/env bash
# run-start — sessionStart: inject plan context
set -euo pipefail

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(cd "$HOOKS_DIR/.." && pwd)"
# shellcheck source=lib/config-load.sh
source "$HOOKS_DIR/lib/config-load.sh"
# shellcheck source=lib/json-utils.sh
source "$HOOKS_DIR/lib/json-utils.sh"

jw_resolve_project_root "$HOOKS_DIR"
jw_init_config "$CURSOR_DIR"

jw_role_hint() {
  local cursor_dir="$1"
  local roles_file="${cursor_dir}/config/roles.json"
  local role_id
  role_id="$(jw_cfg '.role.default' 'professional')"
  [[ -f "$roles_file" ]] || return 0
  local py
  py="$(jw_python 2>/dev/null)" || return 0
  "$py" - "$roles_file" "$role_id" <<'PY'
import json, sys
for p in json.load(open(sys.argv[1])).get("personas", []):
    if p.get("id") == sys.argv[2]:
        print(p.get("hint", ""))
        break
PY
}

if [[ "$JW_HOOKS_ENABLED" != "true" || "$JW_WORKFLOW_ENABLED" != "true" ]]; then
  echo "{}"
  exit 0
fi

PLAN="$(jw_plan_path)"
# shellcheck source=lib/plan-parse.sh
source "$HOOKS_DIR/lib/plan-parse.sh" "$PLAN"

input="$(cat)"
conversation_id="$(json_get "$input" conversation_id)"

STATE_DIR="$JW_PROJECT_ROOT/.cursor/hooks/state"
mkdir -p "$STATE_DIR"

active="$(plan_active)"
verify="$(plan_verify)"
autonomous="false"
if plan_autonomous; then autonomous="true"; fi
planning="false"
if plan_planning; then planning="true"; fi
sprint="$(plan_sprint)"
approved="$(plan_plan_approved)"
pending="$(plan_pending_count)"
gate="$(plan_gate_ok || true)"
status=""
if [[ -n "$active" ]]; then
  status="$(plan_task_status "$active")"
fi

cat > "$STATE_DIR/run.json" <<EOF
{
  "conversation_id": "$conversation_id",
  "active_id": "$active",
  "active_status": "$status",
  "sprint": "$sprint",
  "plan_approved": "$approved",
  "planning": $planning,
  "gate": "$gate",
  "verify_cmd": "$verify",
  "autonomous": $autonomous,
  "pending_count": $pending,
  "session_started_at": "$(iso8601_now)"
}
EOF

if [[ ! -f "$PLAN" ]]; then
  echo "{}"
  exit 0
fi

if [[ "$planning" == "true" ]]; then
  ctx="## plan in progress
- **SPRINT**: \`${sprint:-unset}\`
- Load skill \`plan\`; keep \`PLANNING: true\` until handoff
- Handoff: \`PLANNING: false\` + \`PLAN_APPROVED\` + plan-check + gate-check → \`run\`"
  json_additional_context "$ctx"
  exit 0
fi

if [[ "$gate" != "OK" ]]; then
  ctx="## run gate blocked (${gate})
- Complete \`plan\` and set \`PLAN_APPROVED\`
- Run: \`./.cursor/bin/runner.sh gate-check\`"
  json_additional_context "$ctx"
  exit 0
fi

if [[ "$autonomous" == "true" && -n "$active" ]]; then
  ctx="## run autonomous
- **SPRINT**: \`${sprint:-unset}\` · **ACTIVE**: \`$active\` (${status:-unknown})
- **Verify**: \`./.cursor/bin/runner.sh task-verify\`; release \`${verify}\`
- Load \`run\`: gate-check → implement → task-verify → commit"
  role_hint="$(jw_role_hint "$CURSOR_DIR" 2>/dev/null || true)"
  if [[ -n "$role_hint" ]]; then
    ctx="${ctx}
- **Persona hint**: ${role_hint}"
  fi
  json_additional_context "$ctx"
else
  role_hint="$(jw_role_hint "$CURSOR_DIR" 2>/dev/null || true)"
  if [[ -n "$role_hint" ]]; then
    json_additional_context "## session
- **Persona hint**: ${role_hint}"
  else
    echo "{}"
  fi
fi

exit 0
