---
name: plan
description: 规划（/plan）：需求→先总后分→Sprint→plan.md→/run。说「规划」「拆任务」时用。禁止写业务代码。≠ IDE Plan 模式。
disable-model-invocation: true
---

# plan

闸门见 `rules/workflow.mdc`。配置：`config/workflow.json`

**详文**：`reference/phases.md`（阶段 1/2/3 · 头身一致）· `reference/followup-facade.md`（Follow-up · README 门面）· `reference/prioritization.md`（RICE/ICE/Kano · backlog 排序）· `reference/sdd/source-map.md`（Spec-Driven Development）· `reference/autonomy-chain.md`（Sprint 连跑 · hooks 触点）· `reference/standalone-map.md`（母版独立 · 引用纪律）

配置坐标：`config/workflow.json` → `sdd.specs_dir` · `sdd.principles_file`

## 规模门禁 · plan≥5

| 条件 | 动作 |
|------|------|
| 预估 / 已列 **todolist 或 TASK 超过 5 条** | **先**写入 / 更新 `.cursorGrowth/plan.md`（Goal · Done when · TASK 表），**等用户确认**后再 `/run` 编码 |
| 大改动、跨模块、不确定选型 | 同上；必要时先 `SPIKE-*` |
| ≤5 且范围清晰的小修 | 可直述执行；仍建议 gate-check |

禁止：脑内排 6+ 步却只在聊天里列 checklist、不落 plan。与用户规则「>5 todolist → plan.md」对齐；可观测落点为本节 + `workflow.mdc`。

## 必读

`.cursorGrowth/plan.md` 元数据 · **未完成** Sprint/TASK · `.cursorGrowth/archive/` · `learn/plan-conventions.md` · grep 落点（**不写代码**）

**`.cursorGrowth/` 不纳入 git**：`plan.md` · `archive/` · `learn/` · `rules/local` 均在此；安装时由 `templates/plan.md` 复制到 `.cursorGrowth/plan.md`。

空仓库 / 用户要「新建项目」：在 `PLANNING:true` 用 **AskQuestion** 确认栈 → 预览 `scaffold.sh apply --dry-run` → 用户确认后 apply 或写入 `TASK-001`（见 **scaffold** skill）。**不写业务代码**直至用户确认脚手架范围。

## plan.md 正文卫生（未完成优先）

**目标**：`plan.md` 是**执行面板**，不是历史档案。团队细则 → `.cursorGrowth/learn/plan-conventions.md`。

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
| 已闭合 Sprint 全文（Done when · TASK ✅） | `.cursorGrowth/archive/` 一篇摘要 |
| ROADMAP 全表（含大量 `done` 行） | 运行时 `archive/` · 项目 `docs/ROADMAP.md` |
| **历史 Sprint** 长链接列表 | `archive/` 目录即可 |
| 设计拍板长文 · 多段 archive 互链 | `learn/` · `docs/` |

Sprint **全部 TASK ✅** 后：**从 plan 删除整个 Active 区块**（不只改标题）；细节只留 archive + CHANGELOG。

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

| 层 | 载体 | 作用 |
|----|------|------|
| **总** | Sprint **Goal** · **Done when** · 候选表对齐 | 主题边界、全局验收 |
| **分** | 扁平 `TASK-*` 表 · **执行顺序** | `/run`：默认 `AUTONOMOUS:true` **Sprint 连跑**；`false` 时一次一个 `ACTIVE` |

1. **阶段 1** — Goal / Done when / Out of scope（**不写** TASK 表）→ 详 `reference/phases.md`
2. **Follow-up / 门面** — 见 `reference/followup-facade.md`
3. **阶段 2** — 拆 TASK + 执行顺序 → 详 `reference/phases.md`
4. **阶段 3 · handoff** — `PLANNING:false` · `PLAN_APPROVED` · `ACTIVE`/`NEXT` · 默认 `AUTONOMOUS:true` → `plan-check` && `gate-check` → 告知用户 **只说一次 `/run`**

大改动 / 跨模块：读 `rules/execution/vibe.mdc` · `rules/feedback/evolution.mdc`。

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

## Spec-Driven Development（SDD · 吸收自 github/spec-kit）

**用这个**：新功能从 0→1、要先写清 what/why 再拆 TASK。**不是那个**：常规 Sprint 增量（默认仍走下方「先总后分」）；不记 `/speckit.*` 命令。

### 模式分流（`PLANNING:true` · AskQuestion ≤4）

| 选项 id | 用户看到 | 流程 |
|---------|----------|------|
| `sprint` | 继续 / 常规 Sprint 增量 | 现有阶段 1→2→3（默认） |
| `greenfield` | 新功能 · 从规格开始 | principles → spec → clarify → tech plan → tasks → 导入 TASK 表 |
| `brownfield` | 存量功能增强 | 读代码 + 增量 `spec.md`；可跳过新目录 |
| `doc` | 写文档 / PRD（非功能 spec） | §协作文档（doc-coauthoring） |

工具不可用时：同表正文编号（**master** AskQuestion 约定）。

### Greenfield 工件（目标项目）

路径默认读 `workflow.json` → `sdd`（见 `reference/sdd/source-map.md`）：

```
docs/principles.md          # 可选 · principles-template
docs/specs/001-<slug>/
  spec.md                   # spec-template · what/why
  clarifications.md         # clarify 产出（或 spec 内一节）
  plan.md                   # tech-plan-template · how
  tasks.md                  # tasks-template → 阶段 2 导入 plan TASK
```

**阶段 2 导入**：从 `tasks.md` 提取可验收项 → `.cursorGrowth/plan.md` 扁平 `TASK-*`；`[P]` 表可并行，写入执行顺序。

### 模板

| 文件 | 用途 |
|------|------|
| `reference/sdd/spec-template.md` | 功能 spec |
| `reference/sdd/tech-plan-template.md` | 技术计划 |
| `reference/sdd/tasks-template.md` | 任务分解 |
| `reference/sdd/principles-template.md` | 项目原则（≠ constitution.mdc） |

安装副本：`.cursor/templates/sdd/`（与 reference 同步）。

## 任务 ID

| 前缀 | 用途 |
|------|------|
| `TASK-*` | 实现任务（默认） |
| `SPIKE-` / `REV-` / `DOC-` | 调研 / 回顾 / 文档；`next-task` 自动推进时跳过，**仍需** `PLAN_APPROVED` 才能 `/run` 编码 |

配置：`workflow.json` → `task_id.prefixes_skip` · `prefixes_autonomous`

## 协作文档（DOC-* · 吸收自 anthropics/skills/doc-coauthoring）

用户说「写文档 / PRD / RFC / 设计 doc / 提案」→ **AskQuestion**（≤4 项，勿填空）：

| 选项 | 动作 |
|------|------|
| **结构化协作** | 三阶段工作流（推荐 substantial doc） |
| **自由撰写** | 直述，不走阶段 |
| **SPIKE 调研** | `SPIKE-*` 只读 |
| **同步现有 doc** | `DOC-*` 对齐 `rules/execution/docs.mdc` |
| **可发布操作手册** | **user-manual** `/manual` · Manual Contract · 配图 regen |
| **可发布测试报告** | **test-report** `/report` · Report Contract · verify 后汇总 |

### 三阶段（结构化协作）

1. **Context** — 用户 dump 背景；Agent 5–10 个澄清问题（可编号简答）
2. **Refine** — 按节：头脑风暴 → 用户勾选 → 起草 → 迭代（`str_replace` 局部改，勿整篇重打）
3. **Reader Testing** — 用 **review** agent 或新会话「仅持文档」回答 5–10 个读者问题；失败 → 回阶段 2

Sprint 表用 `DOC-*`；验收：Reader Testing 通过或用户明确跳过。

### 需求体检与 PRD 补漏（吸收自 SpaceZephyr/pm-skills）

结构化协作或自由撰写 PRD / 功能说明时，在 Context 之前或 Refine 之后套用 **`reference/doc-prd-enrich.md`**：

1. **需求体检** — 来源 · 用户价值 · 成功指标（见该文件信号表）
2. **自动补漏** — 异常/埋点/非功能/对接（补入对应节，不堆附录）
3. **待确认项** — 交付时单独汇总；每条带默认建议与影响范围

信息严重不足 → 需求梳理兜底，不硬写完整 PRD。预审 → **review** §文档预审。

### Backlog 优先级（吸收自 pm-skills）

候选 Sprint · backlog · TASK 的 P0/P1 争议 → **`reference/prioritization.md`**（RICE · ICE · Kano · MoSCoW）。
