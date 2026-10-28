#!/usr/bin/env bash
# SPIKE-005 SPRINT-PLUGIN-AGENTS: agents in plugin scope archived.
set -euo pipefail
# shellcheck source=../lib/resolve-root.sh
source "$(cd "$(dirname "$0")/.." && pwd)/lib/resolve-root.sh"
ROOT="$(sc_adaptor_repo_root_from "$(cd "$(dirname "$0")" && pwd)")"
ARCHIVE_DIR="$ROOT/.growing/archive/meta"

# 归档为本地私有（.growing/ 不入 git）→ 未引导时 SKIP；本地有 meta/ 仍严格校验
# shellcheck source=../lib/growth-archive.sh
source "$ROOT/.cursor/lib/growth-archive.sh"
sc_growth_archive_available "$ARCHIVE_DIR" "verify-spike-plugin-agents-scope" || exit 0

shopt -s nullglob
files=("$ARCHIVE_DIR"/*_SPIKE_plugin_agents_scope.md)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no archive meta/*_SPIKE_plugin_agents_scope.md" >&2
  exit 1
fi
latest="$(printf '%s\n' "${files[@]}" | sort | tail -1)"
for needle in "ship" "review" "spike" "sync-plugin-subset" "super-cursor-mvp" "0.2.0"; do
  grep -qF "$needle" "$latest" || { echo "FAIL: missing '$needle' in $latest" >&2; exit 1; }
done
echo "OK: plugin agents scope spike archive $latest"
