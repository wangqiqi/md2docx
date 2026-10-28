#!/usr/bin/env node
/**
 * 通用测例去重审计：配置驱动 discover + 扫描 manifest/slice 文本引用。
 * 用法: node scripts/verify/audit-dedup.mjs [--json] [--config path]
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const jsonOut = process.argv.includes('--json');
const configArg = process.argv.find((a) => a.startsWith('--config='))?.slice(9);

function loadConfig() {
  const candidates = [
    configArg,
    path.join(ROOT, 'scripts/verify/audit-dedup.config.json'),
    path.join(ROOT, 'scripts/verify/audit-dedup.config.example.json'),
  ].filter(Boolean);
  for (const p of candidates) {
    const full = path.isAbsolute(p) ? p : path.join(ROOT, p);
    if (fs.existsSync(full)) {
      return JSON.parse(fs.readFileSync(full, 'utf8'));
    }
  }
  throw new Error('missing audit-dedup config (copy audit-dedup.config.example.json)');
}

function walkFiles(dir, out, ignoreGlobs) {
  if (!fs.existsSync(dir)) return;
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    const rel = path.relative(ROOT, p);
    if (ignoreGlobs.some((g) => matchGlob(rel, g))) continue;
    if (ent.isDirectory()) walkFiles(p, out, ignoreGlobs);
    else out.push(rel);
  }
}

function matchGlob(rel, pattern) {
  const re = pattern
    .replace(/\*\*/g, '§')
    .replace(/\*/g, '[^/]*')
    .replace(/§/g, '.*');
  return new RegExp(`^${re}$`).test(rel);
}

function discoverAssets(suite) {
  const ignore = suite.ignoreGlobs || ['**/node_modules/**'];
  const files = [];
  for (const glob of suite.discoverGlobs || []) {
    const prefix = glob.split('**')[0].replace(/\/$/, '');
    const base = prefix ? path.join(ROOT, prefix) : ROOT;
    const pool = [];
    walkFiles(base, pool, ignore);
    for (const rel of pool) {
      if (matchGlob(rel, glob)) files.push(rel);
    }
  }
  return [...new Set(files)].sort();
}

function collectScanTexts(scanRoots) {
  const texts = [];
  for (const rel of scanRoots) {
    const full = path.join(ROOT, rel);
    if (!fs.existsSync(full)) continue;
    const stat = fs.statSync(full);
    if (stat.isFile()) {
      texts.push({ rel, body: fs.readFileSync(full, 'utf8') });
      continue;
    }
    const stack = [full];
    while (stack.length) {
      const dir = stack.pop();
      for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
        const p = path.join(dir, ent.name);
        if (ent.isDirectory()) stack.push(p);
        else if (/\.(sh|mjs|js|ts|json|txt|mdc|md|yaml|yml|toml)$/i.test(ent.name)) {
          texts.push({ rel: path.relative(ROOT, p), body: fs.readFileSync(p, 'utf8') });
        }
      }
    }
  }
  return texts;
}

function countRefs(assetPath, texts) {
  const refs = [];
  const needle = assetPath.replace(/\\/g, '/');
  for (const { rel, body } of texts) {
    if (body.includes(needle)) refs.push(rel);
  }
  return refs;
}

const cfg = loadConfig();
const policy = cfg.policy || {};
const maxRefs = policy.maxListedReferences ?? 1;
const texts = collectScanTexts(cfg.scanRoots || ['scripts/verify']);

const report = { suites: [], duplicates: [], unlisted: [] };

for (const suite of cfg.suites || []) {
  const assets = discoverAssets(suite);
  const suiteReport = { id: suite.id, assets: assets.length, listed: 0, duplicate: 0 };
  for (const asset of assets) {
    const refs = countRefs(asset, texts);
    const listed = refs.length;
    if (listed > 0) suiteReport.listed += 1;
    if (listed > maxRefs) {
      suiteReport.duplicate += 1;
      report.duplicates.push({ suite: suite.id, asset, refs, listed });
    }
    if (listed === 0 && policy.warnUnlisted) {
      report.unlisted.push({ suite: suite.id, asset });
    }
  }
  report.suites.push(suiteReport);
}

const fail = policy.failOnDuplicate && report.duplicates.length > 0;

if (jsonOut) {
  console.log(JSON.stringify({ ok: !fail, ...report }, null, 2));
} else {
  console.log('== verify audit-dedup ==');
  for (const s of report.suites) {
    console.log(`  ${s.id}: assets=${s.assets} listed=${s.listed} duplicate=${s.duplicate}`);
  }
  if (report.duplicates.length) {
    console.error('FAIL: duplicate test references (register once in manifest/bundles):');
    for (const d of report.duplicates) {
      console.error(`  ${d.asset} (${d.listed}x): ${d.refs.join(', ')}`);
    }
  }
  if (report.unlisted.length && policy.warnUnlisted) {
    console.log(`[i] unlisted assets: ${report.unlisted.length} (add to manifest or bundles)`);
  }
}

process.exit(fail ? 1 : 0);
