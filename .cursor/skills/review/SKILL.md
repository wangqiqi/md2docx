---
name: review
description: PR/代码结构化回顾（/review · REV-*）— 双轴清单；可委派 review agent（只读）
---

# review

**用这个**：`REV-*`、合并前结构化回顾、坏味道/复杂度扫读。**不是那个**：只跑 Bugbot/Security → 全局 `~/.cursor/skills-cursor/review`；安全深挖 → **security**；上线 7 维走查 → **delivery**；找根因修 bug → **debug**。

可委派 **review** agent（只读）。本 skill 管清单与输出格式。

## 双轴回顾（Standards · Spec）

分支 / PR / 自某 commit 起的变更，按**两轴**扫读（可并行 subagent，结果并排汇报）：

| 轴 | 问什么 | 证据来源 |
|----|--------|----------|
| **Standards** | 是否符合**本仓**已文档化规范？ | `rules/tech/*.mdc` · `.cursorGrowth/learn/dev-conventions.md` · 同目录既有代码风格 |
| **Spec** | 是否满足** originating issue / PRD / plan Goal**？ | PR 描述 · linked issue · `plan.md` Target · 验收命令 |

每轴输出：**通过 / 疑点 / Blocker** + `file:line` + 一句依据。两轴结论冲突时（规范过但偏离需求，或反之）标 **`Decision needed`**。

## 人类 reviewer 优先级

同一 diff 多问题时，**先报高影响、低噪声**（排序权重，非跳过清单）：

1. **上下文与架构** — 方案是否契合模块边界与既有抽象；有无过度设计
2. **正确性与 bug** — 边界、失败路径、回归风险
3. **安全边角** — auth、注入、密钥、对外契约（触发时叠加 **security** · **api**）
4. **缺测试** — 行为变更无对应测试或验收命令
5. **风格与 nit** — 命名、格式、注释（最低优先，可合并为一条）

## 输出格式

严重度（Blocker / High / Medium / Low）· `file:line` · 发现 · 建议 · （可选）**轴**：Standards / Spec

## 结构化清单

### 范围

- [ ] 符合 PR / REV 描述；无 drive-by 重构
- [ ] 落点与 plan Target 一致（若有）

### 正确性

- [ ] 边界与失败路径清楚；无吞异常 / 空 catch
- [ ] 并发、幂等、空值等与域相关的陷阱已考虑（有则查）

### 安全 / API（触发再扫）

- [ ] 高风险 diff（auth、密钥、对外 API、注入面）→ 叠加 **security** · **api** skills
- [ ] 无硬编码密钥；对外契约变更有文档/兼容说明

### 可测性

- [ ] 行为变更有对应测试或明确验收命令
- [ ] 纯 UI/文案可注明「手工/delivery」覆盖

### 可维护性

- [ ] 命名与模块边界清晰
- [ ] 重复逻辑 / 过长函数 / 深嵌套
- [ ] 复杂度与注释匹配意图（非噪声注释）

### 交付叠加（可选）

- [ ] `REV-*` 含交付/上线 → 叠加 **delivery** 7 维（+ 可选 §8–§11）（只读）

## 文档预审（PRD / 原型 · 吸收自 SpaceZephyr/pm-skills）

**用这个**：PRD、原型、功能说明过评审会前。**不是那个**：代码 diff（上节双轴）· 上线走查（**delivery**）。

1. 定严格度：快速过筛 / 标准（默认）/ 上线前终审
2. 按 **`reference/doc-review-checklist.md`** 六视角 + 意见红线 + 三级风险
3. 输出判定（通过/有条件/不通过）+ 复评清单

用户说「帮我看看这个 PRD」「模拟评审会」→ 本节。写完 PRD 后预审 → 链 **plan** `doc-prd-enrich.md` 待确认项优先核对。

## SDD analyze（吸收自 github/spec-kit）

**用这个**：Greenfield/Brownfield 在 **implement 前**或 **plan** 拆 TASK 后。**不是那个**：PR 代码回顾（上节清单仍适用）。

对照三件套（路径见 `workflow.json` `sdd.specs_dir`）：

| 检查 | 问什么 |
|------|--------|
| spec → plan | 每个用户故事/FR 在技术 plan 有落点？无孤儿需求？ |
| plan → tasks | 每个技术决策有 task？无未覆盖的 contract/research 项？ |
| tasks → spec | 每个 task 追溯到用户故事或 FR？无 scope 外 task？ |
| 术语 | spec/plan/tasks 同一实体同名？ |
| 验收 | TASK 验收列与 spec 验收场景、tasks checkpoint 一致？ |

输出：Blocker / High / Medium · 工件路径 · 缺口 · 建议修复（回 **plan** 或 **run** 勿静默扩 scope）。

## 与 plan

- 纯回顾不写代码 → `REV-*`；`next-task` 跳过但 gate 仍适用编码任务
- 交付走查 REV → 输出含 **`Decision needed`** 的文档冲突项（见 **delivery**）
