#!/usr/bin/env bash
# npm audit 门禁：VitePress 文档站（与 CI pages / docs-security job 同策略）
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

REGISTRY="${NPM_AUDIT_REGISTRY:-https://registry.npmjs.org}"

if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm not found (Node.js 20+ required)" >&2
  exit 1
fi

if [[ ! -f package-lock.json ]]; then
  echo "ERROR: package-lock.json missing — run npm install at repo root" >&2
  exit 1
fi

echo "=== npm audit (docs deps · audit-level=critical · registry=$REGISTRY) ==="
npm ci --registry="$REGISTRY"
npm audit --audit-level=critical --registry="$REGISTRY"
echo "OK: check_npm_audit passed"
