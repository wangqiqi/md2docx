# Plan & archive conventions（项目特化）

> 由 **`/learn`** 维护 · 供 **plan** · **run** · `runner.sh plan-check` 参考。  
> **勿**写入 `.cursor/rules` 或 skills 正文 — 团队差异只放本文件。

## Archive 命名

| 项 | 本项目 |
|----|--------|
| 目录 | `.cursorGrowth/archive/` |
| 格式 | `YYYYMMDD_HHMMSS_<topic>_<module>.md` |
| 说明 | `<topic>` / `<module>` 用英文或拼音缩写，避免空格 |

## Plan 可选段落（若有）

团队在 plan 中使用的**额外**基线段落（差距表、审查笔记等）在此登记；Sprint 收尾须与 `.cursorGrowth/archive/` 对齐：

| 段落类型（团队自定） | 收尾动作 |
|----------------------|----------|
| （待填） | 改 **交付态**，或链 `.cursorGrowth/archive/...` 作历史快照 |

## Sprint 区块标题

`runner.sh plan-check` 在 Sprint 闭合时会 WARN 仍为「进行中」标题的区块：

| 状态 | 标题示例（任选一种语言，团队统一即可） |
|------|----------------------------------------|
| 进行中 | `Active sprint` · `活跃 Sprint` |
| 已闭合 | `Completed sprint` · `已完成 Sprint` |

## 与母版分工

| 层 | 内容 |
|----|------|
| `.cursor/` | 通用机制：`SPRINT_STATUS` · Done when · TASK ✅ · reconciliation 清单 |
| 本文件 | 归档命名 · 可选段落类型 · 标题用语 |
