#!/usr/bin/env bash
# run-start — sessionStart: inject plan context
set -euo pipefail

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$(cd "$HOOKS_DIR/.." && pwd)"
# shellcheck source=lib/config-load.sh
source "$HOOKS_DIR/lib/config-load.sh"
# shellcheck source=lib/json-utils.sh
source "$HOOKS_DIR/lib/json-utils.sh"

sc_resolve_project_root "$HOOKS_DIR"
sc_init_config "$CURSOR_DIR"

sc_role_hint() {
  local cursor_dir="$1"
  local roles_file="${cursor_dir}/config/roles.json"
  local role_id project_root session_file
  role_id="$(sc_cfg '.role.default' 'dashu')"
  project_root="${SC_PROJECT_ROOT:-}"
  session_file="${project_root}/.cursorGrowth/session/persona.json"
  if [[ -n "$project_root" && -f "$session_file" ]]; then
    local sid
    sid="$(json_get "$(cat "$session_file")" persona_id 2>/dev/null || true)"
    if [[ -z "$sid" ]]; then
      sid="$(json_get "$(cat "$session_file")" id 2>/dev/null || true)"
    fi
    if [[ -n "$sid" && "$sid" != "null" ]]; then
      role_id="$sid"
    fi
  fi
  [[ -f "$roles_file" ]] || return 0
  local py
  py="$(sc_python 2>/dev/null)" || return 0
  "$py" - "$roles_file" "$role_id" <<'PY'
import json, sys
q = sys.argv[2].strip().lower()
for p in json.load(open(sys.argv[1], encoding="utf-8")).get("personas", []):
    keys = {str(p.get("id","")).lower(), str(p.get("role_name") or p.get("name") or "").lower(), str(p.get("given_name","")).lower()}
    for n in p.get("nicknames") or []:
        keys.add(str(n).lower())
    if q in keys or p.get("id") == sys.argv[2]:
        pid = p.get("id") or ""
        role = p.get("role_name") or p.get("name") or pid
        tone = p.get("tone") or ""
        attitude = p.get("attitude") or ""
        intensity = p.get("intensity", "")
        hint = p.get("hint") or ""
        pers = p.get("personality") or ""
        cues = p.get("voice_cues") or {}
        cue_parts = []
        if cues.get("address_user"):
            cue_parts.append(f"addr={cues['address_user']}")
        if cues.get("rhythm"):
            cue_parts.append(f"rhythm={cues['rhythm']}")
        if cues.get("flavor"):
            cue_parts.append(f"flavor={cues['flavor']}")
        if cues.get("never"):
            cue_parts.append(f"never={cues['never']}")
        emo = p.get("emotion_cues") or {}
        emo_parts = []
        for ek in ("on_success", "on_blocker", "on_decision", "on_grind"):
            if emo.get(ek):
                emo_parts.append(f"{ek}={emo[ek]}")
        emo_str = " · ".join(emo_parts)
        cue_str = " · ".join(cue_parts)
        examples = p.get("speech_examples") or []
        ex = (" · ex: " + " / ".join(examples[:4])) if examples else ""
        parts = [
            f"id={pid}",
            f"role={role}",
            f"tone={tone}",
            f"attitude={attitude}",
            f"intensity={intensity}",
            f"skills=full",
            pers,
            hint,
            cue_str,
            emo_str,
        ]
        line = " · ".join(p for p in parts if p) + ex
        print(line.strip(" ·"))
        break
PY
}

if [[ "$SC_HOOKS_ENABLED" != "true" || "$SC_WORKFLOW_ENABLED" != "true" ]]; then
  echo "{}"
  exit 0
fi

PLAN="$(sc_plan_path)"
# shellcheck source=lib/plan-parse.sh
source "$HOOKS_DIR/lib/plan-parse.sh" "$PLAN"

input="$(cat)"
conversation_id="$(json_get "$input" conversation_id)"

STATE_DIR="$SC_PROJECT_ROOT/.cursor/hooks/state"
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
  ctx="## run autonomous (Sprint chain)
- **SPRINT**: \`${sprint:-unset}\` · **ACTIVE**: \`$active\` (${status:-unknown}) · pending=${pending}
- User authorized **one /run** — **continue all TASK in this session** until decision or sprint done; **do not wait** for another \`/run\`
- **Interrupt only**: decision_needed · blocker · high_risk · release · goal_drift (workflow.json autonomy.interrupt_on)
- **Verify**: \`./.cursor/bin/runner.sh task-verify\`; release \`${verify}\`
- Load \`run\`: gate-check → implement → task-verify → commit → next ACTIVE"
  role_hint="$(sc_role_hint "$CURSOR_DIR" 2>/dev/null || true)"
  if [[ -n "$role_hint" ]]; then
    ctx="${ctx}
- **Persona hint**: ${role_hint}"
  fi
  json_additional_context "$ctx"
else
  role_hint="$(sc_role_hint "$CURSOR_DIR" 2>/dev/null || true)"
  if [[ -n "$role_hint" ]]; then
    json_additional_context "## session
- **Persona hint**: ${role_hint}"
  else
    echo "{}"
  fi
fi

exit 0
