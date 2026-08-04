#!/usr/bin/env bash
# Validate scaffold templates: test.sh · verify.sh · tests layout
set -euo pipefail

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_ROOT="$CURSOR_DIR/templates/scaffold"
MANIFEST="$TEMPLATE_ROOT/manifest.json"
# shellcheck source=../lib/platform.sh
source "$CURSOR_DIR/lib/platform.sh"
FAIL=0

fail() { echo "FAIL $1"; FAIL=$((FAIL + 1)); }
ok() { echo "OK  $1"; }

if ! sc_has_json_tool; then
  echo "FAIL: jq or python3 required" >&2
  exit 1
fi

echo "=== scaffold integrity ==="

while IFS= read -r id; do
  dir="$TEMPLATE_ROOT/$id"
  [[ -d "$dir" ]] || { fail "missing dir $id"; continue; }

  for script in scripts/test.sh scripts/verify.sh .github/workflows/ci.yml; do
    [[ -f "$dir/$script" ]] || fail "$id: missing $script"
  done

  test_field="$(sc_manifest_scaffold_field "$MANIFEST" "$id" test)"
  verify_field="$(sc_manifest_scaffold_field "$MANIFEST" "$id" verify)"
  [[ "$test_field" == "scripts/test.sh" ]] || fail "$id: manifest test field"
  [[ "$verify_field" == "scripts/verify.sh" ]] || fail "$id: manifest verify field"

  case "$id" in
    react-vite-ts|vue-vite-ts|nextjs-ts|cpp-cmake|rust-axum)
      [[ -d "$dir/tests" ]] || fail "$id: missing tests/"
      ;;
    go-api)
      [[ -d "$dir/tests/integration" ]] || fail "$id: missing tests/integration/"
      ;;
    python-fastapi)
      [[ -d "$dir/tests/unit" && -d "$dir/tests/integration" ]] || fail "$id: missing tests/unit|integration"
      ;;
  esac

  ok "$id"
done < <(sc_manifest_ids "$MANIFEST")

bundle_root="$TEMPLATE_ROOT/_bundles/user-manual"
if jq -e '.bundles[] | select(.id == "user-manual")' "$MANIFEST" >/dev/null 2>&1; then
  echo ""
  echo "=== bundle integrity ==="
  for f in \
    shared/config/manual.yaml \
    shared/docs/user-guide.md \
    shared/scripts/docs/sync_manual_screenshots.sh \
    shared/scripts/verify/docs/verify_doc_manual.sh \
    web/e2e/manual-walkthrough.spec.ts \
    web/playwright.manual.config.ts
  do
    [[ -f "$bundle_root/$f" ]] && ok "bundle user-manual $f" || fail "bundle missing $f"
  done
fi

bundle_root="$TEMPLATE_ROOT/_bundles/test-report"
if jq -e '.bundles[] | select(.id == "test-report")' "$MANIFEST" >/dev/null 2>&1; then
  echo ""
  echo "=== bundle integrity (test-report) ==="
  for f in \
    shared/config/test-report.yaml \
    shared/docs/test-report.md \
    shared/scripts/docs/collect_test_report.sh \
    shared/scripts/verify/docs/verify_test_report.sh \
    shared/design/test-report/README.md
  do
    [[ -f "$bundle_root/$f" ]] && ok "bundle test-report $f" || fail "bundle missing $f"
  done
fi

[[ "$FAIL" -eq 0 ]] && exit 0
echo "$FAIL scaffold check(s) failed." >&2
exit 1
