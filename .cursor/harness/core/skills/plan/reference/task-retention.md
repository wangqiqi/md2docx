# 任务保留纪律（plan · ROADMAP）

> Agent 与维护者共用 SSOT。违反下列条目的「精简 plan / 整理 ROADMAP」视为 **steering 事故**，须恢复任务行或经用户书面确认后归档。

## `.growing/plan.md`

| 必须 | 禁止 |
|------|------|
| 保留 Active Sprint 内所有 **未闭合** TASK（`⬜` · `🔧` · `⚠️`）直至 ✅ 或用户取消 | 为「简洁」删除、合并覆盖、隐藏未完成任务行 |
| 保留 **下一 Sprint 候选** 表，直到立项或用户明确废弃 | 用一两行摘要替换整张 TASK 表 |
| 更新进度时只改 **Status** · 验收说明 · `ACTIVE`/`NEXT` 元数据 | 因「代码已 push / CI 已绿」就删掉仍开放的 TASK |
| Sprint **全部 TASK ✅** 且用户确认收尾后，**整段删除** Active 正文 | 未归档就删 Active；只改标题冒充闭合 |
| 仍有 `⬜`/`🔧` 时 **禁止**清空 plan 或覆盖为新 Sprint | 静默开新 Sprint 覆盖旧 ID |

**用这个**：`plan.md` = 执行面板（未完成优先）。**不是那个**：聊天里 checklist 当唯一真源。

细则 → **plan** skill `plan.md 正文卫生` · 团队 `learn/plan-conventions.md`。

## `docs/ROADMAP.md`

| 区块 | 纪律 |
|------|------|
| **进行中** · **计划中（候选）** | **不得随意删除**未交付行；只可改状态列、补充依赖、或经用户确认后标记「废弃」 |
| **已完成** | 已交付项 **迁出** 进行中/计划（可进本表近 N 项或 `.growing/archive/`）；可定期 **清理** 过旧已完成行，**不是**删未做项 |
| 与 plan 分工 | ROADMAP = 长期 / 多 Sprint 主题；`plan.md` = 当前 Sprint TASK 与执行顺序 |

模板 → `templates/project-docs/ROADMAP.md` · 号位例外 → **project-docs** rule。

## 验收（人工 / Agent 自检）

- 改 `plan.md` 前：grep `⬜|🔧|⚠️`，diff 不得减少未完成任务 **行数**（除非改为 ✅ 或用户确认取消）。
- 改 `ROADMAP.md` 前：`进行中`/`计划中` 表行删除须有对应 archive 或用户消息。
