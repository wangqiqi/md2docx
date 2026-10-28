#!/usr/bin/env bash
# 脚本分层 + 公因子门禁 —— 让「减少重复的 verify · 提取公因子」可执行
#
# 两种模式：
#   project   — 目标项目有 `scripts/`：查分层（根只留入口）· scripts/README.md · 根脚本体量 · 重复块
#   templates — 母版仓无 `scripts/`：改查 scaffold 模板（_shared + 7 栈）的重复块与 shebang
#
# 重复块 = 两个脚本共享 ≥N 行连续相同内容 → 应提取到 `lib/_*.sh`。
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"

# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-scripts-layout"

# 全项目可调：DUPLICATE_BLOCK_LINES（默认 4）· ROOT_SCRIPT_MAX_LINES（默认 40）· ROOT_SCRIPT_MAX_COUNT（默认 6）
DUP_LINES="${DUPLICATE_BLOCK_LINES:-4}"
ROOT_MAX_LINES="${ROOT_SCRIPT_MAX_LINES:-40}"
ROOT_MAX_COUNT="${ROOT_SCRIPT_MAX_COUNT:-6}"

echo "=== verify-scripts-layout ==="

if [[ -d "$ROOT/scripts" ]]; then
  MODE="project"
  vc_info "mode=project ($ROOT/scripts)"
else
  MODE="templates"
  vc_info "mode=templates（本仓无 scripts/ → 校验 scaffold 模板）"
fi

vc_py "$ROOT" "$CUR" "$MODE" "$DUP_LINES" "$ROOT_MAX_LINES" "$ROOT_MAX_COUNT" <<'PY'
import re
import sys
from pathlib import Path

root, cur, mode, dup_lines, root_max_lines, root_max_count = (
    Path(sys.argv[1]),
    Path(sys.argv[2]),
    sys.argv[3],
    int(sys.argv[4]),
    int(sys.argv[5]),
    int(sys.argv[6]),
)

fails = []


def collect(base, recursive=True):
    if not base.is_dir():
        return []
    pat = "**/*.sh" if recursive else "*.sh"
    return sorted(p for p in base.glob(pat) if p.is_file())


def code_lines(path):
    out = []
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        s = raw.strip()
        if not s or s.startswith("#"):
            continue
        if s in ("set -euo pipefail", "set -eu", "set -e"):
            continue
        # 约定前导（每个脚本都该有）不算重复逻辑
        if s.startswith("source ") and "lib/_" in s:
            continue
        if s == "sc_root" or s.startswith("# shellcheck source=lib/_"):
            continue
        if len(s) < 12:          # 跳掉 `fi` / `done` 之类
            continue
        out.append(s)
    return out


def duplicate_blocks(files):
    windows = {}
    for f in files:
        lines = code_lines(f)
        for i in range(len(lines) - dup_lines + 1):
            key = tuple(lines[i:i + dup_lines])
            windows.setdefault(key, []).append(f)
    hits = []
    for key, owners in windows.items():
        uniq = sorted(set(owners))
        if len(uniq) > 1:
            hits.append((uniq, key))
    return hits


if mode == "project":
    scripts = root / "scripts"
    if not (scripts / "README.md").is_file():
        fails.append("scripts/README.md missing (脚本矩阵 SSOT；见 references/growth-layout.md §Scripts 布局)")

    root_scripts = sorted(p for p in scripts.glob("*.sh") if p.is_file())
    if len(root_scripts) > root_max_count:
        fails.append(
            f"scripts/ root has {len(root_scripts)} scripts (>{root_max_count}): root should keep only entries, move implementations into verify/domain|tier, ops/ or dev/"
        )
    for p in root_scripts:
        name = p.name
        lines = len(code_lines(p))
        if lines > root_max_lines and not re.match(r"^(verify|test)", name):
            fails.append(f"scripts/{name} has {lines} logic lines (>{root_max_lines}) in the root: move it under a subdir")
    files = collect(scripts)
else:
    tpl = cur / "templates/scaffold"
    files = collect(tpl / "_shared")
    for stack in sorted(p for p in tpl.iterdir() if p.is_dir() and not p.name.startswith("_")):
        files += collect(stack / "scripts")
    if not files:
        fails.append("no scaffold scripts found to audit")

for f in files:
    first = f.read_text(encoding="utf-8", errors="replace").splitlines()[:1]
    if not first or not first[0].startswith("#!/usr/bin/env bash"):
        fails.append(f"{f.relative_to(root).as_posix()}: shebang must be '#!/usr/bin/env bash'")

for owners, key in duplicate_blocks(files):
    where = ", ".join(o.relative_to(root).as_posix() for o in owners)
    fails.append(
        f"duplicate {dup_lines}-line block in {where} -> extract into scripts/lib/_*.sh :: {key[0][:60]!r}"
    )

# 分层：域/工具脚本不得散落在根（模板模式检查 _shared 结构）
if mode == "templates":
    shared = cur / "templates/scaffold/_shared/scripts"
    for rel in ("README.md", "lib/_common.sh"):
        if not (shared / rel).is_file():
            fails.append(f"missing _shared/scripts/{rel}")

if fails:
    for f in fails:
        print("FAIL scripts-layout:", f)
    sys.exit(1)
print(f"OK  scripts layout clean ({len(files)} scripts · mode={mode} · dup>{dup_lines} lines)")
PY

vc_summary "verify-scripts-layout passed."
