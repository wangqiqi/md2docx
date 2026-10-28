#!/usr/bin/env bash
# Doc-coherence checks for Super Cursor mother repo (aggregated by verify-super-cursor.sh).
set -euo pipefail

_walk="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT=""
while [[ "$_walk" != "/" ]]; do
  if [[ -f "$_walk/install-super-cursor.sh" ]]; then
    ROOT="$_walk"
    break
  fi
  _walk="$(dirname "$_walk")"
done
[[ -n "$ROOT" ]] || { echo "FAIL: repo root not found" >&2; exit 1; }
CUR="$ROOT/.cursor"

# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-doc-super-cursor"

echo "=== verify-doc-super-cursor ==="

# --- README skills count vs disk ---
disk_skills="$(find -L "$CUR/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
readme_line="$(grep -E 'skills/.*[0-9]+ 个' "$ROOT/README.md" 2>/dev/null | head -1 || true)"
if [[ -z "$readme_line" ]]; then
  vc_fail "README.md missing skills count line (N 个)"
else
  readme_skills="$(echo "$readme_line" | grep -oE '[0-9]+ 个' | head -1 | grep -oE '[0-9]+' || true)"
  if [[ "$readme_skills" == "$disk_skills" ]]; then
    vc_ok "README skills count=$disk_skills matches disk"
  else
    vc_fail "README skills count=$readme_skills disk=$disk_skills"
  fi
fi

# --- migration-catalog skills/rules counts (optional line) ---
mc="$CUR/docs/migration-catalog.md"
if [[ -f "$mc" ]]; then
  disk_rules="$(find -L "$CUR/rules" -name '*.mdc' 2>/dev/null | wc -l | tr -d ' ')"
  if grep -qE "${disk_skills} skills" "$mc" && grep -qE "${disk_rules} rules" "$mc"; then
    vc_ok "migration-catalog counts skills=$disk_skills rules=$disk_rules"
  else
    vc_fail "migration-catalog counts mismatch (expect ${disk_skills} skills · ${disk_rules} rules)"
  fi
else
  vc_fail "missing $mc"
fi

# --- doc-hygiene rule registered ---
check_rule() {
  [[ -f "$1" ]] && vc_ok "exists $1" || vc_fail "missing $1"
}
check_rule "$CUR/rules/execution/doc-hygiene.mdc"

# --- 双语最低集（A5）：英文入口存在且被主 README 链接 ---
if [[ -f "$ROOT/README.en.md" ]] \
  && grep -q 'README\.en\.md' "$ROOT/README.md" \
  && [[ -f "$CUR/docs/quickstart.en.md" ]]; then
  vc_ok "bilingual entry (README.en.md + docs/quickstart.en.md) present and linked"
else
  vc_fail "bilingual entry missing or not linked from README.md (README.en.md · docs/quickstart.en.md)"
fi

# --- skill metadata 契约：description ≤85 字 + dmi 分桶（防再次被删的回归）---
# 该节曾在 ef5521b 被静默删除且无人发现；此处断言存在性 + 实际元数据
training="$CUR/docs/training/skills.md"
if grep -q 'disable-model-invocation' "$training" 2>/dev/null \
  && grep -q '≤85' "$training" 2>/dev/null; then
  vc_ok "training/skills.md documents dmi policy + description cap"
else
  vc_fail "training/skills.md missing disable-model-invocation policy section"
fi

# --- slash SSOT: routes.md canonical; README/training no full 3-tier Command tables ---
routes="$CUR/skills/master/routes.md"
readme="$CUR/README.md"
naming="$CUR/docs/naming.md"
[[ -f "$routes" ]] || vc_fail "missing $routes"
grep -q "## 主路由" "$routes" || vc_fail "routes.md missing 主路由 section"
grep -qE 'skills/master/routes\.md|master/routes\.md' "$readme" \
  || vc_fail ".cursor/README.md must link skills/master/routes.md (slash SSOT)"
grep -qE 'routes\.md.*canonical|canonical.*routes|路由详表.*routes\.md' "$training" \
  || vc_fail "training/skills.md must declare routes.md canonical"
grep -qE 'routes\.md|master/routes' "$naming" \
  || vc_fail "naming.md must reference routes.md for slash SSOT"
if grep -q '### 【日常】' "$readme" && grep -q '### 【生命周期】' "$readme" \
  && grep -qE '\| `/scaffold` \|' "$readme"; then
  vc_fail ".cursor/README.md still has full 3-tier slash tables; summary + routes.md only"
fi
if grep -q '| `scaffold` |' "$training" && grep -q '主路由（第 1 轮' "$training"; then
  vc_fail "training/skills.md duplicates routes.md main route table"
fi
vc_ok "slash SSOT (routes.md canonical · README/training no 3-tier duplicate tables)"

# --- Plugin MVP docs: install primary + sync/verify commands ---
platform_learn="$CUR/templates/growing/learn/cursor-platform.md"
cloud_doc="$CUR/docs/cursor-cloud.md"
[[ -f "$cloud_doc" ]] || cloud_doc="$CUR/adaptors/cursor/docs/cursor-cloud.md"
[[ -f "$platform_learn" ]] || vc_fail "missing cursor-platform.md learn template"
[[ -f "$cloud_doc" ]] || vc_fail "missing cursor-cloud.md (core or adaptors/cursor/docs)"
grep -q "## Plugin MVP" "$platform_learn" || vc_fail "cursor-platform.md missing Plugin MVP section"
grep -q "install-super-cursor" "$platform_learn" || vc_fail "cursor-platform.md must state install primary path"
grep -q "sync-plugin-subset" "$platform_learn" || vc_fail "cursor-platform.md missing sync-plugin-subset"
grep -q "## Plugin MVP" "$cloud_doc" || vc_fail "cursor-cloud.md missing Plugin MVP section"
grep -q "verify-cursor-plugin-mvp" "$cloud_doc" || vc_fail "cursor-cloud.md missing plugin verify command"
grep -qF "agents" "$platform_learn" || vc_fail "cursor-platform.md must document plugin agents"
grep -qF "ship" "$cloud_doc" || vc_fail "cursor-cloud.md must mention plugin agents (ship)"
grep -qF "verify-spike-plugin-agents-scope" "$ROOT/.cursor/verify-super-cursor.sh" \
  || vc_fail "verify-super-cursor must wire verify-spike-plugin-agents-scope"
vc_ok "Plugin MVP docs (install primary · agents · cursor-platform + cursor-cloud)"

grep -q "## 分发三轨" "$platform_learn" || vc_fail "cursor-platform.md missing 分发三轨 section"
grep -q "## Hooks 与 config" "$platform_learn" || vc_fail "cursor-platform.md missing Hooks 与 config section"
grep -q "分发三轨" "$cloud_doc" || vc_fail "cursor-cloud.md missing 分发三轨 table"
grep -q "config-load" "$cloud_doc" || vc_fail "cursor-cloud.md missing hooks config dependency"
grep -qF "cursor-plugin" "$CUR/config/skill-bundles.json" || vc_fail "skill-bundles.json must reference plugin boundary"
grep -qF "verify-spike-plugin-phase2-scope" "$ROOT/.cursor/verify-super-cursor.sh" \
  || vc_fail "verify-super-cursor must wire verify-spike-plugin-phase2-scope"
vc_ok "plugin phase2 docs (三轨 · hooks/config · skill-bundles · verify wire)"

plugin_readme="$ROOT/.cursor-plugin/README.md"
[[ -f "$plugin_readme" ]] || vc_fail "missing .cursor-plugin/README.md"
grep -q "## Marketplace" "$platform_learn" || vc_fail "cursor-platform.md missing Marketplace section"
grep -qF "marketplace_prep_scope" "$platform_learn" || vc_fail "cursor-platform.md missing marketplace prep archive pointer"
grep -q "## Marketplace" "$cloud_doc" || vc_fail "cursor-cloud.md missing Marketplace section"
grep -qF "verify-spike-marketplace-prep-scope" "$cloud_doc" || vc_fail "cursor-cloud.md missing marketplace prep verify command"
grep -q "## Marketplace" "$plugin_readme" || vc_fail ".cursor-plugin/README.md missing Marketplace section"
grep -qF "marketplace_prep_scope" "$plugin_readme" || vc_fail ".cursor-plugin/README.md missing marketplace prep archive pointer"
grep -qF "verify-spike-marketplace-prep-scope" "$mc" || vc_fail "migration-catalog missing marketplace prep verifier"
grep -qF "verify-spike-marketplace-prep-scope" "$ROOT/.cursor/verify-super-cursor.sh" \
  || vc_fail "verify-super-cursor must wire verify-spike-marketplace-prep-scope"
vc_ok "marketplace prep docs (platform · cloud · plugin README · catalog · verify wire)"

grep -q "## Skills bundle" "$platform_learn" || vc_fail "cursor-platform.md missing Skills bundle section"
grep -q "skill-bundles.json" "$platform_learn" || vc_fail "cursor-platform.md missing skill-bundles.json"
grep -q "## Skills bundle" "$cloud_doc" || vc_fail "cursor-cloud.md missing Skills bundle section"
grep -q "verify-install-skills-bundle" "$cloud_doc" || vc_fail "cursor-cloud.md missing verify-install-skills-bundle"
grep -qF 'skills-bundle' "$ROOT/README.md" || vc_fail "README.md missing --skills-bundle option"
vc_ok "skills bundle docs (README · cursor-platform · cursor-cloud)"

grep -q "## 分发三轨" "$mc" || vc_fail "migration-catalog missing 分发三轨 section"
grep -q "## 母版 verify 索引" "$mc" || vc_fail "migration-catalog missing 母版 verify 索引 section"
grep -qF "verify-spike-mother-hygiene-scope" "$mc" || vc_fail "migration-catalog missing hygiene verifier"
grep -qF "**hygiene**" "$ROOT/README.md" || vc_fail "README.md missing hygiene verify group"
grep -qF "migration-catalog" "$ROOT/README.md" || vc_fail "README.md must link migration-catalog verify index"
grep -qF "verify-spike-mother-hygiene-scope" "$ROOT/README.md" || vc_fail "README.md must mention verify-spike-mother-hygiene-scope"
if grep -qF "11 道门禁" "$ROOT/README.md"; then
  vc_fail "README.md still mentions obsolete 11 道门禁"
fi
grep -qF "verify-spike-mother-hygiene-scope" "$ROOT/.cursor/verify-super-cursor.sh" \
  || vc_fail "verify-super-cursor must wire verify-spike-mother-hygiene-scope"
vc_ok "mother hygiene facade (migration-catalog · README · verify wire)"

grep -qF "onekey_bootstrap" "$CUR/config/README.md" || vc_fail "config/README.md missing growth.onekey_bootstrap"
grep -qF "verify-onekey-template" "$mc" || vc_fail "migration-catalog missing verify-onekey-template"
grep -qF "verify-spike-onekey-bootstrap-scope" "$mc" || vc_fail "migration-catalog missing verify-spike-onekey-bootstrap-scope"
grep -qF "verify-onekey-template" "$ROOT/README.md" || vc_fail "README.md missing verify-onekey-template"
grep -qF "onekey_start.sh" "$CUR/docs/building-super-cursor.md" || vc_fail "building-super-cursor missing onekey触发表"
grep -qF "templates/project-onekey" "$CUR/docs/scaffold.md" || vc_fail "scaffold.md missing project-onekey pointer"
grep -qF "verify-onekey-template" "$ROOT/.cursor/verify-super-cursor.sh" \
  || vc_fail "verify-super-cursor must wire verify-onekey-template"
grep -qF "verify-spike-onekey-bootstrap-scope" "$ROOT/.cursor/verify-super-cursor.sh" \
  || vc_fail "verify-super-cursor must wire verify-spike-onekey-bootstrap-scope"
vc_ok "onekey bootstrap docs (config · catalog · README · building · scaffold · verify wire)"

tpl_07="$CUR/templates/project-docs/07_用户手册.md"
tpl_08="$CUR/templates/project-docs/08_测试报告.md"
learn_pc="$CUR/templates/growing/learn/plan-conventions.md"
[[ -f "$tpl_07" ]] || vc_fail "templates/project-docs/07_用户手册.md missing"
[[ -f "$tpl_08" ]] || vc_fail "templates/project-docs/08_测试报告.md missing"
grep -qF "generated: manual" "$tpl_07" || vc_fail "07 template missing manual generated marker"
grep -qF "generated: report" "$tpl_08" || vc_fail "08 template missing report generated marker"
grep -qF "docs-layout.json" "$learn_pc" || vc_fail "plan-conventions missing docs-layout.json pointer"
grep -qF "docs-init" "$CUR/docs/building-super-cursor.md" || vc_fail "building-super-cursor missing docs-init"
grep -qF "docs-init" "$mc" || vc_fail "migration-catalog missing docs-init"
vc_ok "project-docs SSOT (07/08 templates · plan-conventions · contributor docs)"

vc_py "$CUR" <<'PY'
import re, sys
from pathlib import Path

cur = Path(sys.argv[1])
dmi_expected = {
    "plan", "run", "learn", "scaffold", "release", "long",
    "week", "disk", "maintain", "code-stats-viz", "ops-deploy",
}
fails = []

for p in sorted((cur / "skills").glob("*/SKILL.md")):
    name = p.parent.name
    text = p.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---", text, re.S)
    if not m:
        fails.append(f"{name}: missing frontmatter")
        continue
    fm = m.group(1)
    dm = re.search(r"^description:\s*(.*?)(?=\n[A-Za-z_-]+:|\Z)", fm, re.S | re.M)
    desc = re.sub(r"\s+", " ", (dm.group(1) if dm else "")).strip()
    if len(desc) > 85:
        fails.append(f"{name}: description {len(desc)} chars (>85)")
    has_dmi = bool(re.search(r"^disable-model-invocation:\s*true\s*$", fm, re.M))
    if has_dmi != (name in dmi_expected):
        fails.append(f"{name}: disable-model-invocation={has_dmi}, policy expects {name in dmi_expected}")

# master 路由 payload：主路由须内联在 SKILL.md（routes.md 为按需二级索引）
master = cur / "skills/master/SKILL.md"
if not master.is_file():
    fails.append("skills/master/SKILL.md missing")
else:
    mt = master.read_text(encoding="utf-8")
    if len(mt) > 3000:
        fails.append(f"master/SKILL.md {len(mt)} chars (>3000): routing payload must stay inline and small")
    for rid in ("scaffold", "plan", "run", "learn", "fix", "ship", "more"):
        if not re.search(r"\|\s*`?" + rid + r"`?\s*\|", mt):
            fails.append(f"master/SKILL.md missing main route id '{rid}' (routing moved out of the default payload)")

# 巨型 SKILL 必须瘦身到 reference/（C5）：主流程留 SKILL，细节按需加载
for name, limit in (("run", 5000), ("plan", 5000)):
    p = cur / f"skills/{name}/SKILL.md"
    if not p.is_file():
        fails.append(f"skills/{name}/SKILL.md missing")
        continue
    size = len(p.read_text(encoding="utf-8"))
    if size > limit:
        fails.append(f"skills/{name}/SKILL.md {size} chars (>{limit}): move detail into reference/")
    if not (cur / f"skills/{name}/reference").is_dir():
        fails.append(f"skills/{name}/reference missing (detail must live there, not in SKILL)")

if fails:
    for f in fails:
        print("FAIL skill metadata:", f)
    sys.exit(1)
print(f"OK  skill metadata (28 files · description <=85 · dmi buckets · run/plan slim)")
PY

# --- relative markdown links under .cursor/docs ---
vc_py "$CUR/docs" "$CUR" <<'PY'
import re, sys
from pathlib import Path
from typing import Optional

docs_root = Path(sys.argv[1]).resolve()
pack_root = Path(sys.argv[2]).resolve()

def pack_relative_fallback(path_part: str) -> Optional[Path]:
    """Harness 分区：core/docs 常链到 adaptors/（Windows 下纯 resolve 偶发失败）。"""
    norm = path_part.replace("\\", "/")
    while norm.startswith("../"):
        norm = norm[3:]
    if not norm or norm.startswith("/"):
        return None
    candidate = (pack_root / norm).resolve()
    return candidate if candidate.is_file() else None

link_re = re.compile(r'\]\(([^)]+)\)')
skip_prefix = ("http://", "https://", "mailto:", "#")
broken = []

for md in sorted(docs_root.rglob("*.md")):
    text = md.read_text(encoding="utf-8", errors="replace")
    for raw in link_re.findall(text):
        target = raw.split()[0].strip()
        if not target or target.startswith(skip_prefix):
            continue
        # strip anchor
        path_part = target.split("#", 1)[0]
        if not path_part:
            continue
        resolved = (md.parent / path_part).resolve()
        if resolved.exists():
            continue
        alt = pack_relative_fallback(path_part)
        if alt and alt.exists():
            continue
        broken.append(f"{md.relative_to(docs_root).as_posix()} -> {target}")

if broken:
    for b in broken[:20]:
        print("FAIL broken link:", b)
    if len(broken) > 20:
        print("FAIL ... and", len(broken) - 20, "more")
    sys.exit(1)
print("OK  relative links in .cursor/docs (%d files)" % len(list(docs_root.rglob('*.md'))))
sys.exit(0)
PY

# --- README facade: version badge + scaffold count vs CHANGELOG / manifest ---
changelog_ver="$(grep -m1 -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$ROOT/CHANGELOG.md" | sed -E 's/^## \[([0-9]+\.[0-9]+\.[0-9]+)\].*/\1/' || true)"
if [[ -z "$changelog_ver" ]]; then
  vc_fail "CHANGELOG.md missing released version header"
elif grep -q "version-${changelog_ver}" "$ROOT/README.md" 2>/dev/null \
  || grep -q "version-${changelog_ver//./-}" "$ROOT/README.md" 2>/dev/null; then
  vc_ok "README version badge matches CHANGELOG ($changelog_ver)"
else
  vc_fail "README version badge must match latest CHANGELOG ($changelog_ver)"
fi

manifest_stacks=""
_py_manifest="$(vc_python 2>/dev/null || true)"
if [[ -n "$_py_manifest" ]]; then
  manifest_stacks="$("$_py_manifest" - "$ROOT" <<'PY'
import json, sys
from pathlib import Path
m = Path(sys.argv[1]) / ".cursor/templates/scaffold/manifest.json"
data = json.loads(m.read_text(encoding="utf-8"))
ids = [s["id"] for s in data.get("scaffolds", []) if isinstance(s, dict) and s.get("id")]
print(len(ids))
PY
)"
fi
unset _py_manifest
if [[ -z "$manifest_stacks" || "$manifest_stacks" -lt 1 ]]; then
  vc_fail "could not read scaffold manifest stack count"
elif grep -qE "scaffolds-${manifest_stacks}%20stacks" "$ROOT/README.md" 2>/dev/null; then
  vc_ok "README scaffold badge matches manifest ($manifest_stacks stacks)"
else
  vc_fail "README scaffold badge must be ${manifest_stacks} stacks (manifest.json)"
fi

for stale in "7 栈" "7 stacks" "scaffolds-7%20stacks"; do
  if grep -qF "$stale" "$ROOT/README.md" \
    || grep -qF "$stale" "$CUR/docs/quickstart.md" \
    || grep -qF "$stale" "$CUR/docs/training/skills.md" 2>/dev/null; then
    vc_fail "stale scaffold count ($stale) in README or .cursor/docs facade"
  fi
done
vc_ok "facade docs use current scaffold count (no 7-stack drift)"

# --- v5: runtime dir SSOT is .growing (legacy path only in install + CHANGELOG Breaking) ---
if git -C "$ROOT" grep -rnE '\.growing|templates/cursorGrowth' -- . \
  ':(exclude)install-super-cursor.sh' \
  ':(exclude)CHANGELOG.md' \
  ':(exclude).cursor/harness/core/bin/verify-doc-super-cursor.sh' \
  ':(exclude).cursor/bin/verify-doc-super-cursor.sh' \
  2>/dev/null | grep -q .; then
  vc_fail "legacy .growing path outside install migration + CHANGELOG (SSOT must be .growing)"
else
  vc_ok "no legacy .growing path outside install/CHANGELOG"
fi

vc_summary "verify-doc-super-cursor passed."
