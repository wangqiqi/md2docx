#!/usr/bin/env bash
# skill-bundles.json SSOT vs mother skills/ tree (no temp install).
set -euo pipefail
CUR="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-skill-bundles-ssot"

vc_title
CFG="$CUR/config/skill-bundles.json"
[[ -f "$CFG" ]] || { vc_fail "missing $CFG"; vc_summary; exit 1; }

export CUR CFG
vc_py "$CFG" <<'PY'
import json, os, sys
from pathlib import Path

cur = Path(os.environ["CUR"])
cfg_path = Path(os.environ["CFG"])
data = json.loads(cfg_path.read_text(encoding="utf-8"))

def fail(msg: str) -> None:
    print(f"FAIL {msg}", file=sys.stderr)
    sys.exit(1)

default = data.get("default")
if default != "full":
    fail(f"default must be 'full', got {default!r}")

tools = sorted(data.get("tools_skills") or [])
exclude = sorted((data.get("bundles") or {}).get("core", {}).get("exclude_skills") or [])
if tools != exclude:
    fail(f"tools_skills {tools!r} != core.exclude_skills {exclude!r}")

skills_dir = cur / "skills"
if not skills_dir.is_dir():
    fail(f"missing skills dir {skills_dir}")

on_disk = sorted(
    p.name for p in skills_dir.iterdir() if p.is_dir() and not p.name.startswith(".")
)
for name in exclude:
    if name not in on_disk:
        fail(f"exclude skill {name!r} not on disk under skills/")

full_n = len(on_disk)
core_n = full_n - len(exclude)

print(f"OK  skill-bundles SSOT: full={full_n} core={core_n} tools={len(tools)}")
PY

vc_summary
