import fs from 'node:fs'
import path from 'node:path'
import { type Locator, type Page } from '@playwright/test'

const HIGHLIGHT_LAYER_ID = 'manual-highlight-layer'

export const MANUAL_OUT =
  process.env.MANUAL_INTERMEDIATE_DIR ??
  path.join(process.cwd(), 'test-results', 'manual-walkthrough')

type ClipRect = { x: number; y: number; width: number; height: number }

async function drawHighlights(page: Page, locators: Locator[]): Promise<ClipRect[]> {
  const boxes: ClipRect[] = []
  for (const loc of locators) {
    await loc.scrollIntoViewIfNeeded()
    const box = await loc.boundingBox()
    if (box && box.width > 2 && box.height > 2) boxes.push(box)
  }
  await page.evaluate(
    ({ layerId, rects }) => {
      document.getElementById(layerId)?.remove()
      const layer = document.createElement('div')
      layer.id = layerId
      layer.style.cssText =
        'position:fixed;inset:0;pointer-events:none;z-index:2147483646'
      for (const r of rects) {
        const box = document.createElement('div')
        box.style.cssText = [
          'position:absolute',
          `left:${r.x}px`,
          `top:${r.y}px`,
          `width:${r.width}px`,
          `height:${r.height}px`,
          'border:3px solid #e53935',
          'border-radius:4px',
        ].join(';')
        layer.appendChild(box)
      }
      document.body.appendChild(layer)
    },
    { layerId: HIGHLIGHT_LAYER_ID, rects: boxes },
  )
  return boxes
}

/** Save PNG with optional red-box highlights. */
export async function shot(page: Page, name: string, highlights: Locator[] = []) {
  fs.mkdirSync(MANUAL_OUT, { recursive: true })
  if (highlights.length) await drawHighlights(page, highlights)
  const out = path.join(MANUAL_OUT, `${name}.png`)
  await page.screenshot({ path: out })
  await page.evaluate((id) => document.getElementById(id)?.remove(), HIGHLIGHT_LAYER_ID)
}
