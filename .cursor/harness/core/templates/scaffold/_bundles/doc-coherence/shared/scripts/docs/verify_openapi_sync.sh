#!/usr/bin/env bash
# Template: openapi info.version ↔ package.json (extend with route spot-check when OpenAPI exists).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

[[ -f package.json ]] || { echo "SKIP: no package.json"; exit 0; }
[[ -f docs/openapi.yaml ]] || { echo "SKIP: no docs/openapi.yaml"; exit 0; }
command -v node >/dev/null 2>&1 || { echo "SKIP: node 不可用（该 slice 需要 Node；非 Node 栈可忽略）"; exit 0; }

node <<'NODE'
const { read, mustInclude } = require('./scripts/lib/doc-anchors');
const pkg = JSON.parse(read('package.json'));
const version = pkg.version;
mustInclude('docs/openapi.yaml', `version: ${version}`, 'openapi version');
console.log(`[✓] openapi info.version = ${version}`);
NODE

echo "[✓] verify_openapi_sync"
