#!/usr/bin/env bash
# Cross-reference coherence checks for Super Cursor .cursor/ tree
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

fail() { echo "FAIL $1"; FAIL=$((FAIL+1)); }
ok() { echo "OK  $1"; }

# shellcheck source=../lib/platform.sh
source "$CUR/lib/platform.sh"

echo "=== cursor coherence ==="

# 1. skills/*/ directory name = SKILL.md name: field
for skill_dir in "$CUR"/skills/*/; do
  [[ -d "$skill_dir" ]] || continue
  dir_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  [[ -f "$skill_file" ]] || { fail "missing SKILL.md in $dir_name"; continue; }
  yaml_name="$(grep -E '^name:\s*' "$skill_file" | head -1 | sed 's/^name:\s*//' | tr -d ' \r')"
  [[ "$dir_name" == "$yaml_name" ]] && ok "skill dir=$yaml_name" || fail "skill dir $dir_name != name:$yaml_name"
done

# 2. AGENTS.md Skills line lists every disk skill
disk_skills="$(find "$CUR/skills" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)"
agents_block="$(sed -n '/^Skills:/p' "$CUR/AGENTS.md")"
while IFS= read -r sk; do
  [[ -z "$sk" ]] && continue
  echo "$agents_block" | grep -qF "**$sk**" && ok "AGENTS lists $sk" || fail "AGENTS.md missing skill $sk"
done <<< "$disk_skills"

# 3. agents/*.md name: matches AGENTS table
for agent_file in "$CUR"/agents/*.md; do
  [[ -f "$agent_file" ]] || continue
  agent_name="$(grep -E '^name:\s*' "$agent_file" | head -1 | sed 's/^name:\s*//' | tr -d ' \r')"
  grep -qF "**$agent_name**" "$CUR/AGENTS.md" && ok "agent $agent_name in AGENTS.md" || fail "agent $agent_name not in AGENTS.md"
done

# 4. roles.json — 12 personas, unique call aliases, skills=full
roles_file="$CUR/config/roles.json"
if [[ -f "$roles_file" ]]; then
  py="$(sc_python 2>/dev/null || true)"
  if [[ -n "$py" ]]; then
    "$py" - "$roles_file" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
personas = data.get("personas", [])
ids = [p.get("id") for p in personas]
assert len(personas) == 12, f"expected 12 personas, got {len(personas)}"
assert len(ids) == len(set(ids)), "duplicate persona id"
assert "professional" in ids, "missing professional persona"
assert data.get("skills_policy") == "full", "skills_policy must be full"
rules = data.get("speech_rules") or {}
assert rules.get("forbid_self_name_opener") is True, "speech_rules.forbid_self_name_opener must be true"
aliases = {}
for p in personas:
    assert p.get("skills") == "full", f"{p.get('id')} skills must be full"
    for key in ("role_name", "given_name", "personality", "tone", "hint"):
        assert p.get(key), f"{p.get('id')} missing {key}"
    cues = p.get("voice_cues") or {}
    for ck in ("address_user", "rhythm", "flavor", "never"):
        assert cues.get(ck), f"{p.get('id')} voice_cues missing {ck}"
    emo = p.get("emotion_cues") or {}
    for ek in ("on_success", "on_blocker", "on_decision", "on_grind"):
        assert emo.get(ek), f"{p.get('id')} emotion_cues missing {ek}"
    ex = p.get("speech_examples") or []
    assert isinstance(ex, list) and len(ex) >= 4, f"{p.get('id')} needs >=4 speech_examples"
    gn = str(p.get("given_name") or "")
    for line in ex:
        s = str(line).strip()
        assert not gn or not s.startswith(gn), f"{p.get('id')} speech_example must not start with given_name"
    keys = [p.get("id"), p.get("role_name"), p.get("given_name")]
    keys += list(p.get("nicknames") or [])
    for k in keys:
        if not k:
            continue
        kl = str(k).lower()
        prev = aliases.get(kl)
        if prev and prev != p.get("id"):
            raise AssertionError(f"duplicate call alias '{k}' for {prev} and {p.get('id')}")
        aliases[kl] = p.get("id")
print("OK  roles.json personas=12 unique ids+aliases skills=full")
PY
  else
    fail "python not found for roles.json check"
  fi
else
  fail "roles.json missing"
fi

# 5. routes.md **name** references resolve to skill dir or agent file
routes="$CUR/skills/master/routes.md"
MENU_IDS="fix more style config docs deps pr scaffold plan run learn"
while IFS= read -r ref; do
  if [[ -d "$CUR/skills/$ref" ]]; then
    ok "routes skill $ref exists"
  elif [[ -f "$CUR/agents/$ref.md" ]]; then
    ok "routes agent $ref exists"
  elif [[ " $MENU_IDS " == *" $ref "* ]]; then
    ok "routes menu id $ref"
  else
    fail "routes unknown ref **$ref**"
  fi
done < <(grep -oE '\*\*[a-z][a-z0-9_-]*\*\*' "$routes" | tr -d '*' | sort -u)

# 6. alwaysApply: true only in core.mdc, workflow.mdc, super-cursor-persona.mdc
while IFS= read -r f; do
  base="$(basename "$f")"
  if [[ "$base" == "core.mdc" || "$base" == "workflow.mdc" || "$base" == "super-cursor-persona.mdc" || "$base" == "cursor-standalone.mdc" ]]; then
    ok "alwaysApply allowed: $base"
  else
    fail "alwaysApply in unexpected file: $f"
  fi
done < <(grep -rl 'alwaysApply:\s*true' "$CUR/rules" 2>/dev/null || true)

# 6b. SDD install seeds ↔ reference templates stay in sync
for tpl in spec-template tasks-template tech-plan-template principles-template; do
  ref="$CUR/skills/plan/reference/sdd/${tpl}.md"
  seed="$CUR/templates/sdd/${tpl}.md"
  if [[ -f "$ref" && -f "$seed" ]]; then
    if diff -q "$ref" "$seed" >/dev/null 2>&1; then
      ok "sdd twin $tpl"
    else
      fail "sdd twin drift: templates/sdd/${tpl}.md vs reference/sdd/${tpl}.md"
    fi
  else
    fail "sdd twin missing: $tpl"
  fi
done

# 7. tech/*.mdc have description and globs
for mdc in "$CUR"/rules/tech/*.mdc; do
  [[ -f "$mdc" ]] || continue
  base="$(basename "$mdc")"
  grep -qE '^description:' "$mdc" && grep -qE '^globs:' "$mdc" \
    && ok "tech $base frontmatter" \
    || fail "tech $base missing description or globs"
done

# 8. all rules/**/*.mdc have description
while IFS= read -r mdc; do
  base="${mdc#"$CUR/rules/"}"
  grep -qE '^description:' "$mdc" && ok "rule $base description" || fail "rule $base missing description"
done < <(find "$CUR/rules" -name '*.mdc' | sort)

# 9. every rules/**/*.mdc basename appears in verify-super-cursor.sh
verify_sh="$CUR/verify-super-cursor.sh"
while IFS= read -r mdc; do
  base="$(basename "$mdc")"
  grep -qF "$base" "$verify_sh" \
    && ok "verify registers $base" \
    || fail "verify-super-cursor.sh missing check for $base"
done < <(find "$CUR/rules" -name '*.mdc' | sort)

# 10. docs/training/skills.md lists every disk skill
training="$CUR/docs/training/skills.md"
while IFS= read -r sk; do
  [[ -z "$sk" ]] && continue
  grep -qF "**$sk**" "$training" && ok "training lists $sk" || fail "training/skills.md missing $sk"
done <<< "$disk_skills"

# 11. agent-only names must not appear as skill rows in training/skills.md
while IFS= read -r agent; do
  [[ -z "$agent" ]] && continue
  [[ -d "$CUR/skills/$agent" ]] && continue
  grep -qE "^\| \*\*${agent}\*\* \|" "$training" \
    && fail "training lists agent-only $agent as skill row" \
    || ok "training excludes agent-only $agent from skill table"
done < <(grep -hE '^name:' "$CUR/agents/"*.md 2>/dev/null | sed 's/^name:[[:space:]]*//')

# 12. migration-catalog documents intentional non-migration boundary
catalog="$CUR/docs/migration-catalog.md"
grep -q '刻意不迁移' "$catalog" && grep -q '完整性边界' "$catalog" \
  && ok "migration-catalog completeness boundary" \
  || fail "migration-catalog missing 完整性边界 section"

# 13. root README mentions full template verify chain
root_readme="$CUR/../README.md"
grep -q 'template-verify' "$root_readme" && grep -q 'cursor-coherence' "$root_readme" \
  && ok "root README verify chain" \
  || fail "root README missing template-verify or cursor-coherence"

# 14. root README mentions every disk skill and agent (facade sync)
while IFS= read -r sk; do
  [[ -z "$sk" ]] && continue
  grep -qF "$sk" "$root_readme" && ok "README mentions skill $sk" || fail "README missing skill $sk"
done <<< "$disk_skills"

for agent_file in "$CUR"/agents/*.md; do
  [[ -f "$agent_file" ]] || continue
  agent_name="$(grep -E '^name:\s*' "$agent_file" | head -1 | sed 's/^name:\s*//' | tr -d ' \r')"
  [[ -z "$agent_name" ]] && continue
  grep -qF "$agent_name" "$root_readme" && ok "README mentions agent $agent_name" \
    || fail "README missing agent $agent_name"
done

# 15. rules/local symlink resolves (.cursorGrowth/rules/local)
repo_root="$(cd "$CUR/.." && pwd)"
local_link="$CUR/rules/local"
if [[ -L "$local_link" ]]; then
  if [[ -d "$local_link" && -f "$local_link/README.md" ]]; then
    ok "rules/local symlink resolves"
  else
    fail "rules/local symlink broken — run: bash .cursor/bin/bootstrap-growth.sh"
  fi
elif [[ -d "$local_link" && -f "$local_link/README.md" ]]; then
  ok "rules/local directory"
elif [[ ! -e "$local_link" ]]; then
  fail "rules/local missing — run: bash .cursor/bin/bootstrap-growth.sh"
else
  fail "rules/local not a symlink or directory with README"
fi

echo "---"
[[ "$FAIL" -eq 0 ]] && echo "Coherence checks passed." && exit 0
echo "$FAIL coherence check(s) failed." && exit 1
