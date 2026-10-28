import { defineConfig, devices } from '@playwright/test'

/** Manual screenshot walkthrough — separate from product E2E smoke tests. */
export default defineConfig({
  testDir: './e2e',
  testMatch: /manual-walkthrough\.spec\.ts/,
  outputDir: 'test-results/manual-walkthrough',
  retries: 0,
  use: {
    baseURL: process.env.MANUAL_BASE_URL ?? 'http://localhost:5173',
    trace: 'off',
  },
  projects: [{ name: 'manual', use: { ...devices['Desktop Chrome'] } }],
})
