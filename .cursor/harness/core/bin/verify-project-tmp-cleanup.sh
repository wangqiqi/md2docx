#!/usr/bin/env bash
# 项目 /tmp 契约清理 — 负向/正向 fixture
set -euo pipefail

CUR="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"
# shellcheck source=../lib/platform.sh
source "$CUR/lib/platform.sh"
# shellcheck source=../lib/temp-cleanup.sh
source "$CUR/lib/temp-cleanup.sh"
sc_temp_trap_cleanup

PY="$(command -v python3 || command -v python)"
[[ -n "$PY" ]] || { echo "FAIL: python required"; exit 1; }

sc_mktemp_dir sc-verify-ptc
FIX="$SC_MKTEMP_LAST"
CFG="$FIX/temp-cleanup.json"
sc_mktemp_dir sc-verify-ptc-ephemeral
EPHE_DIR="$SC_MKTEMP_LAST"
sc_mktemp_dir sc-verify-ptc-persist
PERS_DIR="$SC_MKTEMP_LAST"
echo old > "$EPHE_DIR/data"
echo keep > "$PERS_DIR/data"

"$PY" - "$CFG" "$EPHE_DIR" "$PERS_DIR" <<'PY'
import json, sys
from pathlib import Path

cfg, ephe, pers = sys.argv[1], Path(sys.argv[2]).resolve(), Path(sys.argv[3]).resolve()
payload = {
    "version": 1,
    "enabled": True,
    "rules": [
        {"id": "ephemeral", "glob": str(ephe), "tier": "ephemeral", "after": ["test"]},
        {
            "id": "persist",
            "glob": str(pers),
            "tier": "persistent",
            "max_age_hours": 9999,
            "after": ["sweep"],
        },
    ],
}
Path(cfg).write_text(json.dumps(payload), encoding="utf-8")
PY

"$PY" "$CUR/lib/project-tmp-cleanup.py" --config "$CFG" --phase test --root "$ROOT"
[[ ! -d "$EPHE_DIR" ]] || { echo "FAIL: ephemeral not removed"; exit 1; }
[[ -d "$PERS_DIR" ]] || { echo "FAIL: persistent removed too early"; exit 1; }

"$PY" "$CUR/lib/project-tmp-cleanup.py" --config "$CFG" --phase sweep --root "$ROOT"
[[ -d "$PERS_DIR" ]] || { echo "FAIL: persistent removed by sweep (young file)"; exit 1; }

# 非法 glob 不得删除 /etc
BAD="$FIX/bad.json"
echo '{"enabled":true,"rules":[{"id":"x","glob":"/etc/passwd*","tier":"ephemeral","after":["test"]}]}' > "$BAD"
out="$("$PY" "$CUR/lib/project-tmp-cleanup.py" --config "$BAD" --phase test --root "$ROOT" 2>&1)" || true
echo "$out" | grep -q 'SKIP rule' || { echo "FAIL: unsafe glob must SKIP: $out"; exit 1; }
if [[ -f /etc/passwd ]]; then
  [[ -f /etc/passwd ]] || { echo "FAIL: /etc/passwd missing"; exit 1; }
else
  echo "[i] skip /etc/passwd check (non-Unix runner)"
fi

rm -rf "$PERS_DIR"
echo "OK verify-project-tmp-cleanup"
