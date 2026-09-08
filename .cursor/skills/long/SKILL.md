---
name: long
description: >-
  长程调度（/long）：Epic→Sprint→Task 三层收敛，跨 Sprint plan/run 链与 checkpoint。
  说「长程任务」「全自动做到底」「Epic」「多 Sprint」「long resume」时触发。
disable-model-invocation: true
---

# long

**用这个**：跨多个 Sprint 的大目标，模拟程序员「总规划 → 分 Sprint → 每 Sprint plan+run → 归档 → 下一 Sprint」。**不是那个**：单 Sprint 内连跑 → **`/plan` + `/run` 一次**（`AUTONOMOUS:true`）；定时保活 → 系统 **loop** skill。

详文：`reference/hierarchy.md` · `reference/pacing-checkpoint.md` · **plan** `reference/autonomy-chain.md`

## 何时进入

- 用户 **`/long <Epic 目标>`**
- 「自动规划并做到底」「长程开发」「跨天任务」「像程序员一样自己 plan run」
- **`/long resume`** — 读 `.cursorGrowth/long-state.json` 续跑
- `/master` 关键词命中（见 **master** `routes.md`）

**已有单 Sprint ACTIVE** 且用户只说 `/run` → **不要**拦截，走 **run**。

## 三层收敛（硬限制）

| 层 | 上限 | 载体 |
|----|------|------|
| Epic → Sprint | ≤5 | `long-state.json` · plan 候选表 |
| Sprint → Task | ≤5 | `.cursorGrowth/plan.md` |
| Task 深度 | 仅 L2 | 禁止 Task 子 ID |

超限 → 合并抽象或拆多个 Epic，**禁止**加深层级。详 `reference/hierarchy.md`。

## 流程

### 1. Epic 立项（L0）

1. 读 `learn/` · 现有 plan 候选表 · 用户目标
2. 写/更新 `.cursorGrowth/long-state.json`（schema → `reference/pacing-checkpoint.md`）
3. 拆 **≤5** 个 Sprint（各一句 Goal + 依赖），**AskQuestion** 确认（≤4 项；不可用 → 正文编号）
4. `status: active` · `active_sprint_index: 0`

用户首句已含「自动 plan 并连跑」→ 视作批准 Sprint 列表，但仍须落盘 long-state。

### 2. Sprint 循环（L1）

对每个 `sprints[i]`，**顺序执行**：

| 步 | 动作 | 入口 |
|----|------|------|
| a | 阶段 1：Goal · Done when · Out of scope | **plan** skill 阶段 1 |
| b | 阶段 2：TASK 表 ≤5 + 执行顺序 | **plan** 阶段 2 |
| c | handoff：`PLANNING:false` · `PLAN_APPROVED` · `AUTONOMOUS:true` | **plan** 阶段 3 |
| d | `gate-check` OK → 实现全部 TASK | **run**（同会话连跑，勿等第二次 `/run`） |
| e | Sprint 收尾：verify · archive · plan reconciliation · long-state checkpoint | **run** §Sprint 收尾 + `pacing-checkpoint.md` |
| f | `active_sprint_index++`；仍有 Sprint → 回到 a；否则 Epic `completed` | |

**Sprint 间**：可选 60–180s 休息或结束会话；跨天用 `/long resume` 或 `/loop`（见 `pacing-checkpoint.md`）。

### 3. 恢复（resume）

```bash
./.cursor/bin/runner.sh gate-check
```

1. 读 `long-state.json` + `plan.md`
2. `paused` / `MAX_LOOPS` → 向用户说明 `interrupt_reason`，确认后续
3. 当前 Sprint 未完成 → 续 **run**（ACTIVE）
4. 当前 Sprint 已闭合 → 对下一 Sprint 执行 §2a–f

## 与 plan / run / loop 分工

| 组件 | 职责 |
|------|------|
| **long** | Epic 外壳 · Sprint 顺序 · checkpoint · resume |
| **plan** | 单 Sprint 的 Goal/TASK/handoff |
| **run** | TASK 实现 · verify · commit · 单 Sprint 自治链 |
| **loop**（系统） | 定时/事件唤醒；long 文档化配合，不修改其源码 |

## 决策打断

与 `workflow.json` → `autonomy.interrupt_on` 一致；另加 Epic 级：

| 类型 | long 动作 |
|------|-----------|
| `decision_needed` | 暂停 Epic 链 · long-state `paused` + `interrupt_reason` |
| `blocker` | 同左；用户 `/plan` 后 `/long resume` |
| `high_risk` | 必须用户确认 |
| `goal_drift` | 停 Epic · 说明偏离点 |
| `release` | 交 **release** / 用户明示 |

**非决策（勿停 Epic）**：Sprint 内 TASK 切换 · commit · CHANGELOG · README 门面。

## 禁止

- 绕过 `gate-check` / `task-verify` / `PLAN_APPROVED`
- 在 Task 运行中静默插入新 TASK 或新 Sprint
- 修改 `run-stop` hooks 默认行为（须单独 Sprint 授权）
- 把 long 做成无限任务树生成器

## 验收（母版 Sprint）

涉及 `.cursor/skills/long/` 变更时，Sprint Done when 含：

```bash
bash .cursor/bin/cursor-coherence.sh
```

Epic 全闭合：long-state `status: completed` · plan 无 Active · 候选表更新。
