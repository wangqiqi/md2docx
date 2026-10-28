#!/usr/bin/env node
/**
 * 按 git 变更执行最小 verify（verify-layers scaffold）。
 * VERIFY_CHANGED_DRY=1 · VERIFY_CHANGED_BASE=ref · VERIFY_CHANGED_MIN_LAYER=l2-core
 */
import { spawnSync } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';
import {
  gitChangedFiles,
  planForChangedFiles,
  buildChangedSteps,
  loadMap,
} from './lib/changed-plan.mjs';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const dry = process.env.VERIFY_CHANGED_DRY === '1' || process.argv.includes('--dry-run');

const base = process.env.VERIFY_CHANGED_BASE || process.argv.find((a) => a.startsWith('--base='))?.slice(7);
const map = loadMap();
const files = gitChangedFiles(base, ROOT);
const plan = planForChangedFiles(files, map);
const steps = buildChangedSteps(plan);

console.log('== verify:changed ==');
console.log(`files: ${plan.files} · unmatched: ${plan.unmatched} · layer: ${plan.layer}`);
if (files.length) {
  for (const f of files.slice(0, 20)) console.log(`  - ${f}`);
  if (files.length > 20) console.log(`  ... +${files.length - 20} more`);
}

for (const [cmd, args] of steps) {
  const line = `${cmd} ${args.join(' ')}`;
  console.log(dry ? `[dry-run] ${line}` : `>> ${line}`);
  if (!dry) {
    const r = spawnSync(cmd, args, { cwd: ROOT, stdio: 'inherit', shell: false });
    if (r.status !== 0) process.exit(r.status ?? 1);
  }
}

if (dry) {
  console.log('[dry-run] verify:changed plan OK');
} else {
  console.log('[verify] verify:changed OK');
}
