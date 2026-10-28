#!/usr/bin/env bash
# 项目文档体系门禁 —— 号位 = 瀑布阶段 · 名称按 profile 替换 · ≤10 · ROADMAP 例外
#
# 渐进启用：
#   有编号文档 → 全部断言生效（必选号位 · 上限 · 号唯一 · 生成标记 · 未编号白名单）
#   尚无编号文档 → 不 FAIL，只提示；同时校验 templates/project-docs 骨架（母版/CI 也覆盖）
#
# 配置真源：.cursor/config/docs-layout.json · 规则：rules/execution/project-docs.mdc
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"

# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-docs-layout"

echo "=== verify-docs-layout ==="

vc_py "$ROOT" "$CUR" <<'PY'
import json
import re
import sys
from pathlib import Path

root, cur = Path(sys.argv[1]), Path(sys.argv[2])
cfg_path = cur / "config/docs-layout.json"

if not cfg_path.is_file():
    print("FAIL missing config/docs-layout.json — docs 体系门禁会被静默跳过")
    sys.exit(1)

try:
    cfg = json.loads(cfg_path.read_text(encoding="utf-8"))
except json.JSONDecodeError as exc:
    print(f"FAIL config/docs-layout.json invalid JSON ({exc})")
    sys.exit(1)

fails = []


def fail(msg):
    fails.append(msg)


if not cfg.get("enabled"):
    print("OK  docs-layout disabled (enabled=false)")
    sys.exit(0)

slots = cfg.get("slots") or {}
required = sorted(n for n, s in slots.items() if s.get("required"))
generated = {n: s.get("generated") for n, s in slots.items() if s.get("generated")}
max_numbered = int(cfg.get("max_numbered", 10))
allow_unnumbered = set(cfg.get("allow_unnumbered") or [])
roadmap = cfg.get("roadmap_file") or "ROADMAP.md"
docs_dir = root / str(cfg.get("dir", "docs"))


def check_templates():
    tpl = cur / "templates/project-docs"
    if not tpl.is_dir():
        fail("missing templates/project-docs (骨架缺失，无法 bootstrap)")
        return
    for n in sorted(slots):
        if not list(tpl.glob(f"{n}_*.md")):
            fail(f"templates/project-docs missing skeleton for slot {n}")
    for extra in ("README.md", "ROADMAP.md"):
        if not (tpl / extra).is_file():
            fail(f"templates/project-docs missing {extra}")
    for n, kind in sorted(generated.items()):
        hits = list(tpl.glob(f"{n}_*.md"))
        if not hits:
            continue
        text = hits[0].read_text(encoding="utf-8", errors="replace")
        if "<!-- generated:" not in text:
            fail(f"templates/project-docs slot {n} ({kind}) missing generated marker")
    default_profile = str(cfg.get("profile") or "web-fullstack")
    profiles = cfg.get("profiles") or {}
    pmap = profiles.get(default_profile) or {}
    for n in ("07", "08"):
        name = pmap.get(n)
        if not name:
            continue
        expected = tpl / f"{n}_{name}.md"
        if not expected.is_file():
            fail(
                f"templates/project-docs missing {expected.name} "
                f"(default profile {default_profile} slot {n})"
            )
    if not profiles:
        fail("docs-layout.json: profiles is empty (无法按项目类型替换名称)")
    for pname, mapping in profiles.items():
        if not isinstance(mapping, dict):
            fail(f"profiles.{pname} must be an object")
            continue
        for n in sorted(s for s in slots if not slots[s].get("required")):
            if n not in mapping and slots[n].get("names"):
                # 条件号位允许不出现在某 profile（该 profile 不启用该号位）
                continue
        for n, name in mapping.items():
            if n not in slots:
                fail(f"profiles.{pname} references unknown slot {n}")
            allowed = slots.get(n, {}).get("names") or []
            if allowed and name not in allowed:
                fail(f"profiles.{pname}.{n}='{name}' not in slots.{n}.names {allowed}")


numbered = []
if docs_dir.is_dir():
    numbered = sorted(
        p for p in docs_dir.glob("*.md") if re.match(r"^\d{2}_", p.name) and p.is_file()
    )

if not numbered:
    check_templates()
    if fails:
        for f in fails:
            print("FAIL docs-layout:", f)
        sys.exit(1)
    print(f"OK  docs 尚未 bootstrap（{docs_dir.name}/ 无编号文档）· 模板骨架完整")
    sys.exit(0)

# --- 已 bootstrap：全部断言生效 ---
if len(numbered) > max_numbered:
    fail(f"{len(numbered)} numbered docs > max_numbered={max_numbered} — 合并同类或下沉 .growing/")

seen = {}
for p in numbered:
    num = p.name[:2]
    seen.setdefault(num, []).append(p.name)
    if num not in slots:
        fail(f"{p.name}: slot {num} not declared in docs-layout.json")
    elif slots[num].get("names"):
        base = p.name[3:-3]                      # 去掉 'NN_' 与 '.md'
        if base not in slots[num]["names"]:
            fail(f"{p.name}: name '{base}' not in slots.{num}.names {slots[num]['names']}")

for num, names in sorted(seen.items()):
    if len(names) > 1:
        fail(f"slot {num} used by multiple files: {', '.join(names)} — 号不可重用（删除留空号）")

for num in required:
    if num not in seen:
        fail(f"required slot {num} ({slots[num].get('role')}) missing — 必选号位 {required}")

for num, kind in sorted(generated.items()):
    if num not in seen:
        continue
    text = next(p for p in numbered if p.name[:2] == num).read_text(encoding="utf-8", errors="replace")
    if "<!-- generated:" not in text:
        fail(f"slot {num} is generated by '{kind}' but lacks the '<!-- generated: ... -->' marker — 禁止手写")

if roadmap and not (docs_dir / roadmap).is_file():
    fail(f"missing {docs_dir.name}/{roadmap}（长期计划必备，例外不加序号）")

for p in sorted(docs_dir.glob("*.md")):
    if re.match(r"^\d{2}_", p.name):
        continue
    if p.name not in allow_unnumbered:
        fail(f"{docs_dir.name}/{p.name}: 未编号文档不在 allow_unnumbered {sorted(allow_unnumbered)}")

if fails:
    for f in fails:
        print("FAIL docs-layout:", f)
    sys.exit(1)
print(f"OK  docs layout clean ({len(numbered)}/{max_numbered} numbered · profile={cfg.get('profile')})")
PY

vc_summary "verify-docs-layout passed."
