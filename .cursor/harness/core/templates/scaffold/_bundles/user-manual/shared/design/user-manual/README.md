# User manual · screenshot regen

Playwright walkthrough outputs PNGs for `docs/user-guide.md`.

## First-time setup (web stacks)

```bash
npm i -D @playwright/test
npx playwright install chromium
```

Add to `package.json` scripts (if not present):

```json
"test:e2e:manual": "playwright test -c playwright.manual.config.ts"
```

## Regenerate (after `verify` green)

```bash
export MANUAL_WALKTHROUGH_ENABLED=1
npm run test:e2e:manual
bash scripts/docs/sync_manual_screenshots.sh
bash scripts/verify/docs/verify_doc_manual.sh
```

Contract: `config/manual.yaml` · SOP: **user-manual** `/manual` skill.
