#!/usr/bin/env bash
# Universal Super Cursor layout check
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CUR="$ROOT/.cursor"
FAIL=0

check() { [[ -e "$1" ]] && echo "OK  $1" || { echo "FAIL $1"; FAIL=$((FAIL+1)); }; }
check_absent() { [[ -e "$1" ]] && { echo "FAIL must not exist: $1"; FAIL=$((FAIL+1)); } || echo "OK  absent $1"; }
check_grep_absent() {
  local dir="$1" pattern="$2"
  if grep -rq --exclude="verify-super-cursor.sh" "$pattern" "$dir" 2>/dev/null; then
    echo "FAIL $dir contains $pattern"
    FAIL=$((FAIL+1))
  else
    echo "OK  no '$pattern' in $(basename "$dir") tree"
  fi
}

echo "=== Super Cursor verify (universal) ==="
check "$CUR/rules/core.mdc"
check "$CUR/rules/workflow.mdc"
check "$CUR/rules/feedback/changelog.mdc"
check "$CUR/rules/feedback/verify.mdc"
check "$CUR/rules/execution/submodule.mdc"
check "$CUR/config/workflow.json"
check "$CUR/config/release.json"
check "$CUR/config/README.md"
check "$CUR/templates/plan.md"
if [[ -f "$CUR/templates/plan.md" ]] && ! grep -qE '^\*\*(执行顺序|Order)\*\*' "$CUR/templates/plan.md" 2>/dev/null; then
  echo "FAIL templates/plan.md missing **执行顺序** line"
  FAIL=$((FAIL+1))
else
  echo "OK  templates/plan.md has execution order line"
fi
check "$CUR/rules/communication/collaboration.mdc"
check "$CUR/rules/execution/docs.mdc"
check "$CUR/rules/execution/commit.mdc"
check "$CUR/rules/execution/bugfix.mdc"
check "$CUR/templates/cursorGrowth/README.md"
check "$CUR/templates/cursorGrowth/learn/plan-conventions.md"
check "$CUR/hooks/growth-init.sh"
check "$CUR/hooks/run-start.sh"
check "$CUR/hooks/run-stop.sh"
check "$CUR/hooks/lib/config-load.sh"
check "$CUR/hooks/lib/plan-parse.sh"
check "$CUR/hooks/lib/json-utils.sh"
check "$CUR/README.md"   # .cursor/README.md
check "$CUR/verify-system.sh"
check "$CUR/lib/platform.sh"
check "$CUR/skills/master/SKILL.md"
check "$CUR/skills/master/routes.md"
check "$CUR/bin/runner-smoke.sh"
check "$CUR/bin/bootstrap-growth.sh"
check "$CUR/bin/install-smoke.sh"
check "$ROOT/install-super-cursor.sh"
check "$CUR/config/profiles/full.json"
check "$CUR/config/profiles/lite.json"
check "$CUR/config/profiles/rules-only.json"
check "$CUR/docs/walkthrough.md"
check "$CUR/rules/tech/rust.mdc"
check "$CUR/rules/tech/nextjs.mdc"
check "$CUR/skills/plan/SKILL.md"
check "$CUR/skills/run/SKILL.md"
check "$CUR/skills/learn/SKILL.md"
check "$CUR/skills/scaffold/SKILL.md"
check "$CUR/skills/git/SKILL.md"
check "$CUR/skills/release/SKILL.md"
check "$CUR/commands/plan.md"
check "$CUR/commands/run.md"
check "$CUR/commands/master.md"
check "$CUR/commands/learn.md"
check "$CUR/commands/scaffold.md"
check "$CUR/commands/release.md"
check "$CUR/skills/delivery/SKILL.md"
check "$CUR/skills/ux/SKILL.md"
check "$CUR/skills/ia/SKILL.md"
check "$CUR/commands/ux.md"
check "$CUR/commands/ia.md"
check "$CUR/commands/delivery.md"
check "$CUR/commands/debug.md"
check "$CUR/commands/review.md"
check "$CUR/commands/week.md"
check "$CUR/commands/disk.md"
check "$CUR/commands/maintain.md"
check "$CUR/commands/pencil-design.md"
check "$CUR/skills/week/SKILL.md"
check "$CUR/skills/disk/SKILL.md"
check "$CUR/skills/maintain/SKILL.md"
check "$CUR/skills/pencil-design/SKILL.md"
check "$CUR/skills/security/SKILL.md"
check "$CUR/skills/api/SKILL.md"
check "$CUR/rules/tech/c.mdc"
check "$CUR/rules/communication/constitution.mdc"
check "$CUR/rules/feedback/evolution.mdc"
check "$CUR/rules/execution/cli-python.mdc"
check "$CUR/rules/execution/vibe.mdc"
check "$CUR/rules/execution/scope.mdc"
check "$CUR/rules/execution/testing.mdc"
check "$CUR/rules/communication/agent-discipline.mdc"
check "$CUR/rules/communication/super-cursor-persona.mdc"
check "$CUR/rules/communication/cursor-standalone.mdc"
check "$CUR/docs/library-index.md"
check "$CUR/config/roles.json"
check "$CUR/skills/debug/SKILL.md"
check "$CUR/skills/test/SKILL.md"
check "$CUR/skills/mcp/SKILL.md"
check "$CUR/skills/refactor/SKILL.md"
check "$CUR/skills/perf/SKILL.md"
check "$CUR/rules/tech/eslint.mdc"
check "$CUR/rules/tech/javascript.mdc"
check "$CUR/rules/execution/security-sdlc.mdc"
check "$CUR/skills/review/SKILL.md"
check "$CUR/skills/study/SKILL.md"
check "$CUR/agents/review.md"
check "$CUR/agents/spike.md"
check "$CUR/docs/migration-catalog.md"
check "$CUR/bin/scaffold.sh"
check "$CUR/bin/scaffold-integrity.sh"
check "$CUR/templates/scaffold/manifest.json"
check "$CUR/docs/training/skills.md"
check "$CUR/docs/quickstart.md"
check "$CUR/docs/effective-collaboration.md"
check "$CUR/docs/platforms.md"
check "$ROOT/.cursorignore"
check "$CUR/templates/scaffold/_shared.cursorignore"
check "$CUR/bin/template-verify.sh"
check_absent "$ROOT/scripts"
check_absent "$ROOT/examples"
check "$ROOT/.github/workflows/verify.yml"
check "$CUR/skills/release/SKILL.md"
check "$CUR/agents/ship.md"
check "$CUR/AGENTS.md"
check "$CUR/docs/naming.md"
check "$CUR/docs/rules-catalog.md"
check "$CUR/bin/runner.sh"
check "$CUR/bin/platform-check.sh"
check "$CUR/hooks.json"
check "$CUR/bin/cursor-coherence.sh"
check "$CUR/bin/validate-commit-msg.sh"
check "$CUR/rules/tech/cpp.mdc"
check "$CUR/rules/tech/typescript.mdc"
check "$CUR/rules/tech/react.mdc"
check "$CUR/rules/tech/vue.mdc"
check "$CUR/rules/tech/svelte.mdc"
check "$CUR/rules/tech/go.mdc"
check "$CUR/rules/tech/java.mdc"
check "$CUR/rules/tech/python.mdc"
check "$CUR/rules/execution/api.mdc"
check "$CUR/rules/execution/ux.mdc"
check "$CUR/rules/execution/ia.mdc"
check "$CUR/rules/execution/delivery.mdc"
check "$CUR/rules/execution/async-progress.mdc"
check "$CUR/rules/execution/long-running-ui.mdc"
check "$CUR/rules/execution/modal-layering.mdc"
check "$CUR/rules/execution/error-context.mdc"
check "$CUR/rules/execution/single-detector.mdc"
check "$CUR/rules/execution/data-batch.mdc"
check "$CUR/rules/execution/oss-first.mdc"
check "$CUR/rules/execution/input-bounds.mdc"
check "$CUR/rules/execution/extensibility.mdc"
check "$CUR/rules/execution/prompt-security.mdc"
check "$CUR/rules/feedback/release.mdc"
check "$CUR/rules/feedback/tag.mdc"
check_absent "$ROOT/domain-packages"
check_absent "$ROOT/profiles"
check_absent "$CUR/agents/release.md"
check_absent "$CUR/rules/index.mdc"
check_absent "$CUR/rules/feedback/growth.mdc"
check_grep_absent "$CUR" "date -Iseconds"

check_grep_absent "$CUR" "master 指令"


echo "--- platform helpers ---"
# shellcheck source=lib/platform.sh
source "$CUR/lib/platform.sh"
ts="$(iso8601_now)"
[[ -n "$ts" ]] && echo "OK  iso8601_now=$ts" || { echo "FAIL iso8601_now"; FAIL=$((FAIL+1)); }
pf="$(json_cfg "$CUR/config/workflow.json" plan_file __missing__)"
[[ "$pf" == ".cursorGrowth/plan.md" ]] && echo "OK  json_cfg plan_file=$pf" || { echo "FAIL json_cfg plan_file=$pf"; FAIL=$((FAIL+1)); }
we="$(json_cfg "$CUR/config/workflow.json" workflow.enabled __missing__)"
[[ "$we" == "true" ]] && echo "OK  json_cfg workflow.enabled=$we" || { echo "FAIL json_cfg workflow.enabled=$we"; FAIL=$((FAIL+1)); }

echo "--- changelog order (newest_first) ---"
# release.json order=newest_first：已发布 ## [x.y.z] 节须严格新→旧；## [Unreleased] 可置顶
CL="$ROOT/CHANGELOG.md"
if [[ ! -f "$CL" ]]; then
  echo "OK  no root CHANGELOG.md (skip order check)"
elif ! py="$(sc_python 2>/dev/null)"; then
  echo "FAIL python required for CHANGELOG order check"
  FAIL=$((FAIL+1))
else
  if "$py" - "$CL" <<'PY'
import re, sys
from pathlib import Path
text = Path(sys.argv[1]).read_text(encoding="utf-8")
# capture semver headings only (skip Unreleased)
vers = re.findall(r"^## \[(\d+\.\d+\.\d+)\]", text, flags=re.M)
if len(vers) < 2:
    print("OK  CHANGELOG version headings <%d (skip strict order)" % len(vers))
    sys.exit(0)

def key(v: str):
    return tuple(int(x) for x in v.split("."))

for i in range(len(vers) - 1):
    if key(vers[i]) <= key(vers[i + 1]):
        print(
            "FAIL CHANGELOG not newest_first: %s then %s (index %d)"
            % (vers[i], vers[i + 1], i)
        )
        sys.exit(1)
print("OK  CHANGELOG newest_first (%d version headings)" % len(vers))
sys.exit(0)
PY
  then
    :
  else
    FAIL=$((FAIL+1))
  fi
fi

echo "--- roles.json persona speech ---"
roles_file="$CUR/config/roles.json"
if [[ -f "$roles_file" ]]; then
  py="$(sc_python 2>/dev/null || true)"
  if [[ -n "$py" ]] && "$py" - "$roles_file" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
rules = data.get("speech_rules") or {}
assert rules.get("forbid_self_name_opener") is True
for p in data.get("personas", []):
    assert len(p.get("speech_examples") or []) >= 4, p.get("id")
    gn = str(p.get("given_name") or "")
    for line in p.get("speech_examples") or []:
        assert not gn or not str(line).strip().startswith(gn), p.get("id")
    cues = p.get("voice_cues") or {}
    for k in ("address_user", "rhythm", "flavor", "never"):
        assert cues.get(k), f"{p.get('id')} missing voice_cues.{k}"
    emo = p.get("emotion_cues") or {}
    for k in ("on_success", "on_blocker", "on_decision", "on_grind"):
        assert emo.get(k), f"{p.get('id')} missing emotion_cues.{k}"
print("OK  roles.json speech_rules voice_cues emotion_cues examples")
PY
  then
    :
  else
    FAIL=$((FAIL+1))
  fi
else
  echo "FAIL roles.json missing"
  FAIL=$((FAIL+1))
fi

echo "--- standalone: no upstream URL in skills ---"
# skill 正文禁止 github.com 作 SSOT（library-index / standalone-map 除外）
violators=""
while IFS= read -r f; do
  [[ "$f" == *"standalone-map.md" ]] && continue
  violators="${violators}${f}"$'\n'
done < <(grep -rl 'https://github.com' "$CUR/skills" 2>/dev/null || true)
if [[ -n "$(echo "$violators" | sed '/^$/d')" ]]; then
  echo "FAIL skills contain github.com URL (use docs/library-index.md):"
  echo "$violators" | sed '/^$/d'
  FAIL=$((FAIL+1))
else
  echo "OK  skills no upstream github URLs"
fi

echo "---"
[[ "$FAIL" -eq 0 ]] && echo "All checks passed." && exit 0
echo "$FAIL check(s) failed." && exit 1
