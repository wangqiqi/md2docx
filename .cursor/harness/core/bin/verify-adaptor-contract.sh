#!/usr/bin/env bash
# Placeholder adaptors: README sections + install-map.example.json alignment.
set -euo pipefail

_walk="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_ROOT=""
while [[ "$_walk" != "/" ]]; do
  if [[ -f "$_walk/harness/assemble.sh" && -d "$_walk/adaptors" ]]; then
    CURSOR_ROOT="$_walk"
    break
  fi
  _walk="$(dirname "$_walk")"
done
if [[ -z "$CURSOR_ROOT" ]]; then
  echo "FAIL: cannot find .cursor pack root" >&2
  exit 1
fi

CUR="$CURSOR_ROOT"
CORE="$CURSOR_ROOT/harness/core"
# shellcheck source=../lib/verify-common.sh
source "$CORE/lib/verify-common.sh" "verify-adaptor-contract"

vc_title

CONTRACT="$CORE/docs/reference/adaptor-contract.md"
[[ -f "$CONTRACT" ]] && grep -q 'install_dir' "$CONTRACT" \
  && vc_ok "adaptor-contract.md" || vc_fail "missing or incomplete adaptor-contract.md"

MAP="$CORE/config/install-map.example.json"
[[ -f "$MAP" ]] || { vc_fail "missing $MAP"; vc_summary; exit 1; }

export CURSOR_ROOT MAP
vc_py "$MAP" <<'PY'
import json, os, re, sys
from pathlib import Path

root = Path(os.environ["CURSOR_ROOT"])
map_path = Path(os.environ["MAP"])
data = json.loads(map_path.read_text(encoding="utf-8"))
adaptors = data.get("adaptors") or {}

PLACEHOLDERS = ("dsh", "kiro", "trae", "opencode", "zcode")
REQUIRED_HEADINGS = (
    "## Status",
    "## Identity",
    "## Install map",
    "## Includes",
    "## Next sprint",
)

failures: list[str] = []

def fail(msg: str) -> None:
    failures.append(msg)

for aid in PLACEHOLDERS:
    if aid not in adaptors:
        fail(f"install-map missing adaptors.{aid}")
        continue
    entry = adaptors[aid]
    readme = root / "adaptors" / aid / "README.md"
    layout = root / "adaptors" / aid / "docs" / "layout.md"
    if not readme.is_file():
        fail(f"missing {readme}")
        continue
    if not layout.is_file():
        fail(f"missing {layout}")

    text = readme.read_text(encoding="utf-8")
    if "layout.md" not in text:
        fail(f"{aid}/README.md should link to docs/layout.md")
    if "adaptor-contract:v1" not in text:
        fail(f"{aid}/README.md missing adaptor-contract:v1 marker")
    for h in REQUIRED_HEADINGS:
        if h not in text:
            fail(f"{aid}/README.md missing heading {h}")

    id_pat = re.compile(
        r"adaptor id`:\s*\*\*" + re.escape(aid) + r"\*\*", re.I
    )
    if not id_pat.search(text):
        fail(f"{aid}/README.md adaptor id does not match {aid}")

    install_dir = entry.get("install_dir")
    if install_dir and install_dir not in text:
        fail(f"{aid}/README.md missing install_dir {install_dir!r}")

    growth_dir = entry.get("growth_dir")
    if growth_dir and growth_dir not in text:
        fail(f"{aid}/README.md missing growth_dir {growth_dir!r}")

    includes = entry.get("includes") or []
    for inc in includes:
        if inc not in text:
            fail(f"{aid}/README.md missing includes token {inc!r}")

    if "hooks_manifest" in entry:
        hooks = entry["hooks_manifest"]
        if hooks is None:
            if "hooks_manifest" not in text.lower():
                fail(f"{aid}/README.md should document hooks_manifest")
        elif str(hooks) not in text:
            fail(f"{aid}/README.md missing hooks_manifest {hooks!r}")
    elif "hooks_manifest" not in text.lower():
        fail(f"{aid}/README.md should document hooks_manifest")

if failures:
    for f in failures:
        print(f"FAIL {f}", file=sys.stderr)
    sys.exit(1)
PY

vc_summary "verify-adaptor-contract passed."
