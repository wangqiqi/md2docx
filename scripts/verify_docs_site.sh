#!/usr/bin/env bash
# VitePress 文档站构建验收
# 用法: bash scripts/verify_docs_site.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm not found (Node.js 20+ required)" >&2
  exit 1
fi

if [[ ! -f package-lock.json ]]; then
  echo "ERROR: package-lock.json missing — run npm install at repo root" >&2
  exit 1
fi

npm ci
npm run docs:build

DIST="$ROOT/docs/.vitepress/dist"
[[ -f "$DIST/index.html" ]] || {
  echo "ERROR: missing $DIST/index.html" >&2
  exit 1
}

GUIDE_PAGES=(
  guide/architecture.html
  guide/development.html
  guide/testing.html
  guide/api-deployment.html
  guide/ci-cd.html
  guide/release.html
  guide/version-workflow.html
)

for page in "${GUIDE_PAGES[@]}"; do
  [[ -f "$DIST/$page" ]] || {
    echo "ERROR: missing $DIST/$page" >&2
    exit 1
  }
done

echo "OK: VitePress docs site built ($(find "$DIST" -type f | wc -l) files)"
