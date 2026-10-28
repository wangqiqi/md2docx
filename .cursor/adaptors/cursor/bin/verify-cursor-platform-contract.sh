#!/usr/bin/env bash
# Cursor platform alignment contract (SPRINT-CURSOR-ALIGN + mother lean TASK-001).
# Replaces verify-spike-cursor-align-archive + verify-task-001..006.
set -euo pipefail
# shellcheck source=../lib/resolve-root.sh
source "$(cd "$(dirname "$0")/.." && pwd)/lib/resolve-root.sh"
ROOT="$(sc_adaptor_repo_root_from "$(cd "$(dirname "$0")" && pwd)")"
CUR="$ROOT/.cursor"
TPL="$CUR/templates/growing"
ARCHIVE_DIR="$ROOT/.growing/archive/meta"

# 归档为本地私有（.growing/ 不入 git）→ 未引导时跳过归档段，其余契约检查照跑
# shellcheck source=../lib/growth-archive.sh
source "$ROOT/.cursor/lib/growth-archive.sh"
archive_ready=false
if sc_growth_archive_available "$ARCHIVE_DIR" "verify-cursor-platform-contract"; then
  archive_ready=true
fi

fail() { echo "FAIL: $*" >&2; exit 1; }

# --- SPIKE archive + library-index ---
if [[ "$archive_ready" == "true" ]]; then
  shopt -s nullglob
  spike_files=("$ARCHIVE_DIR"/*_SPIKE_cursor_official_align.md)
  [[ ${#spike_files[@]} -gt 0 ]] || fail "no archive meta/*_SPIKE_cursor_official_align.md"
  spike_latest="$(printf '%s\n' "${spike_files[@]}" | sort | tail -1)"
  for needle in "In · Doc · Skip" "官方文档锚点" "TASK-004"; do
    grep -q "$needle" "$spike_latest" || fail "missing '$needle' in $spike_latest"
  done
fi
LIB="$CUR/docs/library-index.md"
grep -q "Cursor 官方平台" "$LIB" || fail "library-index.md missing Cursor 官方平台 section"

# --- learn template + migration-catalog 2026 ---
LEARN_TPL="$TPL/learn/cursor-platform.md"
[[ -f "$LEARN_TPL" ]] || fail "missing $LEARN_TPL"
grep -q "disable-model-invocation" "$LEARN_TPL" || fail "cursor-platform.md missing skill policy"
MIG="$CUR/docs/migration-catalog.md"
grep -q "## 2026 官方面" "$MIG" || fail "migration-catalog missing 2026 section"
start="$(grep -n "## 2026 官方面" "$MIG" | head -1 | cut -d: -f1)"
next="$(tail -n "+$((start + 1))" "$MIG" | grep -n '^## ' | head -1 | cut -d: -f1 || true)"
if [[ -n "$next" ]]; then
  end=$((start + next - 1))
  lines=$((end - start))
else
  lines="$(tail -n "+$start" "$MIG" | wc -l | tr -d ' ')"
fi
[[ "$lines" -le 30 ]] || fail "2026 section has $lines lines (max 30)"

# --- Bugbot templates ---
for f in BUGBOT.md config/bugbot.yaml.example; do
  [[ -f "$TPL/$f" ]] || fail "missing $TPL/$f"
done
grep -q "version: 1" "$TPL/config/bugbot.yaml.example" || fail "bugbot.yaml.example missing version: 1"
README="$TPL/README.md"
for needle in ".cursor/BUGBOT.md" ".cursor/config/bugbot.yaml" "review"; do
  grep -q "$needle" "$README" || fail "README missing '$needle'"
done
grep -q "review" "$TPL/BUGBOT.md" || fail "BUGBOT.md missing review skill split"

# --- MCP + Cloud templates ---
DOC="$CUR/docs/cursor-cloud.md"
[[ -f "$DOC" ]] || DOC="$CUR/adaptors/cursor/docs/cursor-cloud.md"
for f in mcp.json.example environment.json.example; do
  [[ -f "$TPL/$f" ]] || fail "missing $TPL/$f"
done
grep -q 'mcpServers' "$TPL/mcp.json.example" || fail "mcp.json.example"
grep -q '"install"' "$TPL/environment.json.example" || fail "environment.json.example install"
grep -q '"build"' "$TPL/environment.json.example" && fail "environment.json.example must be install-only (use environment.docker.json.example)"
[[ -f "$TPL/environment.docker.json.example" ]] || fail "missing environment.docker.json.example"
grep -q 'dockerfile' "$TPL/environment.docker.json.example" || fail "environment.docker.json.example build"
grep -q 'environment.docker.json.example' "$DOC" || fail "cursor-cloud.md missing docker environment example"
[[ -f "$DOC" ]] || fail "missing cursor-cloud.md"
grep -q 'ops-deploy' "$DOC" || fail "cursor-cloud.md missing ops-deploy link"
grep -q 'cursor-cloud.md' "$CUR/docs/platforms.md" || fail "platforms.md missing link"
grep -q '.cursor/mcp.json' "$README" || fail "README mcp copy path"

# --- commands retired; slash SSOT skills/ ---
CMD="$CUR/commands"
if [[ -d "$CMD" ]]; then
  leftover=("$CMD"/*.md)
  [[ ${#leftover[@]} -eq 0 ]] || fail ".cursor/commands/*.md still present (skill-only slash)"
fi
NAMING="$CUR/docs/naming.md"
grep -q '永远.*命中.*commands' "$NAMING" && fail "naming.md still documents commands-first slash"
for required in plan run master learn scaffold release long delivery user-manual test-report; do
  [[ -f "$CUR/skills/$required/SKILL.md" ]] || fail "missing skills/$required/SKILL.md"
done

# --- hooks cloud/tab documentation ---
PLAT="$CUR/docs/platforms.md"
for needle in "Cloud Agents parity" "beforeTabFileRead" "run-start.sh"; do
  grep -q "$needle" "$PLAT" || fail "platforms.md missing '$needle'"
done
grep -q 'platforms.md' "$DOC" || fail "cursor-cloud.md missing platforms cross-link"
HOOKS="$CUR/hooks.json"
if grep -q 'beforeTabFileRead\|afterTabFileEdit' "$HOOKS"; then
  fail "hooks.json should not enable Tab hooks by default"
fi
grep -q 'sessionStart' "$HOOKS" || fail "hooks.json sessionStart"

# --- plugin distribution archive ---
if [[ "$archive_ready" == "true" ]]; then
  shopt -s nullglob
  plugin_files=("$ARCHIVE_DIR"/*_plugin_distribution_decision.md)
  [[ ${#plugin_files[@]} -gt 0 ]] || fail "no archive meta/*_plugin_distribution_decision.md"
  plugin_latest="$(printf '%s\n' "${plugin_files[@]}" | sort | tail -1)"
  for needle in "install-super-cursor" "Cursor Plugin" "Agent Plugin" "Marketplace"; do
    grep -q "$needle" "$plugin_latest" || fail "missing '$needle' in $plugin_latest"
  done
fi
grep -q 'install-super-cursor' "$LEARN_TPL" || fail "cursor-platform.md install path"
grep -q 'cursor-plugin' "$LEARN_TPL" || fail "cursor-platform.md plugin MVP pointer"

# --- TASK-001: retired per-task verifiers + single wiring ---
retired=(
  verify-spike-cursor-align-archive.sh
  verify-task-001-cursor-platform.sh
  verify-task-002-bugbot-templates.sh
  verify-task-003-mcp-cloud-templates.sh
  verify-task-004-commands-retired.sh
  verify-task-005-hooks-cloud-doc.sh
  verify-task-006-plugin-distribution.sh
)
for r in "${retired[@]}"; do
  [[ ! -f "$CUR/bin/$r" ]] || fail "retired verifier still present: $r"
done
AGG="$CUR/verify-super-cursor.sh"
for r in "${retired[@]}"; do
  grep -qF "bin/$r" "$AGG" && fail "verify-super-cursor.sh still calls $r"
done
count="$(grep -cF 'verify-cursor-platform-contract.sh' "$AGG" || true)"
[[ "$count" -eq 1 ]] || fail "verify-super-cursor.sh must call verify-cursor-platform-contract.sh exactly once (found $count)"

echo "OK: cursor platform contract (archive · templates · slash · hooks · plugin · wiring)"
