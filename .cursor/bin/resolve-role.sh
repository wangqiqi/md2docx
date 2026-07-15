#!/usr/bin/env bash
# resolve-role.sh — resolve persona by id / role_name / nickname / given_name
# Usage:
#   resolve-role.sh <roles.json> <query> [project_root]
#   SC_PROJECT_ROOT / 第 3 参：读 <root>/.cursorGrowth/session/aliases.json（优先）
# Exit 0 + JSON persona on unique match; exit 2 on ambiguous; exit 1 on miss
set -euo pipefail
roles_file="${1:?roles.json}"
query="${2:?query}"
project_root="${3:-${SC_PROJECT_ROOT:-}}"
aliases_file=""
if [[ -n "$project_root" && -f "$project_root/.cursorGrowth/session/aliases.json" ]]; then
  aliases_file="$project_root/.cursorGrowth/session/aliases.json"
elif [[ -z "$project_root" ]]; then
  # walk up from cwd for .cursorGrowth/session/aliases.json
  d="$(pwd)"
  while [[ "$d" != "/" ]]; do
    if [[ -f "$d/.cursorGrowth/session/aliases.json" ]]; then
      aliases_file="$d/.cursorGrowth/session/aliases.json"
      break
    fi
    d="$(dirname "$d")"
  done
fi
py="$(command -v python3 || command -v python || true)"
[[ -n "$py" ]] || { echo "FAIL: no python" >&2; exit 1; }
"$py" - "$roles_file" "$query" "$aliases_file" <<'PY'
import json, sys
path, q, aliases_path = sys.argv[1], sys.argv[2].strip().lower(), sys.argv[3]
data = json.load(open(path, encoding="utf-8"))
personas = {p.get("id"): p for p in data.get("personas", []) if p.get("id")}

# 1) Growth aliases first (project override)
if aliases_path:
    try:
        al = json.load(open(aliases_path, encoding="utf-8"))
        mapping = al.get("aliases") or {}
        for k, pid in mapping.items():
            if str(k).strip().lower() == q:
                p = personas.get(pid)
                if p:
                    out = dict(p)
                    out["_resolved_via"] = f"growth_alias:{k}"
                    print(json.dumps(out, ensure_ascii=False))
                    sys.exit(0)
                print(json.dumps({"error": "alias_target_missing", "persona_id": pid}, ensure_ascii=False), file=sys.stderr)
                sys.exit(1)
    except (OSError, json.JSONDecodeError) as e:
        print(json.dumps({"error": "aliases_unreadable", "detail": str(e)}, ensure_ascii=False), file=sys.stderr)
        sys.exit(1)

# 2) Mother roles.json fields
hits = []
for p in data.get("personas", []):
    keys = {str(p.get("id", "")).lower(), str(p.get("role_name", "")).lower(), str(p.get("given_name", "")).lower()}
    if p.get("name"):
        keys.add(str(p["name"]).lower())
    for n in p.get("nicknames") or []:
        keys.add(str(n).lower())
    if q in keys:
        hits.append(p)
if len(hits) == 1:
    out = dict(hits[0])
    out["_resolved_via"] = "roles.json"
    print(json.dumps(out, ensure_ascii=False))
    sys.exit(0)
if len(hits) > 1:
    print(json.dumps({"ambiguous": True, "ids": [h.get("id") for h in hits]}, ensure_ascii=False), file=sys.stderr)
    sys.exit(2)
sys.exit(1)
PY
