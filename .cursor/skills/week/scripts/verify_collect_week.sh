#!/usr/bin/env bash
# week skill — collect-week.py fixture smoke (hyphen + em-dash headings)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/hyphen-repo" "$TMP/emdash-repo"
cat > "$TMP/hyphen-repo/CHANGELOG.md" <<'EOF'
## [1.0.0] - 2026-06-17

### Added

- hyphen heading
EOF
cat > "$TMP/emdash-repo/CHANGELOG.md" <<'EOF'
## [2.0.0] — 2026-06-17

### Added

- em dash heading
EOF

count="$(
  python3 "$SCRIPT_DIR/collect-week.py" \
    --workspace "$TMP" \
    --today 2026-06-17 \
    --format json \
    | python3 -c "import json,sys; print(len(json.load(sys.stdin)['entries']))"
)"

if [[ "$count" != "2" ]]; then
  echo "FAIL: expected 2 changelog entries, got $count" >&2
  exit 1
fi

echo "OK verify_collect_week ($count fixture entries)"
