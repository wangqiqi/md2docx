---
name: learn
description: 学习项目（/learn）：CHANGELOG/git/archive→.cursorGrowth/learn/。不写 .cursor。
disable-model-invocation: true
---

# learn

边界见 `rules/workflow.mdc` · **`core.mdc`「.cursor 不可变」**。来源：`workflow.json` → `growth.learn_sources`

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
