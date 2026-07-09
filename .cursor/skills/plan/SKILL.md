---
name: plan
description: 规划（/plan）：需求→先总后分→Sprint→plan.md→/run。说「规划」「拆任务」时用。禁止写业务代码。≠ IDE Plan 模式。
disable-model-invocation: true
---

# plan

闸门见 `rules/workflow.mdc`。配置：`config/workflow.json`

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
| ROADMAP 全表（含大量 `done` 行） | `archive/` · `CHANGELOG.md` · 项目 `docs/ROADMAP.md` |
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

## 规划粒度 · 先总后分

**禁止**在 `PLANNING:true` 阶段直接列一长串 `TASK-*` 而不先对齐全局。两层结构已够用，**不必**引入 Epic/Story 嵌套 ID 或 A1/A2 子编号：

| 层 | 载体 | 作用 |
|----|------|------|
| **总** | Sprint **Goal** · **Done when** · 候选表对齐 | 主题边界、全局验收 |
| **分** | 扁平 `TASK-*` 表 · **执行顺序** | `/run` 一次一个 `ACTIVE`；`next-task` 解析顺序 |

大改动 / 跨模块 / 前后端并行：额外读 `rules/execution/vibe.mdc`（API 契约、层序）· `rules/feedback/evolution.mdc`（小步可回滚）。

### 阶段 1 · 总（先不写 TASK 表）

在 `PLANNING:true` 完成后再进入阶段 2。用 **AskQuestion** 与用户确认：

- [ ] **Goal** — 本 Sprint 要交付什么（一句话）
- [ ] **Done when** — 怎样算 Sprint 完成（可执行 verify 命令 + P0 全 ✅）
- [ ] **与候选表对齐** — 从 plan「下一 Sprint」立项则删对应候选行；新主题直接写 Active
- [ ] **Scope / 非目标** — 本轮明确不做什么（防 scope creep）
- [ ] **风险与依赖** — 跨模块顺序、需先定的契约或接口
- [ ] **SPIKE 门禁** — 选型/方案/范围仍不确定 → 先列 `SPIKE-*`，结论归档后再拆 `TASK-*`（见 **scaffold** · **spike** agent）
- [ ] **Follow-up 立项闸门** — 见 §Follow-up（同症状重复 patch 时强制）
- [ ] **PRD 输入（可选）** — 已有 ChatPRD 规格时：读 **implement-from-prd** / **write-prd** 提炼 Goal；交付前 **check-prd-alignment**（ChatPRD 插件 skills）
- [ ] **对外门面** — 本 Sprint 是否新增/改名 skill、command、agent、hooks 或安装路径？**是** → Done when **必须**含 `bash .cursor/bin/cursor-coherence.sh`（README 与磁盘一致）；**否** → 可省略
- [ ] **交付验收（可选）** — UI/功能 Sprint → Done when 可加 **交付走查无 Blocker**（Agent 走 **delivery** skill）；纯内部可省略

**Done when 勾选项（自然语言，不必记 skill 名）** — 与用户确认后写入 Sprint 头部：

| 勾选意图 | 写入 Done when 示例 |
|----------|---------------------|
| 验收脚本绿 | `bash <项目 verify>` 或 plan `VERIFY` 命令 |
| 上线前走查 | 交付走查无 Blocker（UI/功能 Sprint） |
| 合并/PR | Sprint 末 `/release` §分支 |
| 打版本 tag | `/release` §打版 或 **ship** 自治发版 |
| 母版门面 | `bash .cursor/bin/cursor-coherence.sh` |

阶段 1 产出写入 Sprint 区块头部（**Goal** · **Done when** · 可选 **Out of scope**），**此时仍不写** TASK 表。

### Follow-up 立项闸门

候选 Sprint 名含 `follow-up` / `hotfix` / 或与 CHANGELOG/learn **同症状簇** 已 ≥2 次 patch 时：

| 条件 | 必须 |
|------|------|
| 同用户可见症状 **≥2** 个已发布 patch | 先 **`SPIKE-*`**（模板 `.cursor/templates/spike-regression-cluster.md`）或 **合并进原 Sprint**，禁止只加第三个 symptomatic patch |
| 仅 UX 微调、根因已闭环 | **`/delivery`** 走查确认缺口后再立项；plan 写 **与上版差异** |
| `workflow.followup_gate.require_spike` = true | 无 `SPIKE-*` 归档则 **AskQuestion** 是否豁免 |

立项表须含：**根因类型**（对照 `async-progress` · `long-running-ui` · `modal-layering` · `error-context` · `single-detector`）· **为何本次一次性修完** · **回归测矩阵**（L1/L2）。

### 对外门面 · README（禁止事后补 DOC Sprint）

根目录 `README.md` 是 Super Cursor **产品首页**。凡 Sprint 改变用户可见能力，**须在同一 Sprint 内**同步 README，**禁止**「功能 Sprint ✅ → 另开 SPRINT 专补 README」。

| 变更类型 | 规划要求 |
|----------|----------|
| 新增/改名 skill · agent · `/` 指令 | Done when 含 `cursor-coherence.sh`；最后一项 P0 或各 TASK 的 Target 含 `README.md` |
| 仅内部 refactor · archive · 无对外行为 | README 可不碰 |
| 用户抱怨「文档滞后」 | 回流阶段 1：把 README 写进 **Done when**，勿只加 `DOC-*` |

阶段 2 拆 TASK 时：

- **推荐**：末位 P0 · Target `README.md` · Acceptance `bash .cursor/bin/cursor-coherence.sh`（与功能 TASK **同 Sprint**）
- **或**：每个改 `.cursor/skills/` · `agents/` · `master/` 的 TASK，Target 列 **同时** 写 `README.md`（同 commit 增量同步）
- **勿** 为补 README 单独开 Sprint，除非 Sprint Goal 本身就是文档重写

### 阶段 2 · 分（再写 TASK 表）

全局对齐后再拆任务。每条 `TASK-*` 宜满足：

- **一个可执行验收命令**（`task-verify` 能判绿/红；见 `rules/feedback/verify.mdc`）
- **一次 commit 能讲完**（一逻辑一 commit · `rules/execution/commit.mdc`）
- **Target 列框住落点**（防 drive-by；`/run` 审计对照）
- **依赖显式出现在执行顺序**（B 依赖 A → 顺序里 A 在前）

**全栈 / 跨持久化+API+UI** Sprint：按 `rules/execution/vibe.mdc` §垂直切片拆 TASK；每条验收对齐 `rules/feedback/verify.mdc`（L1 默认 · L3 进 Done when 可选）。

粒度自检：

| 过粗 | 合适 | 过细 |
|------|------|------|
| 一条 TASK 跨多个 Theme / 无单一验收 | 一 TASK ≈ 一可验证增量 | 改一行文案、单文件 typo 单独成 TASK |
| Sprint 内 >15 条且难排顺序 | Task 列可用 `[主题]` 前缀分组，**ID 仍扁平** | 每个子步骤都占一个 ID |

Sprint 表 + **执行顺序** 行：`TASK-001` → `TASK-002` → …

### Plan 头身一致（通用）

HTML 注释（`ACTIVE` / `LAST_DONE` / `SPRINT_STATUS`）与正文须同步：

| 阶段 | 要求 |
|------|------|
| **规划（/plan）** | 团队可选基线 → `learn/plan-conventions.md`；**勿**在 plan 堆已完成 Sprint |
| **执行（/run）** | 单任务 ✅ 时同步 TASK 表 **✅**；**不得**只改 `LAST_DONE` |
| **Sprint 收尾** | archive 摘要 + **从 plan 删除已闭合 Active 区块**（见 **run** skill）；候选表保留 |

`runner.sh plan-check`：闭合后 plan 内**不应**仍有「已闭合」Sprint 正文或历史链接表。

### 阶段 3 · handoff

用户确认后设 `PLANNING:false` · `PLAN_APPROVED` · `ACTIVE`/`NEXT`：

```markdown
<!-- PLANNING: false -->
<!-- PLAN_APPROVED: YYYY-MM-DD -->
<!-- SPRINT_STATUS: active -->
<!-- ACTIVE: TASK-001 -->
<!-- NEXT: TASK-001 -->
```

```bash
./.cursor/bin/runner.sh plan-check && ./.cursor/bin/runner.sh gate-check
```

完成后建议 `/run`

## 任务 ID

| 前缀 | 用途 |
|------|------|
| `TASK-*` | 实现任务（默认） |
| `SPIKE-` / `REV-` / `DOC-` | 调研 / 回顾 / 文档；`next-task` 自动推进时跳过，**仍需** `PLAN_APPROVED` 才能 `/run` 编码 |

配置：`workflow.json` → `task_id.prefixes_skip` · `prefixes_autonomous`
