#!/usr/bin/env bash
# Smoke-test runner.sh against template plan (no side effects on repo plan.md)
set -euo pipefail

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CURSOR_DIR/.." && pwd)"
# shellcheck source=../lib/platform.sh
source "$CURSOR_DIR/lib/platform.sh"
# shellcheck source=../lib/temp-cleanup.sh
source "$CURSOR_DIR/lib/temp-cleanup.sh"
sc_temp_trap_cleanup
# Git Bash / Windows 可能只有 python；勿硬编码 python3
PYTHON_BIN="${PYTHON_BIN:-$(command -v python3 || command -v python || true)}"
[[ -n "$PYTHON_BIN" ]] || { echo "FAIL: python required for runner smoke"; exit 1; }
sc_mktemp_file sc-runner-smoke.plan
TMP_PLAN="$SC_MKTEMP_LAST"

cp "$CURSOR_DIR/templates/plan.md" "$TMP_PLAN"

# Template default is closed/empty; smoke needs an active sprint fixture.
# 不用 `sed -i`（BSD/macOS 需要 -i ''），改走临时文件。
sed \
  -e 's/<!-- ACTIVE: (none) -->/<!-- ACTIVE: TASK-001 -->/' \
  -e 's/<!-- PLAN_APPROVED: (none) -->/<!-- PLAN_APPROVED: 2099-01-01 -->/' \
  -e 's/<!-- SPRINT_STATUS: closed -->/<!-- SPRINT_STATUS: active -->/' \
  -e 's/<!-- SPRINT: (none) -->/<!-- SPRINT: SPRINT-01 -->/' \
  "$TMP_PLAN" > "$TMP_PLAN.new"
mv "$TMP_PLAN.new" "$TMP_PLAN"

# shellcheck source=../hooks/lib/plan-parse.sh
source "$CURSOR_DIR/hooks/lib/plan-parse.sh" "$TMP_PLAN"

echo "=== runner smoke ==="

active="$(plan_active)"
[[ "$active" == "TASK-001" ]] || { echo "FAIL: expected TASK-001, got $active"; exit 1; }
echo "OK  plan_active=$active"

approved="$(plan_plan_approved)"
[[ -n "$approved" ]] || { echo "FAIL: PLAN_APPROVED empty"; exit 1; }
echo "OK  PLAN_APPROVED set"

gate="$(plan_gate_ok)"
[[ "$gate" == "OK" ]] || { echo "FAIL: gate=$gate"; exit 1; }
echo "OK  gate-check would pass"

next="$(plan_next_task)"
echo "OK  next-task=$next"

bash "$CURSOR_DIR/bin/runner.sh" help 2>/dev/null | grep -q 'release-tag' \
  && echo "OK  runner help lists release-tag" \
  || { echo "FAIL: runner help missing release-tag"; exit 1; }

# help 不得有命令替换噪音（回归：未转义反引号）
help_err="$(bash "$CURSOR_DIR/bin/runner.sh" help 2>&1 >/dev/null)"
[[ -z "$help_err" ]] || { echo "FAIL: runner help wrote to stderr: $help_err"; exit 1; }
echo "OK  runner help is clean"

# 闸门 fail-closed：未批准的模板 plan 必须 BLOCK（P0-3 回归）
(
  # shellcheck source=../hooks/lib/plan-parse.sh
  source "$CURSOR_DIR/hooks/lib/plan-parse.sh" "$CURSOR_DIR/templates/plan.md"
  g="$(plan_gate_ok)" || true
  [[ "$g" == "NO_APPROVAL" ]] || { echo "FAIL: template gate=$g (expect NO_APPROVAL)"; exit 1; }
  echo "OK  unapproved template blocks"
) || exit 1

# 造一个含 TASK-001 的临时项目；stdout 只回目录路径
mk_plan_project() {
  local acc="$1" d
  sc_mktemp_dir sc-runner-smoke
  d="$SC_MKTEMP_LAST"
  mkdir -p "$d/.cursor" "$d/.growing"
  sc_stage_cursor_pack "$CURSOR_DIR" "$d/.cursor"
  echo "# t" > "$d/README.md"
  {
    echo '<!-- PLANNING: false -->'
    echo '<!-- PLAN_APPROVED: 2026-09-23 -->'
    echo '<!-- SPRINT: SPRINT-TV -->'
    echo '<!-- ACTIVE: TASK-001 -->'
    echo '<!-- SPRINT_STATUS: active -->'
    echo '<!-- VERIFY: ./README.md -->'
    echo '**执行顺序**: `TASK-001`'
    echo ''
    echo '| ID | Task | Priority | Status | Acceptance | Target |'
    echo '|----|------|----------|--------|------------|--------|'
    echo "| TASK-001 | t | P0 | ⬜ | ${acc} | src/ |"
  } > "$d/.growing/plan.md"
  printf '%s' "$d"
}

# 断言某命令在某临时项目里的退出码类别
smoke_assert() {
  local d="$1" expect="$2" label="$3"
  shift 3
  local rc=0
  ( cd "$d" && "$@" ) >/dev/null 2>&1 || rc=$?
  if { [[ "$expect" == "fail" && "$rc" -ne 0 ]] || [[ "$expect" == "pass" && "$rc" -eq 0 ]]; }; then
    echo "OK  $label"
  else
    echo "FAIL: $label (rc=$rc, expect=$expect)"; rm -rf "$d"; exit 1
  fi
}

# task-verify fail-closed 回归（B1）
D="$(mk_plan_project '功能正常，界面没问题')"
smoke_assert "$D" fail "task-verify 描述性验收 FAIL（防假完成）" bash .cursor/bin/runner.sh task-verify TASK-001
smoke_assert "$D" fail "plan-check prose 验收 FAIL（B2）" bash .cursor/bin/runner.sh plan-check
rm -rf "$D"

D="$(mk_plan_project 'manual: 人工走查首页并截图留证')"
smoke_assert "$D" pass "task-verify manual 豁免 PASS" bash .cursor/bin/runner.sh task-verify TASK-001
smoke_assert "$D" pass "plan-check manual 验收 PASS（B2）" bash .cursor/bin/runner.sh plan-check
rm -rf "$D"

D="$(mk_plan_project "bash -c 'exit 0'")"
smoke_assert "$D" pass "task-verify 可执行命令 PASS" bash .cursor/bin/runner.sh task-verify TASK-001
smoke_assert "$D" pass "plan-check 可执行验收 PASS（B2）" bash .cursor/bin/runner.sh plan-check
rm -rf "$D"

D="$(mk_plan_project "node -e 'process.exit(0)'")"
smoke_assert "$D" pass "task-verify node 行首命令 PASS" bash .cursor/bin/runner.sh task-verify TASK-001
rm -rf "$D"

D="$(mk_plan_project "同上 · \`node -e 'process.exit(0)'\`")"
smoke_assert "$D" pass "task-verify 反引号 node 命令 PASS" bash .cursor/bin/runner.sh task-verify TASK-001
rm -rf "$D"

D="$(mk_plan_project "bash -c 'exit 3'")"
smoke_assert "$D" fail "task-verify 可执行命令失败时 FAIL" bash .cursor/bin/runner.sh task-verify TASK-001
rm -rf "$D"

# release-tag 发版闸门：verify 红 → BLOCK
D="$(mk_plan_project "bash -c 'exit 0'")"
out="$( cd "$D" && RELEASE_VERIFY_CMD='bash -c "exit 3"' bash .cursor/bin/runner.sh release-tag 2>&1 || true )"
case "$out" in
  *"BLOCK: 发版前 verify"*) echo "OK  release-tag verify-red blocks" ;;
  *) echo "FAIL: release-tag verify 红应 BLOCK: $out"; rm -rf "$D"; exit 1 ;;
esac
out="$( cd "$D" && RELEASE_SKIP_VERIFY=1 RELEASE_VERIFY_CMD='bash -c "exit 3"' bash .cursor/bin/runner.sh release-tag 2>&1 || true )"
case "$out" in
  *RELEASE_SKIP_VERIFY*) echo "OK  release-tag skip leaves trace (WARN)" ;;
  *) echo "FAIL: skip 路径无留痕: $out"; rm -rf "$D"; exit 1 ;;
esac
rm -rf "$D"

# 摩擦日志（B5）：必须是合法 JSONL，report 可聚合
D="$(mk_plan_project "bash -c 'exit 0'")"
( cd "$D" && bash .cursor/bin/runner.sh friction-log --task TASK-001 --rounds 2 --rework 0 --verify pass --note 'x"y' ) >/dev/null 2>&1
( cd "$D" && bash .cursor/bin/runner.sh friction-log --task TASK-002 --rounds 4 --rework 1 --verify fail ) >/dev/null 2>&1
if [[ -f "$D/.growing/logs/friction.jsonl" ]] && "$PYTHON_BIN" -c "
import json,sys
[json.loads(l) for l in open(sys.argv[1])]" "$D/.growing/logs/friction.jsonl" 2>/dev/null; then
  echo "OK  friction.jsonl is valid JSONL"
else
  echo "FAIL: friction.jsonl invalid"; rm -rf "$D"; exit 1
fi
rep="$( cd "$D" && bash .cursor/bin/runner.sh friction-report )"
case "$rep" in
  *"tasks=2"*"verify_pass=1"*"verify_fail=1"*) echo "OK  friction-report aggregates ($rep)" ;;
  *) echo "FAIL: friction-report unexpected: $rep"; rm -rf "$D"; exit 1 ;;
esac
rm -rf "$D"

# run-stop：SPRINT_STATUS closed + 无待办 → 不再 followup（自治收尾死循环回归）
mk_closed_autonomous_plan() {
  local d
  sc_mktemp_dir sc-runner-smoke
  d="$SC_MKTEMP_LAST"
  mkdir -p "$d/.cursor" "$d/.growing"
  sc_stage_cursor_pack "$CURSOR_DIR" "$d/.cursor"
  echo "# t" > "$d/README.md"
  {
    echo '<!-- PLANNING: false -->'
    echo '<!-- PLAN_APPROVED: 2026-10-15 user -->'
    echo '<!-- AUTONOMOUS: true -->'
    echo '<!-- SPRINT: SPRINT-01-textbooks -->'
    echo '<!-- SPRINT_STATUS: closed -->'
    echo '<!-- ACTIVE: (none) -->'
    echo '<!-- NEXT: (none) -->'
    echo '<!-- LAST_DONE: TASK-007 -->'
    echo '**执行顺序**: `TASK-007`'
    echo ''
    echo '| ID | Task | Priority | Status | Acceptance | Target |'
    echo '|----|------|----------|--------|------------|--------|'
    echo '| TASK-007 | done | P0 | ✅ | bash -c true | src/ |'
  } > "$d/.growing/plan.md"
  printf '%s' "$d"
}

D="$(mk_closed_autonomous_plan)"
out="$( ( cd "$D" && printf '%s' '{"status":"completed","loop_count":0}' | bash .cursor/hooks/run-stop.sh ) )"
[[ "$out" == "{}" ]] || { echo "FAIL: run-stop on closed sprint expected {}, got: $out"; rm -rf "$D"; exit 1; }
echo "OK  run-stop silent when SPRINT_STATUS closed"
rm -rf "$D"

# closed + 无 PLAN_APPROVED（收尾后常见）→ 仍静默，勿 gate followup
mk_closed_no_approval() {
  local d
  sc_mktemp_dir sc-runner-smoke
  d="$SC_MKTEMP_LAST"
  mkdir -p "$d/.cursor" "$d/.growing"
  sc_stage_cursor_pack "$CURSOR_DIR" "$d/.cursor"
  echo "# t" > "$d/README.md"
  {
    echo '<!-- PLANNING: false -->'
    echo '<!-- PLAN_APPROVED: (none) -->'
    echo '<!-- AUTONOMOUS: true -->'
    echo '<!-- SPRINT_STATUS: closed -->'
    echo '<!-- ACTIVE: (none) -->'
    echo '| TASK-007 | done | P0 | ✅ | bash -c true | src/ |'
  } > "$d/.growing/plan.md"
  printf '%s' "$d"
}
D="$(mk_closed_no_approval)"
out="$( ( cd "$D" && printf '%s' '{"status":"completed","loop_count":0}' | bash .cursor/hooks/run-stop.sh ) )"
[[ "$out" == "{}" ]] || { echo "FAIL: run-stop closed without approval expected {}, got: $out"; rm -rf "$D"; exit 1; }
echo "OK  run-stop silent when closed (no PLAN_APPROVED)"
out="$( ( cd "$D" && printf '%s' '{"conversation_id":"c1"}' | bash .cursor/hooks/run-start.sh ) )"
case "$out" in
  *"gate blocked"*|*"PLAN_APPROVED"*) echo "FAIL: run-start on closed idle must not gate-block: $out"; rm -rf "$D"; exit 1 ;;
esac
echo "OK  run-start silent on closed idle (no gate blocked)"
out="$( ( cd "$D" && printf '%s' '{"status":"completed","loop_count":99}' | bash .cursor/hooks/run-stop.sh ) )"
[[ "$out" == "{}" ]] || { echo "FAIL: run-stop closed at MAX_LOOPS expected {}, got: $out"; rm -rf "$D"; exit 1; }
echo "OK  run-stop silent when closed (ignores MAX_LOOPS)"
rm -rf "$D"

# closed 但 ACTIVE 仍指向旧 ID → run-start 勿注入 Sprint 连跑
D="$(mk_closed_autonomous_plan)"
sed 's/<!-- ACTIVE: (none) -->/<!-- ACTIVE: TASK-007 -->/' \
  "$D/.growing/plan.md" > "$D/.growing/plan.md.tmp"
mv "$D/.growing/plan.md.tmp" "$D/.growing/plan.md"
out="$( ( cd "$D" && printf '%s' '{"conversation_id":"c1"}' | bash .cursor/hooks/run-start.sh ) )"
case "$out" in
  *"autonomous"*) echo "FAIL: run-start must not chain when closed idle: $out"; rm -rf "$D"; exit 1 ;;
esac
echo "OK  run-start no autonomous block when closed idle"
rm -rf "$D"

# acceptance 行首前缀（不执行真实 uv/dotnet — 仅静态白名单）
grep -qE 'uv run \|dotnet \|mvn' "$CURSOR_DIR/bin/runner.sh" \
  && echo "OK  runner acceptance prefix whitelist (uv/dotnet/mvn)" \
  || { echo "FAIL: runner missing uv/dotnet/mvn acceptance prefixes"; exit 1; }

# verify-layers：无 Node 时 --changed 回退（dry-run）
VL_SCRIPTS="$CURSOR_DIR/templates/scaffold/_bundles/verify-layers/shared/scripts"
sc_mktemp_dir sc-runner-smoke-fakebin
FAKE_BIN="$SC_MKTEMP_LAST"
printf '#!/bin/sh\nexit 127\n' > "$FAKE_BIN/node"
chmod +x "$FAKE_BIN/node"
out="$( cd "$VL_SCRIPTS" && env VERIFY_CHANGED_DRY=1 PATH="$FAKE_BIN:/usr/bin:/bin" bash verify/changed-fallback.sh 2>&1 )" || true
case "$out" in
  *"Node 不可用"*|*"跳过 changed-plan"*) echo "OK  verify:changed no-node dry-run fallback" ;;
  *) echo "FAIL: verify:changed no-node unexpected: $out"; exit 1 ;;
esac

# changed-plan：去重 + VERIFY_CHANGED_MIN_LAYER（Node 单元，不跑真实 verify.sh）
if command -v node >/dev/null 2>&1; then
  ( cd "$VL_SCRIPTS" && node --input-type=module -e "
import {
  planForChangedFiles,
  buildChangedSteps,
  resolveMinLayer,
} from './verify/lib/changed-plan.mjs';

const map = {
  version: 1,
  layerOrder: ['l1', 'l2-core', 'l2-standard'],
  defaultLayer: 'l2-core',
  prefixRules: [{ prefix: 'frontend/', layer: 'l1', bash: ['scripts/verify/slices/dup.sh', 'scripts/verify/slices/dup.sh'] }],
};

const p = planForChangedFiles(['frontend/a.ts'], map);
if (p.bash.length !== 1) throw new Error('bash Set dedupe expected 1 got ' + p.bash.length);

const steps = buildChangedSteps({ layer: 'l1', bash: ['scripts/verify.sh', 'scripts/verify.sh'] });
if (steps.length !== 1) throw new Error('buildChangedSteps dedupe expected 1 got ' + steps.length);

process.env.VERIFY_CHANGED_MIN_LAYER = 'l2-core';
const p2 = planForChangedFiles(['frontend/a.ts'], { ...map, prefixRules: [{ prefix: 'frontend/', layer: 'l1' }] });
if (p2.layer !== 'l2-core') throw new Error('min layer expected l2-core got ' + p2.layer);

delete process.env.VERIFY_CHANGED_MIN_LAYER;
try {
  process.env.VERIFY_CHANGED_MIN_LAYER = 'bogus';
  resolveMinLayer({});
  throw new Error('invalid min layer should throw');
} catch (e) {
  if (!String(e.message).includes('无效')) throw e;
} finally {
  delete process.env.VERIFY_CHANGED_MIN_LAYER;
}

console.log('changed-plan unit OK');
" ) || { echo "FAIL: changed-plan unit"; exit 1; }
  echo "OK  changed-plan unit (dedupe + minLayer)"
else
  echo "SKIP  changed-plan unit (no node)"
fi

# project-profile + manifest stacks filter（夹具仓）
sc_mktemp_dir sc-runner-smoke-profile
PD="$SC_MKTEMP_LAST"
VL="$CURSOR_DIR/templates/scaffold/_bundles/verify-layers/shared/scripts"
mkdir -p "$PD/.cursor/lib" "$PD/.growing" "$PD/scripts/verify"
cp "$CURSOR_DIR/lib/project-profile.sh" "$CURSOR_DIR/lib/platform.sh" "$PD/.cursor/lib/"
cp "$VL/verify/run-manifest-tier.sh" "$PD/scripts/verify/"
cat > "$PD/.growing/project-profile.json" <<'JSON'
{
  "version": 1,
  "adapted_at": "2026-10-26T00:00:00+08:00",
  "stacks": { "detected": ["java"], "primary": ["java"] },
  "verify": { "enabled_tiers": ["l0", "l1", "l2-core", "l2-domain", "l3"], "enabled_slices": [] },
  "tech_rules": { "mode": "globs-only" }
}
JSON
# shellcheck source=/dev/null
source "$PD/.cursor/lib/project-profile.sh"
sc_profile_stacks_allow_row "$PD" nodejs && {
  echo "FAIL: java primary must not allow nodejs stacks row"
  rm -rf "$PD"
  exit 1
}
sc_profile_stacks_allow_row "$PD" java || {
  echo "FAIL: java primary must allow java stacks row"
  rm -rf "$PD"
  exit 1
}
sc_profile_stacks_allow_row "$PD" "*" || {
  echo "FAIL: universal stacks row must always allow"
  rm -rf "$PD"
  exit 1
}
printf '%s\n' \
  $'l2-standard\tcommand\techo STACK_NODE\tnodejs' \
  $'l2-standard\tcommand\techo STACK_JAVA\tjava' \
  > "$PD/scripts/verify/manifest.tsv"
out="$( cd "$PD" && VERIFY_SLICE_PARALLEL=1 bash scripts/verify/run-manifest-tier.sh l2-standard 2>&1 )" || true
case "$out" in
  *SKIP*nodejs*) ;;
  *) echo "FAIL: run-manifest-tier expected SKIP nodejs: $out"; rm -rf "$PD"; exit 1 ;;
esac
case "$out" in
  *"manifest tier=l2-standard OK (1 rows)"*) ;;
  *) echo "FAIL: run-manifest-tier unexpected: $out"; rm -rf "$PD"; exit 1 ;;
esac
echo "OK  project-profile manifest stacks filter"
rm -rf "$PD"

bash "$CURSOR_DIR/bin/verify-portability.sh" >/dev/null \
  && echo "OK  verify-portability clean" \
  || { echo "FAIL: verify-portability"; exit 1; }

echo "runner smoke passed."
