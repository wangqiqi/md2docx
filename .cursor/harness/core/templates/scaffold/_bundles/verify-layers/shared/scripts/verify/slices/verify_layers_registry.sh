#!/usr/bin/env bash
# manifest.tsv ↔ slices/*.sh 双向登记（VERIFY_REGISTRY_STRICT=1 时未登记 slice 失败）
set -euo pipefail
source "$(dirname "$0")/../../lib/load.sh"
sc_cd_root

command -v node >/dev/null 2>&1 || { echo "SKIP: node 不可用（该 slice 需要 Node；非 Node 栈可忽略）"; exit 0; }

node <<'NODE'
const fs = require('fs');
const path = require('path');

const root = process.cwd();
const manifestPath = path.join(root, 'scripts/verify/manifest.tsv');
if (!fs.existsSync(manifestPath)) throw new Error('missing scripts/verify/manifest.tsv');

const manifestBash = new Set();
for (const line of fs.readFileSync(manifestPath, 'utf8').split('\n')) {
  if (!line.trim() || line.startsWith('#')) continue;
  const [tier, type, target] = line.split('\t');
  if (type === 'bash' && target) manifestBash.add(target.trim());
}

const slicesDir = path.join(root, 'scripts/verify/slices');
if (!fs.existsSync(slicesDir)) throw new Error('missing scripts/verify/slices');
const sliceFiles = fs
  .readdirSync(slicesDir)
  .filter((f) => f.endsWith('.sh'))
  .map((f) => `slices/${f}`);

const strict = process.env.VERIFY_REGISTRY_STRICT === '1';
const missing = [...manifestBash].filter((rel) => !fs.existsSync(path.join(root, 'scripts/verify', rel)));
if (missing.length) {
  throw new Error(`manifest bash targets missing files:\n${missing.join('\n')}`);
}

const unregistered = sliceFiles.filter((rel) => !manifestBash.has(rel));
if (unregistered.length) {
  const msg = `${unregistered.length} slice scripts not in manifest.tsv:\n${unregistered.join('\n')}`;
  if (strict) throw new Error(`VERIFY_REGISTRY_STRICT: ${msg}`);
  console.log(`[i] ${msg}`);
}

console.log(
  `[✓] manifest registry: bash=${manifestBash.size} slices=${sliceFiles.length}, ${unregistered.length} unclassified`,
);
NODE

sc_pass "verify_layers_registry"
