# Sprint 立项门禁 · Goal 合格性（详）

防止把 **出口动作 / 流程收尾** 误立项为 Sprint（如「release + tag」「专打版 Sprint」）。与 **followup-facade**「禁止专补 README Sprint」同一类反模式。

## 分层对照（用这个 / 不是那个）

| 层 | 必须交付什么 | 典型载体 |
|----|--------------|----------|
| **Epic** | 多 Sprint 的大主题 | `/long` · `long-state.json` |
| **Sprint** | **一块能力 / 模块 / 用户可见增量** | `.cursorGrowth/plan.md` Active |
| **Task** | 一次可验证、可提交的增量 | `TASK-*` 表 |
| **Steps** | commit · 单文件改 · 命令一步 | Task 内部，无新 ID |
| **Sprint 出口** | merge · tag · push | **`/release`**（**不是** Sprint） |

```text
能力 Sprint（实现 TTS 模块）
  └─ TASK-007 … TASK-010
  └─ Sprint 收尾：verify · archive · CHANGELOG
  └─ /release（可选）：merge · tag   ← 出口，不是新 Sprint
```

## Sprint Goal 合格标准

**必须**描述 **能力、模块、契约或用户可见行为变化**。

阶段 1 **AskQuestion** 须区分：

| 用户意图 | 路由 |
|----------|------|
| 交付新能力 / 改模块 / 跨文件功能 | ✅ 立项 Sprint |
| 仅打 tag / 发版 / merge / 开 PR | ❌ **`/release`** |
| 仅更新 CHANGELOG / 归档笔记 | ❌ 并入当前 Sprint 最后一项 TASK 或 **run** 收尾 |
| 仅跑 verify / 补 README 门面 | ❌ Done when 或功能 TASK 同 Sprint（见 **followup-facade**） |
| 仅 commit / 整理 git | ❌ **run** 纪律，非 Sprint |

## 不合格 Goal 反例（禁止单独开 Sprint）

| 反例 Goal | 应改为 |
|-----------|--------|
| 「打版并发 tag」 | Sprint 全 ✅ 后 **`/release` §打版** |
| 「release + tag」 | 同上 |
| 「merge 到 main 并发版」 | **`/release` §分支** + 可选 §打版 |
| 「更新 CHANGELOG 并提交」 | 最后 TASK 或 Sprint 收尾 commit |
| 「跑 verify 并归档」 | Sprint **Done when** + **run** §Sprint 收尾 |
| 「补 README / 门面同步」 | 功能 TASK 同 Sprint（**followup-facade**） |
| 「git commit 收尾」 | **run** 每 TASK 必 commit |

**例外**：Sprint Goal **本身就是**「重写全站文档」「发布流程工具改造」等——须有可验收的**产物增量**（如新 release 脚本、新 CI），不是单纯执行一次发版。

## Done when ≠ Sprint Goal

| 写法 | 含义 |
|------|------|
| **Goal** | 本 Sprint **建造什么** |
| **Done when** 勾「打 tag」 | Sprint **完成后** 可走 `/release` — **不是** Goal 本身 |
| **Done when** 勾「verify 绿」 | 闭合条件 — **不是** 独立 Sprint |

**禁止**把 Done when 里的出口项抄进 Goal 当 Sprint 主题。

## 候选表卫生

「下一 Sprint 候选」**禁止**出现纯仪式行：

```markdown
| SPRINT-99 | 打版发 tag | SPRINT-04 已闭合 |   ← 删，改 /release
```

候选表每行 Goal 须能通过上表「合格标准」。

## plan-check 可观测

`runner.sh plan-check` 对 Active Sprint 的 `**Goal**` 行做启发式 WARN（仪式关键词且无能力关键词）→ 见 `plan-parse.sh` · `runner.sh plan_check`。

Agent 在 **阶段 3 handoff 前**仍须人工语义判断；脚本 WARN **不**替代 `/plan` 阶段 1 确认。

## 与 long / release 分工

| 入口 | 何时 |
|------|------|
| **long** | 多 Sprint **能力** Epic |
| **plan** | 单 Sprint **能力** 迭代 |
| **run** | TASK 实现 + 收尾 archive |
| **release** | merge / PR / tag / push |

**禁止**用 `/long` 或 `/plan` 包装「只为发版」的流程 Sprint。

## 引用

- README 门面反模式 → `followup-facade.md`
- 阶段 1 清单 → `phases.md` §阶段 1
- 出口 SSOT → **release** skill
