---
description: 【高级】上线前 7 维验收（发版前可选 · 不替代 task-verify）
---

加载 skill **delivery**：

1. 读 `learn/acceptance.md`（若有）· `plan.md` Done when
2. 按 **7 维清单**走查（视觉 · i18n · 文档 · API · 组件 · 维护 · 生产就绪）
3. **§5 导航与 IA**：对照 `rules/execution/ia.mdc` R1–R4 · `docs/design/*-ia*`
4. 输出 Blocker/High/Medium/Low；Blocker 须先报告再 **`/release`**

结构规划 → **ia**；体验类型不明 → **`/ux`** 先分流。Agent 也可按 plan 自动选用，**不必死记**。
