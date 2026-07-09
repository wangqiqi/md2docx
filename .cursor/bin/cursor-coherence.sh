#!/usr/bin/env bash
# Cross-reference coherence checks for Super Cursor .cursor/ tree
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

fail() { echo "FAIL $1"; FAIL=$((FAIL+1)); }
ok() { echo "OK  $1"; }

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

# 4. roles.json — 12 personas, unique ids, includes professional
roles_file="$CUR/config/roles.json"
if [[ -f "$roles_file" ]]; then
  py="$(command -v python3 || command -v python || true)"
  if [[ -n "$py" ]]; then
    "$py" - "$roles_file" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
personas = data.get("personas", [])
ids = [p.get("id") for p in personas]
assert len(personas) == 12, f"expected 12 personas, got {len(personas)}"
assert len(ids) == len(set(ids)), "duplicate persona id"
assert "professional" in ids, "missing professional persona"
print("OK  roles.json personas=12 unique ids")
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

# 6. alwaysApply: true only in core.mdc and workflow.mdc
while IFS= read -r f; do
  base="$(basename "$f")"
  if [[ "$base" == "core.mdc" || "$base" == "workflow.mdc" ]]; then
    ok "alwaysApply allowed: $base"
  else
    fail "alwaysApply in unexpected file: $f"
  fi
done < <(grep -rl 'alwaysApply:\s*true' "$CUR/rules" 2>/dev/null || true)

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
