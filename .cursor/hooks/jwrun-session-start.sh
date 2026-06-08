#!/usr/bin/env bash
# jwrun — sessionStart：注入 ACTIVE / 闸门上下文
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [[ ! -f "$ROOT/plan.md" ]]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
fi

PLAN="$ROOT/plan.md"
# shellcheck source=lib/plan-parse.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/plan-parse.sh" "$PLAN"

input="$(cat)"
conversation_id="$(echo "$input" | jq -r '.conversation_id // empty')"

STATE_DIR="$ROOT/.cursor/hooks/state"
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

cat > "$STATE_DIR/jwrun.json" <<EOF
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
  "session_started_at": "$(date -Iseconds)"
}
EOF

if [[ "$planning" == "true" ]]; then
  ctx="## jwplan 规划进行中
- **SPRINT**: \`${sprint:-（未设）}\`
- 加载 skill \`jwplan-skill\`；第一步保持 \`PLANNING: true\`；有疑 **AskQuestion**
- handoff：\`PLANNING: false\` + \`PLAN_APPROVED\` + \`plan-check\` + \`gate-check\` → \`/jwrun\`"
  echo "{\"additional_context\": $(echo "$ctx" | jq -Rs .)}"
  exit 0
fi

if [[ "$gate" != "OK" ]]; then
  ctx="## jwrun 闸门未通过（${gate}）
- 请先 \`/jwplan\` 完成规划并写入 \`PLAN_APPROVED\`
- 校验：\`./.cursor/bin/dev_runner.sh gate-check\`"
  echo "{\"additional_context\": $(echo "$ctx" | jq -Rs .)}"
  exit 0
fi

if [[ "$autonomous" == "true" && -n "$active" ]]; then
  ctx="## jwrun 自治 Sprint
- **SPRINT**: \`${sprint:-（未设）}\` · **APPROVED**: ${approved}
- **ACTIVE**: \`$active\`（${status:-未知}）
- **验收**: 任务级 \`./.cursor/bin/dev_runner.sh task-verify\`；打版前 \`${verify}\`
- **待办**: ${pending} 项 ⬜ · **NEXT**: \`$(plan_next_task)\`
- 加载 skill \`jwrun-skill\`：gate-check → 实现 → task-verify → commit
- **自治**：直接执行不问确认；仅高风险删除（→ \`archive/…_删除_…\`）或项目外操作须停并征得同意"
  echo "{\"additional_context\": $(echo "$ctx" | jq -Rs .)}"
else
  echo "{}"
fi

exit 0
