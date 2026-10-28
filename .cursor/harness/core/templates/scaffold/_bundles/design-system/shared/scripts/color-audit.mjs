#!/usr/bin/env node
/**
 * Minimal contrast audit for design-tokens.json (scaffold bundle).
 * Extend with WCAG pairs as the product grows.
 */
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const tokensPath = path.join(root, 'design-tokens.json');
if (!fs.existsSync(tokensPath)) {
  console.error('FAIL: missing shared/design-tokens.json');
  process.exit(1);
}

const tokens = JSON.parse(fs.readFileSync(tokensPath, 'utf8'));
const required = ['color', 'space', 'radius', 'zIndex'];
for (const key of required) {
  if (!tokens[key]) {
    console.error(`FAIL: design-tokens.json missing "${key}"`);
    process.exit(1);
  }
}

const z = tokens.zIndex;
if (!(z.content < z.sticky && z.sticky < z.popover && z.popover < z.overlay)) {
  console.error('FAIL: zIndex must be content < sticky < popover < overlay');
  process.exit(1);
}

console.log('[✓] color-audit: design-tokens.json structure OK');
