---
name: week
description: >-
  周报（/week）：扫描工作区下 CHANGELOG.md，按年内第 N 周归纳进展，写入 .cursorGrowth/week-report/。
  说「周报」「本周总结」「weekly report」「总结最近一周」时也触发。
disable-model-invocation: true
---

# week · 周报

扫描工作区各仓库 **CHANGELOG.md**，归纳后写入 **`.cursorGrowth/week-report/第{N}周任务总结.md`**（本地、**不提交 git**）。

## 何时进入

- 用户说 **`/week`**
- 「周报」「本周总结」「总结最近一周的成果」

## 周范围

| 今天 | 统计区间 |
|------|----------|
| 周一～周四 | 本周一 ～ **今天** |
| 周五～周日 | 本周一 ～ **本周日** |

周号：**年内第 N 周**（包含 1 月 1 日的那一周为第 1 周）。

## 流程（Agent 一次跑完）

### 1. 采集

```bash
python3 .cursor/skills/week/scripts/collect-week.py --format meta
python3 .cursor/skills/week/scripts/collect-week.py --format raw
```

可选：

- `--workspace <dir>` — 默认 `~/workspace`（不存在时改用当前仓库父目录或 AskQuestion）
- `--today YYYY-MM-DD` — 测试用

### 2. 归纳并写入

```bash
mkdir -p .cursorGrowth/week-report
```

输出：`.cursorGrowth/week-report/第{N}周任务总结.md`（同周已存在则覆盖）。

**不要**只粘贴 CHANGELOG 原文。结构：

```markdown
# 第 {N} 周任务总结（{start} ～ {end}）

> 自动生成 · 来源：工作区 CHANGELOG

## 本周概览
## 按项目
## 亮点
## 风险 / 遗留
## 下周建议
```

- **本周概览**：3～5 条，跨项目主题
- **按项目**：有进展的仓库各一小节（版本 + 日期 + 要点）
- 中文为主；无条目时在概览说明

### CHANGELOG 格式兼容

采集器识别版本节分隔符：**ASCII `-`** · **en dash `–`** · **em dash `—`**（规范仍为 `-`，见 `changelog.mdc`）。

验收：`bash .cursor/skills/week/scripts/verify_collect_week.sh`

### 3. 确认

```bash
git status   # .cursorGrowth/ 不应出现在待提交列表
```

**禁止** `git add .cursorGrowth/week-report/`。

## 与 release 的关系

- **release**：各仓库写 CHANGELOG（数据源）
- **week**：只读聚合，不打 tag
