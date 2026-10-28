---
name: plan
description: 规划（/plan）：需求→先总后分→Sprint→plan.md→/run。说「规划」「拆任务」时用。禁止写业务代码。≠ IDE Plan 模式。
disable-model-invocation: true
---

# plan

闸门见 `rules/workflow.mdc`。配置：`config/workflow.json`

**详文**：`reference/phases.md`（阶段 1/2/3 · 头身一致）· `reference/sprint-goal-gate.md`（**Sprint Goal 合格性** · 禁止仪式型 Sprint）· `reference/task-retention.md`（**未完成任务不得删** · plan · ROADMAP）· `reference/followup-facade.md`（Follow-up · README 门面）· `reference/prioritization.md`（RICE/ICE/Kano · backlog 排序）· `reference/sdd/source-map.md`（Spec-Driven Development）· `reference/autonomy-chain.md`（Sprint 连跑 · hooks 触点）· `reference/standalone-map.md`（母版独立 · 引用纪律）

配置坐标：`config/workflow.json` → `sdd.specs_dir` · `sdd.principles_file`

## 规模门禁 · plan≥5

| 条件 | 动作 |
|------|------|
| 预估 / 已列 **todolist 或 TASK 超过 5 条** | **先**写入 / 更新 `.growing/plan.md`（Goal · Done when · TASK 表），**等用户确认**后再 `/run` 编码 |
| 大改动、跨模块、不确定选型 | 同上；必要时先 `SPIKE-*` |
| ≤5 且范围清晰的小修 | 可直述执行；仍建议 gate-check |

禁止：脑内排 6+ 步却只在聊天里列 checklist、不落 plan。与用户规则「>5 todolist → plan.md」对齐；可观测落点为本节 + `workflow.mdc`。

## Sprint 立项门禁 · Goal 合格性

Sprint **Goal 必须是能力/模块交付**；打 tag · merge · 归档等**出口动作不得单独立项**。
判定表与反例 → [reference/sprint-goal-gate.md](reference/sprint-goal-gate.md)（`plan-check` 会 WARN 仪式型 Goal）。

## 必读

`.growing/plan.md` 元数据 · **未完成** Sprint/TASK · `.growing/archive/` · `learn/plan-conventions.md` · grep 落点（**不写代码**）

**`.growing/` 不纳入 git**：`plan.md` · `archive/` · `learn/` · `rules/local` 均在此；安装时由 `templates/plan.md` 复制到 `.growing/plan.md`。

空仓库 / 用户要「新建项目」：在 `PLANNING:true` 用 **AskQuestion** 确认栈 → 预览 `scaffold.sh apply --dry-run` → 用户确认后 apply 或写入 `TASK-001`（见 **scaffold** skill）。**不写业务代码**直至用户确认脚手架范围。

## plan.md 正文卫生（未完成优先）

**目标**：`plan.md` 是**执行面板**，不是历史档案。团队细则 → `.growing/learn/plan-conventions.md`。

### 保留在 plan.md

| 区块 | 说明 |
|------|------|
| **HTML 注释** | `PLANNING` · `SPRINT` · `ACTIVE` · `NEXT` · `VERIFY` 等（`runner.sh` 解析） |
| **执行原则** | 一两行指针（archive/CHANGELOG 在哪），**勿**堆归档链接表 |
| **Active sprint** | 当前 Sprint：`Goal` · `Done when` · `Out of scope` · TASK 表（`⬜`/`🔧`/`⚠️`）· **执行顺序** |
| **下一 Sprint 候选** | 未立项 Sprint 简表（Goal · 依赖）；**保留在 plan** |

### 禁止堆进 plan.md

| 不放 | 放哪里 |
|------|--------|
| 已闭合 Sprint 全文（Done when · TASK ✅） | `.growing/archive/` 一篇摘要 |
| ROADMAP 全表（含大量 `done` 行） | 运行时 `archive/` · 项目 `docs/ROADMAP.md` |
| **历史 Sprint** 长链接列表 | `archive/` 目录即可 |
| 设计拍板长文 · 多段 archive 互链 | `learn/` · `docs/` |

Sprint **全部 TASK ✅** 后：**从 plan 删除整个 Active 区块**（不只改标题）；细节只留 archive + CHANGELOG。

### 任务保留纪律（Agent 硬约束）

完整表 → [reference/task-retention.md](reference/task-retention.md)。

| 必须 | 禁止 |
|------|------|
| 保留所有 `⬜`/`🔧`/`⚠️` TASK 直至 ✅ 或用户明确取消 | **随意删除**未完成任务行、用摘要替换整张 TASK 表 |
| 更新进度只改 Status / 元数据，不丢 ID | 因「已 push / 本地已绿」就从 plan 移除仍开放 TASK |
| `docs/ROADMAP.md` 的 **进行中 / 计划中** 行同上 | 删 ROADMAP 未做项；只允许 **已完成** 迁出或清理旧行 |

### 新开 / 续开 Sprint（累加，不覆盖）

| 场景 | 动作 |
|------|------|
| **仍有** `⬜`/`🔧` TASK 或 Active Sprint | **禁止**清空 plan；先收尾或继续在现有 Sprint 排期 |
| **新开** Sprint（上一 Sprint 已归档并删正文） | 从候选表**删掉已立项行**；新增 `## Active sprint · …`；`SPRINT_STATUS: active` |
| **候选表有剩余** | 未选中行**保留**；与用户确认下一项，**累加**不重复造 ID |
| **全部完成** | plan 无 Active · 仅候选表 + 可选阻塞一行；`SPRINT_STATUS: closed` |

### 推荐结构

有 Active：**Active 置顶** → 分隔线 → **下一 Sprint 候选**。无 Active：一行空状态说明 → 候选表。勿加「历史 Sprint」列表。

## 先总后分（摘要）

冻结 **L0 Goal / Done when / Out of scope** → 划 L1 Theme → 同层 MECE 拆 TASK（`Target` · `Owns` · 主验收不跨 Theme）→ 每 TASK 可执行验收 + 落点。
完整阶段与产物 → [reference/phases.md](reference/phases.md)。

## Sprint 连跑（AUTONOMOUS）

**用这个**：Sprint 已批准 · 用户授权自治 · 一次 `/run` 连跑 P0 TASK。**不是那个**：每 TASK 等用户再 `/run` · 无 `PLAN_APPROVED` 编码。

| 项 | 约定 |
|----|------|
| 默认 | `workflow.json` → `autonomous.default: true`；plan 模板 `<!-- AUTONOMOUS: true -->` |
| handoff 话术 | 「批准完成；请 **`/run` 一次**，我会连跑 TASK，仅决策点打断」 |
| 决策打断 | `autonomy.interrupt_on` · Sprint 表 **决策打断清单** · `reference/autonomy-chain.md` |
| 非决策 | TASK 切换 · commit · CHANGELOG · README · closeout Medium/Low — **勿停跑问人** |
| hooks | `run-stop` 发 followup；Agent **同会话**续下一 `ACTIVE` |

用户显式设 `AUTONOMOUS: false` → 恢复「每 TASK 手动 `/run`」。

## Spec-Driven Development（SDD · 可选）

大特性走 spec → plan → tasks 三件套；**模式分流 · 工件 · 模板** →
[reference/sdd/](reference/sdd/)（`spec-template.md` · `tech-plan-template.md` · `tasks-template.md` · README）· 目录键 `sdd.specs_dir`。
仅当需求有歧义或跨多 Sprint 时才启用；小改不要走 SDD。

## 任务 ID

| 前缀 | 用途 |
|------|------|
| `TASK-*` | 实现任务（默认） |
| `SPIKE-` / `REV-` / `DOC-` | 调研 / 回顾 / 文档；`next-task` 自动推进时跳过，**仍需** `PLAN_APPROVED` 才能 `/run` 编码 |

配置：`workflow.json` → `task_id.prefixes_skip` · `prefixes_autonomous`

## 协作文档（DOC-*）

PRD/RFC/提案类产出走结构化协作（先共情 → 收敛 → 固化），并做需求体检与优先级排序 →
[reference/doc-prd-enrich.md](reference/doc-prd-enrich.md) · [reference/prioritization.md](reference/prioritization.md)。
大改版立 `DOC-*` 任务，验收写可执行命令或明确 `manual:`。
