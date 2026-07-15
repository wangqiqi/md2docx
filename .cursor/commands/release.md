---
description: 【生命周期】Sprint 出口 — merge/PR/打 tag（UI Sprint 建议先 /delivery）
---

加载 skill **release**：

**用这个**：人主导 Sprint 出口（问 merge/PR/打 tag、走 AskQuestion）。**不是那个**：委派 Agent 按清单自治打版 → **ship** agent（无 `/ship` slash）。

1. **§分支收尾** — verify 绿后 4 选 1（merge · PR · 保留 · 丢弃）
2. **§打版** — CHANGELOG · semver · tag（自治 → **ship** agent）

**顺序（UI/功能 Sprint）**：`/run` 全 ✅ → 可选 **`/delivery`** 走查 → **`/release`**  
日常 commit 纪律见 **git** skill；**ship** 是 agent 不是 slash。打版步骤 SSOT 只在 **release** skill **§打版**，ship 只执行不另立流程。
