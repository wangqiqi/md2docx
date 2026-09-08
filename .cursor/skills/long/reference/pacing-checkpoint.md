# long · 节奏、checkpoint 与续跑（详）

长程执行的三类风险：**配额/会话超时**、**上下文膨胀**、**无限细拆**。本页定义 **何时快跑、何时停顿、如何恢复**。

## 节奏原则

| 层级 | 驱动 | 是否 sleep |
|------|------|------------|
| **Task** | 事件（verify 绿 → next-task） | ❌ 不 sleep |
| **Sprint 结束** | checkpoint 完成后 | ✅ 短休息 60–180s（可选） |
| **Epic 阶段** | 用户确认或 `/loop` 唤醒 | ✅ 可更长；失败指数退避 |
| **等 CI/部署** | 事件 watcher | 用系统 `/loop` watcher，勿 tight poll |

**用这个**：Sprint 内靠 **run** 自治链零间隔连跑。**不是那个**：每个 TASK 后 `sleep`（拖慢且无益）。

## 限流与 MAX_LOOPS

| 机制 | 配置 | 行为 |
|------|------|------|
| `MAX_LOOPS` | plan `<!-- MAX_LOOPS: 15 -->` · `workflow.json` | `run-stop` 达上限停跑，人工 `/long resume` 或 `/run` |
| Epic `max_sprints` | long-state（默认 5） | 超出须回 Epic 重排 |
| 失败熔断 | **run** · **debug** | 同 Task 自修 ≤2 轮仍红 → `⚠️` 停链 |

不因「怕限流」降低 verify 标准；用 **checkpoint + 可恢复** 代替盲目连刷。

## Checkpoint（Sprint 结束时必做）

1. `./.cursor/bin/runner.sh verify`（满足当前 Sprint Done when）
2. Sprint 笔记 → `.cursorGrowth/archive/`（`YYYYMMDD_HHMMSS_功能_模块.md`）
3. 更新 **long-state.json**（见下）
4. **plan 正文 reconciliation**（删已闭合 Active 区块，见 **run** §Sprint 收尾）
5. （可选）短 sleep 或结束会话，下一 Sprint 新上下文启动

## long-state.json

路径：**`.cursorGrowth/long-state.json`**（gitignore，与 plan 同级）。

```json
{
  "epic_id": "EPIC-001",
  "goal": "一句话 Epic Goal",
  "done_when": ["可执行验收条目"],
  "status": "planning | active | paused | completed",
  "autonomous": true,
  "max_sprints": 5,
  "sprints": [
    {
      "id": "SPRINT-04",
      "goal": "…",
      "status": "pending | active | done",
      "plan_sprint_meta": "SPRINT-04"
    }
  ],
  "active_sprint_index": 0,
  "last_checkpoint": "2026-08-04T17:30:00+08:00",
  "last_done_task": "TASK-010",
  "interrupt_reason": null
}
```

| 字段 | 说明 |
|------|------|
| `status: paused` | 决策打断 · MAX_LOOPS · 用户暂停 |
| `active_sprint_index` | 指向 `sprints[]` 当前项 |
| `interrupt_reason` | 恢复时 Agent 先读再行动 |

**resume**：`/long resume` 或「继续长程任务」→ 读 long-state + plan → 从 `active` Sprint 或下一 Sprint 的 plan handoff 继续。

## 与系统 `/loop` 配合

系统级 **loop** skill（`~/.cursor/skills-cursor/loop`）是 **外层调度器**；**long** 是 **Epic SOP**。

推荐（跨天 / 易断连）：

```text
/loop 3m "读 .cursorGrowth/long-state.json：
若 status=active 且 plan 有 ⬜/🔧 → 执行 /run 推进；
若当前 Sprint 已闭合 → long checkpoint 并 plan 下一 Sprint；
若 status=completed → 停止 loop。"
```

动态模式：Sprint 内不 arm loop；Sprint 间 arm **较长** heartbeat（3–10m）作保活兜底。

## 三种运行模式

| 模式 | 适用 | 用户操作 |
|------|------|----------|
| **同会话** | 2–3 Sprint · 数小时 | `/long <goal>` 一次，Sprint 间不新开对话 |
| **checkpoint 续跑** | 跨天 · 高风险 | 每 Sprint 结束人工看一眼 diff，「继续」 |
| **loop 守护** | 无人值守倾向 | `/long` + `/loop`；决策点仍停 |

## 引用

- 层级 → `hierarchy.md`
- 自治链 → **plan** `reference/autonomy-chain.md`
- loop 协议 → 系统 `loop` skill（勿改其源码；long 只文档化配合方式）
