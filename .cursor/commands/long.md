---
description: 【生命周期】Epic 长程 — 拆 Sprint → 每 Sprint plan+run → checkpoint
---

加载 skill **long**：

1. **Epic 立项** — 拆 ≤5 个 Sprint，写入 `.cursorGrowth/long-state.json`，确认 Goal
2. **Sprint 循环** — 对每个 Sprint：走 **plan** handoff → **`/run` 一次** 连跑 TASK
3. **Checkpoint** — Sprint 收尾：verify · archive · 更新 long-state；下一 Sprint 或 `/long resume`

单 Sprint 内自治见 **plan** `AUTONOMOUS:true` · 层级与节奏见 `skills/long/reference/`。

`gate-check` ≠ OK 不写业务代码。
