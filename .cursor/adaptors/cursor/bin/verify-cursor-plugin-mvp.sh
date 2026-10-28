#!/usr/bin/env bash
# TASK-002 SPRINT-PLUGIN-MVP: .cursor-plugin subset matches SPIKE-002 scope.
set -euo pipefail
# shellcheck source=../lib/resolve-root.sh
source "$(cd "$(dirname "$0")/.." && pwd)/lib/resolve-root.sh"
ROOT="$(sc_adaptor_repo_root_from "$(cd "$(dirname "$0")" && pwd)")"
PLUGIN="$ROOT/.cursor-plugin"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -d "$PLUGIN" ]] || fail "missing $PLUGIN"

if [[ -d "$PLUGIN/commands" ]]; then
  fail ".cursor-plugin/commands must not exist"
fi

for rel in rules/core.mdc rules/workflow.mdc; do
  [[ -f "$PLUGIN/$rel" ]] || fail "missing $rel"
done

for skill in master plan run learn scaffold; do
  [[ -f "$PLUGIN/skills/$skill/SKILL.md" ]] || fail "missing skills/$skill/SKILL.md"
done

[[ -f "$PLUGIN/skills/master/routes.md" ]] || fail "missing skills/master/routes.md"

for agent in ship review spike; do
  [[ -f "$PLUGIN/agents/$agent.md" ]] || fail "missing agents/$agent.md"
done

for skill in git release debug test; do
  [[ ! -d "$PLUGIN/skills/$skill" ]] || fail "skills/$skill should not be in MVP plugin"
done

[[ ! -d "$PLUGIN/rules/tech" ]] || fail "rules/tech must not be in MVP plugin"

for hook in hooks/hooks.json hooks/growth-init.sh hooks/run-start.sh hooks/run-stop.sh; do
  [[ -e "$PLUGIN/$hook" ]] || fail "missing $hook"
done

[[ -f "$PLUGIN/hooks/lib/config-load.sh" ]] || fail "missing hooks/lib/config-load.sh"
# hooks/lib 里 source ../../lib/platform.sh —— 缺这份就三个 hook 全哑（2026-10-14 修）
[[ -f "$PLUGIN/lib/platform.sh" ]] || fail "missing lib/platform.sh (hooks source ../../lib/platform.sh)"
[[ -f "$PLUGIN/lib/onekey-bootstrap.sh" ]] || fail "missing lib/onekey-bootstrap.sh"
onekey_ssot="$ROOT/.cursor/templates/project-onekey/onekey_start.sh"
onekey_plugin="$PLUGIN/templates/project-onekey/onekey_start.sh"
[[ -f "$onekey_plugin" ]] || fail "missing templates/project-onekey/onekey_start.sh (run sync-plugin-subset.sh)"
cmp -s "$onekey_ssot" "$onekey_plugin" \
  || fail "plugin onekey template diverges from mother SSOT"

grep -q '"command": "hooks/run-start.sh"' "$PLUGIN/hooks/hooks.json" \
  || fail "hooks.json must use plugin-local hooks/ paths"

verify_mdc="$PLUGIN/rules/feedback/verify.mdc"
mother_verify="$ROOT/.cursor/rules/feedback/verify.mdc"
[[ -f "$verify_mdc" ]] || fail "missing rules/feedback/verify.mdc"
[[ -f "$mother_verify" ]] || fail "missing mother rules/feedback/verify.mdc"
if ! diff -q "$mother_verify" "$verify_mdc" >/dev/null 2>&1; then
  fail "plugin verify.mdc must match mother (run sync-plugin-subset.sh)"
fi
grep -q "## 母版门禁清单（分组聚合" "$verify_mdc" \
  || fail "plugin verify.mdc must document grouped gate list"
if grep -qE '11 道(门禁| · 全部接线)' "$verify_mdc"; then
  fail "plugin verify.mdc still mentions obsolete 11 道 gate count"
fi

bash "$(cd "$(dirname "$0")" && pwd)/verify-cursor-plugin-manifest.sh" || exit 1

# --- hooks 冒烟：复制到临时项目实跑三个 hook ---
# 只查「文件存在」看不见两类死法：缺 lib/platform.sh（source 即退 1）、
# 读不到已安装项目的 .cursor/config（用户配置被静默忽略）。
_tc="$ROOT/.cursor/harness/core/lib/temp-cleanup.sh"
[[ -f "$_tc" ]] || _tc="$ROOT/.cursor/lib/temp-cleanup.sh"
# shellcheck source=temp-cleanup.sh
source "$_tc"
sc_temp_trap_cleanup
sc_mktemp_dir sc-verify-plugin-mvp
smoke_root="$SC_MKTEMP_LAST"
cp -a "$PLUGIN" "$smoke_root/plugin"
mkdir -p "$smoke_root/.cursor/config"
_gtpl="$ROOT/.cursor/harness/core/templates/growing"
[[ -d "$_gtpl" ]] || _gtpl="$ROOT/.cursor/templates/growing"
if [[ -d "$_gtpl" ]]; then
  mkdir -p "$smoke_root/.cursor/templates"
  cp -a "$_gtpl" "$smoke_root/.cursor/templates/growing"
fi
_oktpl="$PLUGIN/templates/project-onekey"
[[ -d "$_oktpl" ]] && mkdir -p "$smoke_root/.cursor/templates/project-onekey" && cp -a "$_oktpl/." "$smoke_root/.cursor/templates/project-onekey/"
printf '%s\n' '{"workflow":{"enabled":true,"hooks_enabled":true},"growth":{"enabled":true,"onekey_bootstrap":true}}' \
  > "$smoke_root/.cursor/config/workflow.json"
hook_input="{\"conversation_id\":\"verify-plugin\",\"hook_event_name\":\"sessionStart\",\"workspace_roots\":[\"$smoke_root\"]}"
for hook in growth-init run-start run-stop; do
  if ! hook_out="$(printf '%s' "$hook_input" | bash "$smoke_root/plugin/hooks/$hook.sh" 2>&1)"; then
    fail "$hook.sh exited non-zero: $hook_out"
  fi
done
# growth.enabled=true 必须真被读到：配置路径读错时 growth-init 提前返回，不会建 .growing
[[ -d "$smoke_root/.growing" ]] \
  || fail "plugin hooks ignored .cursor/config/workflow.json (growth.enabled not applied)"
[[ -f "$smoke_root/onekey_start.sh" && -x "$smoke_root/onekey_start.sh" ]] \
  || fail "plugin growth-init did not bootstrap onekey_start.sh from bundled template"

echo "OK: cursor-plugin MVP subset (lifecycle skills · agents · core rules · hooks · no commands)"
