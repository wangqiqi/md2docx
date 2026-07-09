---
description: 【日常】执行 ACTIVE TASK — 写代码 · task-verify（默认做事入口）
---

加载 skill **run**：

```bash
./.cursor/bin/runner.sh gate-check
```

1. 按 `ACTIVE` 实现 → `task-verify` → commit
2. Sprint 全 ✅ → archive · CHANGELOG · **`/release`**

| 用这个 | 不是这个 |
|--------|----------|
| 已有 TASK · 继续开发 · 修 bug | 还没 Sprint/Goal → **`/plan`** |
| task-verify / verify 失败修代码 | 完全迷路 → **`/master`** |

其余 skill（test · api · delivery 等）由 Agent 按 plan **自动选用**，不必单独记 slash。
