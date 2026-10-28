#!/usr/bin/env bash
# 目标项目端到端回归 —— 证明「拷进任意 Git 项目就能用」
#
# 覆盖母版自测无法覆盖的路径：安装 → 闸门 → hook → 各验证器在**消费方**视角的行为。
# 全部在 mktemp 目录中进行，不改仓库。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CURSOR_DIR="$ROOT/.cursor"
# shellcheck source=../lib/temp-cleanup.sh
source "$CURSOR_DIR/lib/temp-cleanup.sh"
# shellcheck source=../lib/smoke-git.sh
source "$CURSOR_DIR/lib/smoke-git.sh"
sc_temp_trap_cleanup
INSTALL="$ROOT/install-super-cursor.sh"
FAIL=0

fail() { echo "FAIL $1"; FAIL=$((FAIL + 1)); }
ok() { echo "OK  $1"; }

if [[ ! -x "$INSTALL" ]]; then
  echo "SKIP  consumer-smoke: 非母版仓（无 install-super-cursor.sh）"
  exit 0
fi

sc_mktemp_dir sc-consumer-smoke
TMP="$SC_MKTEMP_LAST"

echo "=== consumer smoke（目标项目视角）==="

PROJ="$TMP/proj"
mkdir -p "$PROJ"
sc_smoke_git_init_repo "$PROJ" "$ROOT"
(
  cd "$PROJ"
  echo "# demo" > README.md
  git add -A
  git -c user.email=smoke@test -c user.name=smoke commit -qm init
)

# 1. 安装（SOURCE 由脚本自身位置解析；显式清掉可能指向别处的环境变量）
if env -u SUPER_CURSOR_HOME -u CURSOR_AI_HOME bash "$INSTALL" "$PROJ" --profile full > "$TMP/install.out" 2>&1; then
  ok "install --profile full"
else
  fail "install --profile full"; tail -5 "$TMP/install.out"
fi

[[ -f "$PROJ/.cursor/verify-super-cursor.sh" ]] && ok "target has .cursor/" || fail "target missing .cursor/"
[[ -f "$PROJ/.growing/plan.md" ]] && ok "target has .growing/plan.md" || fail "target missing plan.md"
grep -q '/learn' "$TMP/install.out" && ok "install points at /learn first-run" || fail "install output lacks /learn"

run_in_proj() { ( cd "$PROJ" && "$@" ); }

# 2. 闸门必须 fail-closed（未批准）
if run_in_proj bash .cursor/bin/runner.sh gate-check >/dev/null 2>&1; then
  fail "gate-check must BLOCK on a fresh install"
else
  ok "gate-check blocks unapproved plan"
fi
if run_in_proj bash .cursor/bin/runner.sh plan-check >/dev/null 2>&1; then
  fail "plan-check must report not-ready on a fresh install"
else
  ok "plan-check reports not-ready"
fi

# 3. hooks 必须真的可执行且不报错（P0-2 回归）
for h in growth-init run-start run-stop; do
  set +e
  out="$(printf '{"conversation_id":"c1","workspace_roots":["%s"]}' "$PROJ" | run_in_proj bash ".cursor/hooks/$h.sh" 2>"$TMP/$h.err")"
  rc=$?
  set -e
  err="$(cat "$TMP/$h.err")"
  if [[ "$rc" -eq 0 && -z "$err" ]]; then
    ok "hook $h exits 0 with clean stderr"
  else
    fail "hook $h rc=$rc stderr=$err"
  fi
done

# 3c. onekey bootstrap：growth-init 后根目录应有模板；二次 hook 不覆盖
if [[ -f "$PROJ/onekey_start.sh" && -x "$PROJ/onekey_start.sh" ]]; then
  ok "growth-init bootstrapped onekey_start.sh"
  onekey_hash="$(sha256sum "$PROJ/onekey_start.sh" | awk '{print $1}')"
  printf '{"conversation_id":"c1","workspace_roots":["%s"]}' "$PROJ" | run_in_proj bash .cursor/hooks/growth-init.sh >/dev/null 2>&1 || true
  onekey_hash2="$(sha256sum "$PROJ/onekey_start.sh" | awk '{print $1}')"
  if [[ "$onekey_hash" == "$onekey_hash2" ]]; then
    ok "growth-init does not overwrite existing onekey_start.sh"
  else
    fail "growth-init overwrote onekey_start.sh"
  fi
else
  fail "onekey_start.sh missing after growth-init (growth.onekey_bootstrap)"
fi

grep -q 'run gate blocked' "$TMP/run-start.err" 2>/dev/null || true
out="$(printf '{"conversation_id":"c1","workspace_roots":["%s"]}' "$PROJ" | run_in_proj bash .cursor/hooks/run-start.sh 2>/dev/null || true)"
case "$out" in
  *"gate blocked"*|*"PLAN_APPROVED"*) ok "run-start reports the blocked gate as context" ;;
  *) fail "run-start did not report the gate state: ${out:0:80}" ;;
esac

# 4. 批准后闸门放行 + 自治上下文注入（消费方主路径）
sed -e 's/<!-- PLAN_APPROVED: (none) -->/<!-- PLAN_APPROVED: 2026-09-23 -->/' \
    -e 's/<!-- ACTIVE: (none) -->/<!-- ACTIVE: TASK-001 -->/' \
    -e 's/<!-- SPRINT_STATUS: closed -->/<!-- SPRINT_STATUS: active -->/' \
    "$PROJ/.growing/plan.md" > "$TMP/plan.new"
mv "$TMP/plan.new" "$PROJ/.growing/plan.md"
run_in_proj bash .cursor/bin/runner.sh gate-check >/dev/null 2>&1 && ok "gate-check passes once approved" || fail "gate-check still blocks after approval"
out="$(printf '{"conversation_id":"c1","workspace_roots":["%s"]}' "$PROJ" | run_in_proj bash .cursor/hooks/run-start.sh 2>/dev/null || true)"
case "$out" in
  *"autonomous"*) ok "run-start injects the autonomous chain context" ;;
  *) fail "run-start did not inject autonomous context" ;;
esac

# 4b. docs 体系端到端：docs-init 铺骨架 → 门禁必须绿（关闭"骨架存在但从没被消费"的盲区）
if run_in_proj bash .cursor/bin/runner.sh docs-init >/dev/null 2>&1; then
  if run_in_proj bash .cursor/bin/verify-docs-layout.sh >/dev/null 2>&1; then
    ok "docs-init bootstraps docs/ and verify-docs-layout passes"
  else
    fail "docs-init output fails verify-docs-layout"
  fi
else
  fail "runner.sh docs-init failed in a target project"
fi

# 5. 消费方视角的验证器（universal 项在目标项目也必须过）
for v in verify-super-cursor.sh bin/cursor-coherence.sh bin/verify-config.sh bin/verify-portability.sh bin/verify-rules-globs.sh bin/verify-docs-layout.sh bin/verify-scripts-layout.sh; do
  v_out=""
  v_rc=0
  v_out="$(run_in_proj bash ".cursor/$v" 2>&1)" || v_rc=$?
  if [[ "$v_rc" -eq 0 ]]; then
    ok "target $v exits 0"
  else
    fail "target $v failed"
    echo "$v_out" | grep -E '^FAIL ' | head -15 | sed 's/^/  | /' >&2 || true
    echo "  ---- $v (tail) ----" >&2
    echo "$v_out" | tail -25 | sed 's/^/  | /' >&2
    echo "  -------------------" >&2
  fi
done

# 6. 母版门面检查不得在目标项目误报（P1 回归：mode 判定）
# 勿用 `cmd | grep -q`：grep 命中即退出会让上游吃 SIGPIPE，pipefail 下误判为失败
vs_out="$(run_in_proj bash .cursor/verify-super-cursor.sh 2>&1 || true)"
case "$vs_out" in
  *"mother-only"*) ok "verify-super-cursor skips mother-only items in a target project" ;;
  *) fail "verify-super-cursor does not recognise a target project" ;;
esac

echo "---"
if [[ "$FAIL" -eq 0 ]]; then echo "consumer smoke passed."; exit 0; fi
echo "$FAIL consumer smoke check(s) failed."
exit 1
