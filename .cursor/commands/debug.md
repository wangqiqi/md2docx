---
description: 【高级】系统调试循环 — 复现→根因→验证（Agent 可自动选用）
---

加载 skill **debug**：

1. 读 `rules/execution/bugfix.mdc` · **铁律**：无根因不提修复
2. 按 skill 五步法：复现 → 假设 → 隔离 → 验证 → 记录
3. 已知实现任务 → **`/run`**；范围不清 → **`/plan`**

日常小修可直接 **`/run`** 或描述复现步骤；反复失败或根因不明时用 **`/debug`**。
