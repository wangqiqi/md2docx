---
description: 【高级】UX 体验分流 → ia / delivery / plan（Agent 可自动选用）
---

加载 skill **ux**：

1. 读 `rules/execution/ux.mdc` · **Garrett 分层**（IA ⊂ UX）
2. **AskQuestion ≤4 项** 分流：
   - 结构 / 导航 / 角色入口 → **ia**
   - 上线验收 / 视觉 / i18n → **delivery**
   - 范围 / Sprint → **plan**
   - 方法论学习 → **study**
3. **默认只读规划**；大改须 `/plan` + `PLAN_APPROVED`

日常 **`/run`** 即可；仅体验问题复杂或类型不明时用 **`/ux`**。
