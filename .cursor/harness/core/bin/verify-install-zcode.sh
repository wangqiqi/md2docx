#!/usr/bin/env bash
# Smoke: install Harness Core into .zcode/ (temp dir).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CURSOR_DIR="$ROOT/.cursor"
# shellcheck source=../lib/temp-cleanup.sh
source "$CURSOR_DIR/lib/temp-cleanup.sh"
sc_temp_trap_cleanup
INSTALL_ZCODE="$CURSOR_DIR/bin/install-adaptor-zcode.sh"
[[ -f "$INSTALL_ZCODE" ]] || INSTALL_ZCODE="$CURSOR_DIR/harness/core/bin/install-adaptor-zcode.sh"

sc_mktemp_dir sc-verify-install-zcode
TMP="$SC_MKTEMP_LAST"

if ! bash "$INSTALL_ZCODE" "$TMP" --profile lite >/dev/null 2>&1; then
  echo "FAIL: install-adaptor-zcode exited non-zero" >&2
  exit 1
fi

for f in .zcode/skills .zcode/rules/core.mdc .zcode/bin/runner.sh .zcode/config/workflow.json \
  .zcode/AGENTS.md .zcode/hooks/run-start.sh .zcode/hooks/growth-init.sh .zcode/hooks/run-stop.sh \
  .zcode/config.json AGENTS.md; do
  [[ -e "$TMP/$f" ]] || { echo "FAIL: missing $f" >&2; exit 1; }
done

[[ -f "$TMP/.zcode/README.md" ]] || { echo "FAIL: missing .zcode/README.md" >&2; exit 1; }
[[ ! -d "$TMP/.zcode/adaptors" ]] || { echo "FAIL: .zcode must not include adaptors/" >&2; exit 1; }
[[ ! -d "$TMP/.zcode/hooks/state" ]] || [[ -z "$(ls -A "$TMP/.zcode/hooks/state" | grep -v README)" ]] || {
  echo "FAIL: .zcode/hooks/state must not carry runtime state" >&2
  exit 1
}

if grep -rn '\.cursor/' "$TMP/.zcode/skills" "$TMP/.zcode/rules" "$TMP/.zcode/agents" >/dev/null 2>&1; then
  echo "FAIL: .cursor/ runtime references remain after rewrite" >&2
  exit 1
fi

# 追加块内引号带反斜杠转义，grep 模式不能内嵌裸引号
grep -q 'adaptor:zcode 协议翻译' "$TMP/.zcode/hooks/lib/json-utils.sh" || {
  echo "FAIL: hook protocol translation block missing" >&2
  exit 1
}

# 功能断言：source 后真实调用，捕获「键改了但参数没接住」类回归（空值输出）
out_ctx="$(bash -c 'source "$1"; json_additional_context "hi-zcode"' _ "$TMP/.zcode/hooks/lib/json-utils.sh" 2>/dev/null || true)"
case "$out_ctx" in
  *'"additionalContext": "hi-zcode"'*) ;;
  *) echo "FAIL: json_additional_context output wrong: $out_ctx" >&2; exit 1 ;;
esac
out_fup="$(bash -c 'source "$1"; json_followup "go-on"' _ "$TMP/.zcode/hooks/lib/json-utils.sh" 2>/dev/null || true)"
case "$out_fup" in
  *'"decision": "block"'*'go-on'*) ;;
  *) echo "FAIL: json_followup output wrong: $out_fup" >&2; exit 1 ;;
esac

full_n="$(find -L "$TMP/.zcode/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
[[ "$full_n" == "28" ]] || { echo "FAIL: .zcode skills=$full_n (expected 28 for full bundle)" >&2; exit 1; }

# shellcheck source=../lib/platform.sh
source "$CURSOR_DIR/lib/platform.sh"
py="$(sc_python)"
"$py" - "$TMP/.zcode/config.json" <<'PY'
import json, sys

cfg = json.load(open(sys.argv[1], encoding="utf-8"))
hooks = cfg.get("hooks") or {}
assert hooks.get("enabled") is True, "hooks.enabled must be true"
events = hooks.get("events") or {}
for ev in ("SessionStart", "UserPromptSubmit", "Stop"):
    assert ev in events, f"missing hooks event {ev}"
print("config.json hooks OK")
PY

echo "OK: verify-install-zcode (.zcode full bundle skills=$full_n · rewrite clean · hooks wired)"
