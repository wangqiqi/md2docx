#!/usr/bin/env bash
# Mother template: .cursor/templates/project-onekey/onekey_start.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CUR="$ROOT/.cursor"
tpl="$CUR/templates/project-onekey/onekey_start.sh"

# 母版仓 SSOT 在 templates/；根目录 onekey 仅属于 install/growth-init 后的目标项目
if [[ -f "$ROOT/install-super-cursor.sh" && -f "$ROOT/onekey_start.sh" ]]; then
  echo "FAIL: mother repo must not have root onekey_start.sh (use templates/project-onekey/)" >&2
  exit 1
fi

[[ -f "$tpl" ]] || { echo "FAIL: missing $tpl" >&2; exit 1; }
bash -n "$tpl" || { echo "FAIL: bash -n onekey template" >&2; exit 1; }

for needle in \
  "scripts/test.sh" \
  "scripts/verify.sh" \
  "onekey_start.sh" \
  "set -euo pipefail"; do
  grep -qF "$needle" "$tpl" || { echo "FAIL: template missing '$needle'" >&2; exit 1; }
done

# 模板须可执行（install 复制后 chmod +x；母版文件本身也应 +x）
if [[ ! -x "$tpl" ]]; then
  chmod +x "$tpl"
fi
[[ -x "$tpl" ]] || { echo "FAIL: template not executable" >&2; exit 1; }

echo "OK: project-onekey template $tpl"
