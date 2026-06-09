---
description: jwplan/jwrun 开发闭环 — plan 真源、硬闸门、分层验收、打版归档
alwaysApply: true
---

# 开发工作流（jwplan · jwrun）

## Command / Skill 分层

- **Command**（用户入口）：`/jwplan` · `/jwrun`（短名）
- **Skill**（Agent 细则）：`jwplan-skill` · `jwrun-skill`（`-skill` 后缀，与 command 区分）

## 分工

- **`/jwplan`** → `jwplan-skill`：`PLANNING:true` → 拆 Sprint → AskQuestion → handoff
- **`/jwrun`** → `jwrun-skill`：`gate-check` → ACTIVE → task-verify → commit → **patch 打版** → Sprint 闭合归档

## plan 真源

- 根目录 **`plan.md`**：Sprint 编排、ACTIVE、闸门元数据
- **根 `plan.md`**：Sprint / 待办真源（非 `docs/` 内）
- 已完成 Sprint 归档 **`archive/sprint/`**

## 硬闸门（jwrun 未过必停）

| 条件 | 动作 |
|------|------|
| `PLANNING: true` | 仅 jwplan |
| 无 `PLAN_APPROVED` | 仅 jwplan 确认 |
| `gate-check` 非 OK | 禁止编码 |

## 分层验收

- **每任务**：`.cursor/bin/dev_runner.sh task-verify`（验收列命令或 pytest 启发式）
- **打版前 / Sprint 闭合**：`.cursor/bin/dev_runner.sh verify` 全量（plan `<!-- VERIFY -->`，默认 `pytest -q`）
- 禁止每任务都跑全量 pytest

## 执行顺序

- plan 必有 `**执行顺序**` 行；完成后用 `next-task` 推进 `ACTIVE`/`NEXT`
- 禁止留空 ACTIVE

## 打版（jwrun §6 · 每任务）

`task-verify` 绿 → commit → **CHANGELOG 升 patch** + 同步 `pyproject.toml` / `__version__` → `git tag v0.4.xx`（读 plan `VERSION_LINE`）→ 更新 plan `RELEASED`

**禁止**多任务堆积无 tag。

## Sprint 闭合归档（jwrun §7）

全量 verify → `archive/sprint/YYYYMMDD_HHMMSS_*` → plan 瘦身

Sprint 结束且 ROADMAP 有余项 → **/jwplan** 下一 Sprint

## 自治（jwrun）

- `AUTONOMOUS: true`：**直接执行** skill 建议，不问「是否继续 / push / 打版」
- **须停并征得同意**：高风险删除 · 项目外路径/其他仓库
- 高风险删除 → **`archive/_delete/YYYYMMDD_HHMMSS_删除_*`** 移入暂存，禁止直接 `rm`

## 阻塞

`⚠️` → 回流 jwplan，勿硬跑
