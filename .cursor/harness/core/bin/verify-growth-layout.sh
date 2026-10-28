#!/usr/bin/env bash
# Growth layout SOP checks (archive domain subdirs · scripts tree) — mother repo.
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"

# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-growth-layout"

echo "=== verify-growth-layout ==="

SSOT="$CUR/skills/plan/reference/growth-layout.md"
META_SSOT="$CUR/skills/plan/reference/growth-meta-ci-dual.md"
[[ -f "$SSOT" ]] && vc_ok "growth-layout.md exists" || vc_fail "missing $SSOT"
[[ -f "$META_SSOT" ]] && vc_ok "growth-meta-ci-dual.md exists" || vc_fail "missing $META_SSOT"
if [[ -f "$META_SSOT" ]] \
  && grep -q 'sc_growth_archive_available' "$META_SSOT" \
  && grep -q 'archive/meta' "$META_SSOT" \
  && grep -q 'SKIP' "$META_SSOT"; then
  vc_ok "growth-meta-ci-dual documents meta SKIP semantics"
else
  vc_fail "growth-meta-ci-dual missing meta/SKIP/sc_growth_archive_available"
fi
if [[ -f "$SSOT" ]] && grep -q 'archive/meta' "$SSOT" && grep -q 'growth-meta-ci-dual' "$SSOT"; then
  vc_ok "growth-layout links meta domain to dual-track SSOT"
else
  vc_fail "growth-layout missing archive/meta or growth-meta-ci-dual link"
fi

need_ref=(
  "$CUR/rules/execution/doc-hygiene.mdc"
  "$CUR/rules/feedback/verify.mdc"
  # run 的 Sprint 收尾细则已移入 reference/（C5 去重）→ 引用跟着落点走
  "$CUR/skills/run/reference/sprint-closeout.md"
  "$CUR/skills/scaffold/SKILL.md"
  "$CUR/templates/growing/learn/plan-conventions.md"
)

for f in "${need_ref[@]}"; do
  if [[ -f "$f" ]] && grep -q 'growth-layout' "$f"; then
    vc_ok "$(basename "$f") references growth-layout"
  else
    vc_fail "$(basename "$f") missing growth-layout reference"
  fi
done

if [[ -f "$CUR/templates/growing/learn/plan-conventions.md" ]] \
  && grep -q 'archive/{domain}/' "$CUR/templates/growing/learn/plan-conventions.md"; then
  vc_ok "plan-conventions template uses archive/{domain}/"
else
  vc_fail "plan-conventions template missing archive/{domain}/"
fi

if [[ -f "$SSOT" ]] \
  && grep -q 'verify/domain/' "$SSOT" \
  && grep -q 'verify/tier/' "$SSOT"; then
  vc_ok "growth-layout documents scripts verify/ tree"
else
  vc_fail "growth-layout missing scripts verify/ tree"
fi

if [[ -f "$SSOT" ]] \
  && grep -qE '\| `sprint`' "$SSOT" \
  && grep -qE '\| `spike`' "$SSOT"; then
  vc_ok "growth-layout lists default archive domains"
else
  vc_fail "growth-layout missing default archive domain table"
fi

# archive 域分层（根目录不得长期堆 flat 文件）
if bash "$CUR/bin/runner.sh" archive-check >/tmp/vg-archive.$$ 2>&1; then
  vc_ok "archive domains ($(tail -1 /tmp/vg-archive.$$))"
else
  vc_fail "archive flat files exceed threshold — 见 runner.sh archive-check"
fi
rm -f /tmp/vg-archive.$$

if grep -q 'verify-growth-layout.sh' "$CUR/verify-super-cursor.sh" 2>/dev/null; then
  vc_ok "verify-super-cursor aggregates verify-growth-layout"
else
  vc_fail "verify-super-cursor.sh must call verify-growth-layout.sh"
fi

vc_summary "verify-growth-layout passed."
