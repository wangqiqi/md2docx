---
name: master
description: 总入口（/master）— 迷路时 AskQuestion 路由 plan/run/learn 等
---

# master · 路由

**日常只需 `/run` ↔ `/plan`；真迷路 `/master`。** 说「help」「不知道用什么」「从哪开始」时也触发。其余 skill（delivery · test · api · debug · review …）由 Agent 按 plan 的 Goal/Done when **自动选用**，你不必记名字。

**只做路由与说明，不代替下游 skill 执行具体工作。** 弄清意图后 handoff 到对应 skill / rules，并给出「接下来你可以说 `/xxx`」。

路由表：[routes.md](routes.md) · 场景对照：`.cursor/README.md` 场景速查 · 速查：`docs/training/skills.md`

## 何时进入

- 用户说 **`/master`**
- 用户不清楚该用哪个指令 / skill
- 用户描述目标但未带 slash（如「帮我搭个项目」「验收总失败」「怎么发版」）
- 新会话、刚安装模板、空仓库且用户只说「开始吧」

**已有明确 slash**（如 `/plan` `/run` `/scaffold`）→ **不要**拦截，直接走对应 skill；**不要**为了「保险」多绕 `/master`。

**呼叫人格**（「呼叫小妮」「切换御姐」等）→ **不要**当普通闲聊：按 [routes.md §人格·呼叫](routes.md#呼叫会话内) 跑 `resolve-role.sh` → 写 `.cursorGrowth/session/persona.json` → 改语气（能力不减）。

## 流程

### 1. 快速感知（可选，不阻塞提问）

```bash
./.cursor/bin/scaffold.sh detect 2>/dev/null || true
./.cursor/bin/runner.sh gate-check 2>/dev/null || true
ls plan.md .cursorGrowth/learn/ 2>/dev/null || true
```

用于缩小选项（空仓库 / 无 plan / 有 ACTIVE / gate 阻塞等），**不向用户抛技术细节**。

### 2. AskQuestion — 主路由与子路由

**选项表 canonical** → [routes.md](routes.md)（主路由 · `more` 子路由 · 关键词索引 · 上下文捷径）。

本 skill 只保留：

- [routes.md](routes.md) 主路由与子路由选项表；**AskQuestion 工具约定**见本节下文
- 主路由 **≤7 项**；子路由按需第 2 轮，仍 ≤7 项
- 人格呼叫 → [routes.md §人格](routes.md#人格预设-style) · `resolve-role.sh`

#### AskQuestion 约定（工具可用性 · SSOT）

**优先**调用 Cursor 原生 `AskQuestion`（结构化多选；每轮 ≤7 项）。

若当前会话**无**该工具（模型未注入时常见，例如部分 Grok 会话；官方亦写 *when unavailable, ask in prose*）：

1. **勿空转、勿假装已弹出选择 UI**
2. 用 [routes.md](routes.md) **同一选项表**写成正文编号列表，请用户回复 **id 或序号**
3. 收到选择后按表 handoff — 流程与选项不变

下游 skill（plan · scaffold · ux · release …）凡写 AskQuestion，均遵循本约定。

**不要**在第 1 轮超过 7 项；原 `review` / `other` 合并进 `fix` 与 `more`（见 routes）。

### 3. Handoff

输出结构（简短）：

1. **推荐入口**：skill 名 + slash（若有）
2. **为什么**：1–2 句
3. **下一步**：用户可直接复制的一句话或命令
4. **可选**：相关 rules / docs 一行链接

**不要**在 master 里写业务代码、改 plan.md、apply 脚手架、commit 或改 `.cursor/`。

## 与 core 的关系

`core.mdc` 一级入口 + `.cursor/README.md` 场景速查均由 master 可达；master 是**认知层**，不替代 workflow 闸门。

| 下游 | master 不做 |
|------|-------------|
| plan | 写 Sprint / PLAN_APPROVED |
| run | 实现与 task-verify |
| scaffold | apply / audit |
| learn | 写 `.cursorGrowth/learn/` |
| release / ship | 改 CHANGELOG / tag |

## 禁止

- 用户已明确 `/plan` 等 slash 时仍强行走 master 问答
- 未弄清意图就执行 scaffold apply、commit、改 `.cursor/`
- 一次抛出全部 skill 列表让用户自己猜（必须 AskQuestion **或正文编号选项**收敛）
- 主路由或子路由单轮超过 7 个选项
- AskQuestion 不可用时卡住或只说「请用别的模型」而不给出正文选项
