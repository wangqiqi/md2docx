import { test, expect } from '@playwright/test'
import { shot } from './helpers/manualWalkthrough'

const enabled = process.env.MANUAL_WALKTHROUGH_ENABLED === '1'

test.describe('manual walkthrough · screenshots', () => {
  test.skip(!enabled, 'Set MANUAL_WALKTHROUGH_ENABLED=1 after UI anchors exist')

  test('primary · home', async ({ page }) => {
    const base = process.env.MANUAL_BASE_URL ?? 'http://localhost:5173'
    await page.goto(base)
    const root = page.getByTestId('app-root')
    await expect(root).toBeVisible({ timeout: 15_000 })
    await shot(page, '01_home', [root])
  })
})
