#!/usr/bin/env bash
# CHANGELOG 结构门禁 —— 同版本不得重复小节（曾真实发生：per-commit 追加各写一个 `### Added`）
#
# 规则真源：rules/feedback/changelog.mdc · 版本节点与文件名来自 config/release.json
#   - 必须存在 `## [Unreleased]`（follow-up 的落地区）
#   - 同一版本节点内 `### X` **不得重复**（要追加就并进已有小节）
#   - 已知小节的**相对顺序**固定：Added → Changed → Deprecated → Removed → Fixed → Security
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"

# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-changelog"

echo "=== verify-changelog ==="

vc_py "$ROOT" "$CUR" <<'PY'
import json
import re
import sys
from pathlib import Path

root, cur = Path(sys.argv[1]), Path(sys.argv[2])
cfg_path = cur / "config/release.json"

changelog = "CHANGELOG.md"
if cfg_path.is_file():
    try:
        changelog = json.loads(cfg_path.read_text(encoding="utf-8")).get("changelog_file") or changelog
    except json.JSONDecodeError:
        pass

path = root / changelog
if not path.is_file():
    # 渐进启用：项目尚未建立 CHANGELOG 时不判失败（母版自身有 → 仍被强约束）
    print(f"OK  {changelog} 尚未建立（跳过结构校验；/release 时会用到）")
    sys.exit(0)

text = path.read_text(encoding="utf-8", errors="replace")

# 规范顺序（Keep a Changelog 子集）；未列出的自定义小节不参与顺序校验
CANON = ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security"]

nodes = []           # (heading, [(subsection, line_no)])
bodies = {}          # heading -> [(line_no, text)] 标题之后到下一节点之前
current = None
for i, line in enumerate(text.splitlines(), 1):
    if line.startswith("## "):
        current = (line.strip(), [])
        nodes.append(current)
        bodies[current[0]] = []
    elif current is not None:
        if line.startswith("### "):
            current[1].append((line[4:].strip(), i))
        bodies[current[0]].append((i, line))

fails = []


def fail(msg):
    fails.append(msg)


if not any(h.startswith("## [Unreleased]") for h, _ in nodes):
    fail(f"{changelog}: missing '## [Unreleased]' (follow-up 需要落地区)")

if not nodes:
    fail(f"{changelog}: no '## [version]' nodes found")

for heading, subs in nodes:
    names = [s for s, _ in subs]
    seen = {}
    for name, line_no in subs:
        seen.setdefault(name, []).append(line_no)

    # 1. 同版本内不得重复小节（本门禁的由来）
    for name, lines in seen.items():
        if len(lines) > 1:
            fail(
                f"{changelog}:{lines[0]} {heading} has {len(lines)} '### {name}' sections "
                f"(lines {lines}) — 追加条目请并进已有小节"
            )

    # 1b. 版本标题下必须先有 `### ` 子节：条目直接挂在 `## [x.y.z]` 后面说明插错了节点
    #     （真实事故：per-commit 追加把 5 条 follow-up 写进了已发布的 4.29.8 节点）
    for line_no, raw in bodies.get(heading, []):
        if not raw.strip():
            continue
        if not raw.startswith("### ") and raw.lstrip().startswith("- "):
            fail(
                f"{changelog}:{line_no} {heading} starts with content before any '### ' subsection "
                f"({raw.strip()[:50]!r}) — 列表条目漏到了错误节点（必须先有 ### 子节）"
            )
        break

    # 2. 已知小节必须按规范顺序出现 —— 仅约束 [Unreleased]（落地区）；
    #    已发布节点的顺序是历史，重排会制造无意义的 diff
    if not heading.startswith("## [Unreleased]"):
        continue
    known = [(CANON.index(name), line_no) for name, line_no in subs if name in CANON]
    if [k for k, _ in known] != sorted(k for k, _ in known):
        order = " → ".join(name for name, _ in subs)
        fail(f"{changelog}:{subs[0][1]} {heading} subsection order is {order}; expected {CANON}")

if fails:
    for f in fails:
        print("FAIL changelog:", f)
    sys.exit(1)

print(f"OK  changelog structure clean ({len(nodes)} version nodes · no duplicate sections)")
PY

vc_summary "verify-changelog passed."
