---
name: learn
description: 学习项目（/learn）：CHANGELOG/git/archive→.cursorGrowth/learn/。不写 .cursor。
disable-model-invocation: true
---

# learn

**用这个**：沉淀**本仓库**约定 → `.cursorGrowth/learn/`。**不是那个**：学 Rust/新框架等通用技术 → **study**（可写 `SPIKE-*`）。

边界见 **cursor-standalone** · `workflow.json` → `growth.learn_sources`

## Growth 边界（产出 · 非母版 SSOT）

| 层 | 规则 |
|----|------|
| **写入** | 本 skill 只产出 `.cursorGrowth/learn/`（及 `/plan`·`/run` 写 plan · archive） |
| **读取** | `/run` 可**按需**读已有 `learn/`；`/learn` 可吸收本地 `archive/` · `plan` — **仅本机项目上下文** |
| **母版禁止** | `.cursor/` 文档**不得**链具体 archive 文件名；对外发版由 **release** 写仓库根发版文件（母版正文不链） |
| **不是** | 把 archive 当安装包内容；把 Growth 路径写进母版业务代码 |

## 输出（仅 `.cursorGrowth/learn/`）

**自动引导**（无需等用户说 `/learn`）：

1. **`install-super-cursor.sh`** — 复制 `templates/cursorGrowth/` → 目标 `.cursorGrowth/`
2. **`hooks/growth-init.sh`**（`beforeSubmitPrompt`）— 若目录缺失则创建；**按文件**种子 `learn/*.md`（已存在的不覆盖）

首次 **`/learn`** 在种子文件上**增量填写**「待填」项，并吸收 CHANGELOG / archive / plan。

| 文件 | 内容 |
|------|------|
| `plan-conventions.md` | archive 命名 · 可选 plan 段落 · Sprint 标题用语 — 供 **plan** / **run** / `plan-check` |
| `dev-conventions.md` | 命名、目录、测试/verify 命令、分支策略 |
| `module-map.md` | 模块边界、入口、依赖方向 |
| `release-rhythm.md` | 发版频率、谁打 tag、CHANGELOG 习惯 |
| `changelog-insights.md` | 近期对外变更摘要 |
| `last-sync.md` | 本次同步时间、来源、待确认项 |
| `acceptance.md` | （可选）design tokens · i18n · OpenAPI — 供 **delivery** skill |

**实验 / 批跑坐标**（通用闭环见 **spike** agent §experiment-loop）→ 写入 `dev-conventions.md` 或 `learn/` 专节：产物根目录 · 报告命名 · 索引 README · gate 脚本路径。**勿**把项目路径写进 `.cursor/` 母版。

## 何时运行

| 时机 | 动作 |
|------|------|
| 新项目接入 | 首次 `/learn` 建骨架 |
| Sprint 结束 | 吸收 archive 中 **Goal**、决策、**Out of scope** / ROADMAP |
| 大重构后 | 更新 `module-map` |
| 发版后 | 更新 `release-rhythm` + `changelog-insights` |
| 重复劳动审计 | 用户要求或 Sprint 密集 patch 后 → §CHANGELOG 重复模式审计 |
| 约定缺口 | 用户说「该加规则吗」或反复踩同一坑 → §建议约定 |
| 命令/验收意外失败 | 记 **ERRORS** 摘要 → §经验捕获 |
| 用户纠正（「不对」「其实…」） | 记 **LEARNINGS** → §经验捕获 |

## 经验捕获（任务中 · 可选）

**用这个**：可复用教训写入 `.cursorGrowth/learn/`。**不是那个**：改母版 `.cursor/`（须 plan 授权 + TASK）。

| 类型 | 写什么 | 默认落点 |
|------|--------|----------|
| **ERRORS** | 失败上下文 · 根因 · 已验证修复 | `dev-conventions.md` §建议约定 或 `changelog-insights.md` |
| **LEARNINGS** | 偏好 · 纠正 · 可复用模式 | 同上；跨模块边界 → `module-map.md` 一句 |

**晋升门禁**：重复 ≥2 或广泛适用 → 走 §建议约定 → **用户确认** → `learn/` 或 `rules/local/`；**禁止**自动改 `.cursor/skills|rules|config`。单会话草稿可留在回复中，不必每次落盘。

## 建议约定（蒸馏自 suggesting-cursor-rules）

**用这个**：从本仓证据提出「该记哪条约定」。**不是那个**：新开 Sprint 拆 TASK → **plan**；学通用技术 → **study**。

### 何时建议

- Sprint 收尾 / `/learn` 吸收后，发现重复决策或口头约定未落盘
- CHANGELOG / archive 同症状簇 ≥2（见上节重复模式审计）
- 用户明确问「要不要加 rule / convention」

### 证据 → 建议 → 落点

| 证据来源 | 建议形态 | 默认落点 |
|----------|----------|----------|
| archive · plan Out of scope | 一行「本仓不做什么」 | `learn/plan-conventions.md` 或 `dev-conventions.md` |
| 命名/目录/verify 命令 | 可执行约定 | `learn/dev-conventions.md` |
| 模块边界 | 依赖方向一句 | `learn/module-map.md` |
| 团队特化门禁（仍属本仓） | 短 rule | `.cursorGrowth/rules/local/`（链 `.cursor/rules/local`） |
| 母版 SOP 缺口 | **仅建议 + 等授权** | **禁止**日常写入 `.cursor/` |

### 输出格式（写给用户确认）

```
建议约定：
- 证据：…（CHANGELOG 版本 / archive 名 / file:line）
- 建议条文：…
- 落点：learn/… 或 rules/local/…
- 不写入：.cursor/ 母版（除非用户明确授权 + plan TASK）
```

**禁止**：无证据空建议；擅自改 `.cursor/rules|skills|config`；把通用技术笔记塞进 learn（去 **study**）。

## CHANGELOG 重复模式审计（可选）

当用户说「重复工作」「follow-up 太多」或 `followup_gate` 触发时：

1. 读 `CHANGELOG.md` 最近 7/30 天（或用户指定窗口）
2. grep 症状关键词簇（进度/上传/弹窗/刷新/error_message/检测器/死代码…）
3. 对照 `.cursor/rules/execution/async-progress.mdc` 等 **通用根因类型** 归类
4. 更新 `.cursorGrowth/learn/changelog-insights.md` §重复工作模式（**只写项目符号与版本**）
5. 建议 plan 候选：合并 Sprint · SPIKE · 关闭多余 follow-up

模板：`.cursor/templates/cursorGrowth/learn/changelog-insights.md` · SPIKE：`.cursor/templates/spike-regression-cluster.md`

## 合并原则

- **增量合并**：保留旧条目，标 `（已废弃）` 而非直接删
- **不确定** → `（待确认）`，不写入 `.cursor/`
- **不 commit** `.cursorGrowth/`（git 忽略）
- 读序仍为：rules → config → **learn/**（覆盖项目默认）

## 演进循环

| 变更类型 | 去向 | 谁可写 |
|----------|------|--------|
| 项目约定、模块地图 | `.cursorGrowth/learn/` | **learn** |
| 母版 `.cursor/` SOP | 须用户明确授权 + plan 任务 | 非日常 learn |
| Sprint 决策 | `.cursorGrowth/archive/` + plan 索引 | **plan** 收尾 |

- 母版与项目边界：见 `rules/feedback/evolution.mdc`
- 增量合并 learn；标 `（已废弃）` 而非静默删除
