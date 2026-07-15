# plan · 先总后分与阶段（详）

## 规划粒度 · 先总后分

**禁止**在 `PLANNING:true` 阶段直接列一长串 `TASK-*` 而不先对齐全局。两层结构已够用，**不必**引入 Epic/Story 嵌套 ID 或 A1/A2 子编号：

| 层 | 载体 | 作用 |
|----|------|------|
| **总** | Sprint **Goal** · **Done when** · 候选表对齐 | 主题边界、全局验收 |
| **分** | 扁平 `TASK-*` 表 · **执行顺序** | `/run`：`AUTONOMOUS:true` 时 **Sprint 连跑**；否则一次一个 `ACTIVE` |

大改动 / 跨模块 / 前后端并行：额外读 `rules/execution/vibe.mdc`（API 契约、层序）· `rules/feedback/evolution.mdc`（小步可回滚）。

### 阶段 1 · 总（先不写 TASK 表）

在 `PLANNING:true` 完成后再进入阶段 2。用 **AskQuestion**（不可用 → 正文选项；见 **master**「AskQuestion 约定」）与用户确认：

- [ ] **SDD 模式** — Sprint 增量 / Greenfield / Brownfield / 文档（见 **plan** skill §SDD · `reference/sdd/source-map.md`）；Greenfield 须 spec + **clarify** 再技术 plan
- [ ] **Goal** — 本 Sprint 要交付什么（一句话）
- [ ] **Done when** — 怎样算 Sprint 完成（可执行 verify 命令 + P0 全 ✅）
- [ ] **与候选表对齐** — 从 plan「下一 Sprint」立项则删对应候选行；新主题直接写 Active；**候选 >1 行** → 可选 **`reference/prioritization.md`** 排序
- [ ] **Scope / 非目标** — 本轮明确不做什么（防 scope creep）
- [ ] **风险与依赖** — 跨模块顺序、需先定的契约或接口
- [ ] **SPIKE 门禁** — 选型/方案/范围仍不确定 → 先列 `SPIKE-*`，结论归档后再拆 `TASK-*`（见 **scaffold** · **spike** agent）
- [ ] **依赖 / 自研选型（可选）** — 新增重量级依赖、仓内 vendor、或「本可开源却自研」→ 对照 `oss-first.mdc` 四问；授权与溯源见 `submodule.mdc`
- [ ] **Follow-up 立项闸门** — 见 §Follow-up（同症状重复 patch 时强制）
- [ ] **PRD 输入（可选 · 外部）** — 若已用 **ChatPRD** 等 IDE 插件写 PRD：人工提炼 Goal 写入 Sprint；**勿**调用仓内不存在的插件 skill 名
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

#### clarify 门禁（SDD · Greenfield /  substantial 需求）

吸收自 github/spec-kit `/speckit.clarify` · 在 **技术 plan / TASK 表之前**：

| 步 | 动作 |
|----|------|
| 1 | 基于 `spec.md`（或用户叙述）列 **覆盖维度**：范围 · 角色 · 边界 · 非目标 · 验收 |
| 2 | 生成 5–10 个**独立**澄清问题；用户可编号简答 |
| 3 | 写入 `{specs_dir}/<id>/clarifications.md` 或 spec 内 **## Clarifications** |
| 4 | 未澄清项标 `Decision needed` 或用户确认跳过 |

**Brownfield** 可缩短为 3–5 题；**Sprint 增量**模式可跳过。

### 阶段 2 · 分（再写 TASK 表）

全局对齐后再拆任务。每条 `TASK-*` 宜满足：

- **一个可执行验收命令**（`task-verify` 能判绿/红；见 `rules/feedback/verify.mdc`）
- **一次 commit 能讲完**（一逻辑一 commit · `rules/execution/commit.mdc`）
- **Target 列框住落点**（防 drive-by；`/run` 审计对照）
- **依赖显式出现在执行顺序**（B 依赖 A → 顺序里 A 在前）
- **Priority 争议**（P0/P1 不清或多候选 TASK）→ **`reference/prioritization.md`**（RICE/ICE/Kano/MoSCoW 选一）

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
