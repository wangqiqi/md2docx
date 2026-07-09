---
name: master
description: 总入口（/master）：不确定用什么指令时用。AskQuestion 路由到 plan/run/learn/scaffold/release/git/security/api/ux/ia/debug/test/review/study 及 README 全场景。说「help」「不知道用什么」「从哪开始」时也触发。
---

# master · 路由

**日常只需 `/run` ↔ `/plan`；真迷路 `/master`。** 其余 skill（delivery · test · api …）由 Agent 按 plan 的 Goal/Done when **自动选用**，你不必记名字。

**只做路由与说明，不代替下游 skill 执行具体工作。** 弄清意图后 handoff 到对应 skill / rules，并给出「接下来你可以说 `/xxx`」。

路由表：[routes.md](routes.md) · 场景对照：`.cursor/README.md` 场景速查 · 速查：`docs/training/skills.md`

## 何时进入

- 用户说 **`/master`**
- 用户不清楚该用哪个指令 / skill
- 用户描述目标但未带 slash（如「帮我搭个项目」「验收总失败」「怎么发版」）
- 新会话、刚安装模板、空仓库且用户只说「开始吧」

**已有明确 slash**（如 `/plan` `/run` `/scaffold`）→ **不要**拦截，直接走对应 skill；**不要**为了「保险」多绕 `/master`。

## 流程

### 1. 快速感知（可选，不阻塞提问）

```bash
./.cursor/bin/scaffold.sh detect 2>/dev/null || true
./.cursor/bin/runner.sh gate-check 2>/dev/null || true
ls plan.md .cursorGrowth/learn/ 2>/dev/null || true
```

用于缩小选项（空仓库 / 无 plan / 有 ACTIVE / gate 阻塞等），**不向用户抛技术细节**。

### 2. AskQuestion — 主路由（**≤7 项**）

文案跟用户语言；中文示例：

| 选项 id | 用户看到 | 路由 |
|---------|----------|------|
| `scaffold` | 新建 / 空项目 / 搭脚手架 | **scaffold** |
| `plan` | 规划、拆 Sprint、调研或文档任务 | **plan** |
| `run` | 按 plan 继续开发、做 TASK | **run** |
| `learn` | 让 Agent 了解本项目、沉淀约定 | **learn** |
| `fix` | 修 bug、验收失败、闸门/verify 排查 | bugfix rules · **run**/**plan** |
| `ship` | 发版、CHANGELOG、打 tag | **release** · **ship** |
| `more` | 提交 / PR / 审查 / 文档 / 依赖 / 配置… | 见 § 子问题 · [routes.md](routes.md) |

**不要**在第 1 轮超过 7 项；原 `review` / `other` 合并进 `fix` 与 `more`。

### 3. 子问题（按需，每轮仍 ≤7 项）

#### `scaffold`

| 子选项 | 路由 |
|--------|------|
| 空目录 | **scaffold** → `apply` + `--dry-run` 预览 |
| 已有代码 | **scaffold** → `audit` |

#### `plan`

| 子选项 | 路由 |
|--------|------|
| 功能 Sprint / 拆 TASK | **plan** `/plan` — 先 **Goal** · **Done when**，再拆 TASK |
| 技术调研 SPIKE | **plan** · 任务 ID `SPIKE-*` |
| 纯文档 DOC | **plan** · 任务 ID `DOC-*` · `rules/execution/docs.mdc` |
| Sprint 收尾 / 归档 ROADMAP | **plan** · `archive/` · `rules/feedback/changelog.mdc` |

#### `run`

- `gate-check` ≠ OK → 建议 **plan**（补 `PLAN_APPROVED` 或 `PLANNING:false`）
- `task-verify` / `verify` 失败 → 见 **`fix`** 子问「验收失败」
- 否则 → **run** `/run`

#### `fix`

| 子选项 | 路由 |
|--------|------|
| 线上 bug / hotfix | `rules/execution/bugfix.mdc` · 小改 **git**；复杂 **plan** |
| task-verify / verify 失败 | **run** 修代码；2 轮仍失败 → **plan** 标 `⚠️` · `rules/feedback/verify.mdc` |
| gate-check 被挡 | **plan** · `./.cursor/bin/runner.sh gate-check` |

#### `ship`

| 子选项 | 路由 |
|--------|------|
| 发版清单（人主导） | **release** skill |
| 自治打版（Agent 执行） | **ship** agent |

#### `more`（第 2 轮 AskQuestion，≤7 项）

| 子选项 id | 用户看到 | 路由 |
|-----------|----------|------|
| `git` | Git 提交 / PR / push / 收尾 | **git** · **release** · babysit · split-to-prs · `commit.mdc` · collaboration |
| `security` | 安全审查（密钥 / PII / 鉴权） | **security** |
| `api` | REST / OpenAPI 设计审查 | **api** · `rules/execution/api.mdc` |
| `delivery` | 交付验收 / 上线前走查 | **delivery** · `rules/execution/delivery.mdc` |
| `docs` | 文档与代码同步更新 | **plan** `DOC-*` 或直述 · `rules/execution/docs.mdc` |
| `deps` | submodule / vendor 升级 | `rules/execution/submodule.mdc` |
| `config` | verify 配置 / 本地 rules / 模板自测 | 见 [routes.md § 扩展](routes.md#扩展场景) |
| `style` | 人格 / 沟通语气 | `config/roles.json` · 见 [routes.md § 人格](routes.md#人格预设-style) |

若 `more` 仍不匹配 → 请用户一句话描述 → 查 [routes.md 关键词](routes.md#关键词索引)。

### 4. Handoff

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
- 一次抛出全部 skill 列表让用户自己猜（必须 AskQuestion 收敛）
- 主路由或子路由单轮超过 7 个选项
