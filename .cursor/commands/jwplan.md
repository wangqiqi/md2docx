---
description: 启动 md2docx 开发规划（jwplan）— 拆 Sprint 写入 plan.md
---

加载 skill **jwplan-skill**（入口 command `/jwplan`）：

1. **第一步** 设 `<!-- PLANNING: true -->`
2. 读 plan / ROADMAP / `docs/` 规格 / 代码落点（**不写业务代码**）
3. 有疑 → **AskQuestion** 确认
4. 写 Sprint（验收列优先**可执行命令** · **执行顺序** · 闭合条件）
5. handoff：`PLANNING: false` · `SPRINT` · `PLAN_APPROVED` · `ACTIVE`/`NEXT` · `VERIFY` · `VERSION_LINE`
6. 跑 **`plan-check`** + **`gate-check`** 确认就绪
7. 变更记录；可选规划 commit
8. Summary → 建议 **`/jwrun`**

**禁止**：规划时改代码 · 无 `PLAN_APPROVED` handoff · 任务只写聊天。
