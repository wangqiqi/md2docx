---
name: master
description: 总入口（/master）— 迷路时 AskQuestion 路由 plan/run/learn 等
---

# master · 路由

**日常只需 `/run` ↔ `/plan`；真迷路 `/master`。** 其余 skill（delivery · test · api · debug · review …）由 Agent 按 plan 的 Goal/Done when **自动选用**。

**只做路由与说明，不代替下游执行。**

## 何时进入

- 用户说 **`/master`** · 不清楚用哪个指令 · 描述目标但未带 slash（「帮我搭个项目」「验收总失败」）
- 新会话 · 刚安装 · 空仓库且只说「开始吧」
- **已有明确 slash**（`/plan` `/run` `/scaffold`）→ **不要拦截**，直接走对应 skill

## 主路由（≤7 项 · canonical）

| id | 意图 | 入口 | 关键词（中英） |
|----|------|------|----------------|
| `scaffold` | 新建 / 空项目 | **scaffold** `/scaffold` | 脚手架 · 初始化 · 空仓库 · bootstrap |
| `plan` | 规划 / Sprint / 调研 / 文档 | **plan** `/plan` | 规划 · 需求 · Sprint · SPIKE · DOC |
| `run` | 继续开发 | **run** `/run` | 继续 · 做任务 · ACTIVE · next task |
| `learn` | 了解本仓 | **learn** `/learn` | 本仓约定（**不是** study 学技术） |
| `fix` | bug / 验收 / 闸门 | bugfix · **run**/**plan** | bug · verify 失败 · gate-check · 卡住 |
| `ship` | 发版 | **release** · **ship** | 打版 · 发版 · CHANGELOG · tag |
| `more` | 审查 / 文档 / 依赖 / 配置 | 见下表 | commit · PR · security · api · submodule · config |

## `more` 子路由（第 2 轮 · ≤7 项）

| 子 id | 意图 | 入口 |
|-------|------|------|
| `git` | Git / PR / Review / 收尾 | **git** · **release** · **review** · `autopilot` · `split-to-prs` |
| `security` | 安全审查 | **security** · `prompt-security` |
| `api` | API / schema / 客户端契约 | **api** · `rules/execution/api.mdc` |
| `delivery` | 上线前 7 维交付走查 | **delivery** `/delivery` |
| `manual` | 使用说明书 / 配图 regen | **user-manual** `/manual` |
| `report` | 测试报告 / verify 汇总 | **test-report** `/report` |
| `ux` · `ia` · `deps` · `docs` · `config` · `style` | 体验分流 · 信息架构 · 依赖选型 · 文档同步 · verify 配置 · 人格语气 | **ux** · **ia** · 详表见 `routes.md` |

## 快速感知（可选，不阻塞提问）

```bash
./.cursor/bin/scaffold.sh detect 2>/dev/null || true
./.cursor/bin/runner.sh gate-check 2>/dev/null || true
```

## AskQuestion 约定（SSOT）

**优先**用 Cursor 原生 `AskQuestion`（每轮 ≤7 项）。若会话**无**该工具（部分模型未注入）：

1. **勿空转、勿假装已弹出选择 UI**
2. 用**同一张表**写成正文编号列表，请用户回 **id 或序号**
3. 收到选择后按表 handoff —— 流程与选项不变

下游 skill（plan · scaffold · ux · release …）凡写 AskQuestion，均遵循本约定。

## Handoff 输出（简短）

1. **推荐入口**：skill + slash（若有） 2. **为什么**：1–2 句 3. **下一步**：可直接复制的一句话 4. **可选**：相关 rules / docs 一行

## 禁止

- 已有明确 slash 仍强行走 master 问答
- 未弄清意图就执行 scaffold apply / commit / 改 `.cursor/`
- 一次抛出全部 skill 列表让用户自己猜 · 单轮选项 >7
- 在 master 内写业务代码 · 改 plan.md · apply 脚手架 · commit

## 详表（**按需**再读，避免默认 payload）

- 关键词索引 · 上下文捷径 · 人格呼叫（12 人格）· DAILY/LIBRARY 裁剪 · spec-kit / pm-skills 对照 → [routes.md](routes.md)
- 场景速查 → `.cursor/README.md` · 速查表 → `docs/training/skills.md`
