---
name: code-stats-viz
description: >-
  代码统计可视化（无 slash · 关键词）：Git 跟踪文件行数/语言分布/提交日历，生成交互式 HTML 仪表板，
  写入 .cursorGrowth/code-stats/。说「代码统计」「代码量」「语言分布」「提交热力图」「code stats」时触发。
disable-model-invocation: true
---

# code-stats-viz · 代码统计仪表板

**工具技能**（无 slash · 非 plan/run 主路径）。**用这个**：仓库体量与语言分布、提交活动可视化。**不是那个**：磁盘占用 → **disk**；周报 → **week**；测试报告 → **test-report** `/report`。

基于 `git ls-files`（默认）扫描代码行数，用 ECharts 生成交互式 HTML：**语言饼图/柱状图** · **提交日历热力图** · **小时/周分布** · **可过滤目录与文件类型**。

产出写入 **`.cursorGrowth/code-stats/`**（本地、**不提交 git**）。

## 何时进入

- 用户说「代码统计」「代码量」「语言分布」「提交热力图」「仓库有多大」「code stats dashboard」
- Sprint 收尾前想了解仓库结构（辅助 **plan** / **review**，不替代 verify）
- `/master` 关键词命中

## 前置

- **python3**（标准库 + `git` 在 PATH）
- 分析目录为 **Git 仓库**（默认 `git_only`）；非 git 仓用 `--no-git-only`
- 生成 HTML 需联网加载 ECharts CDN（`cdn.jsdelivr.net`）；离线环境仅保留 HTML 文件本地打开可能无图表

## 流程（Agent 一次跑完）

### 1. 生成仪表板

```bash
mkdir -p .cursorGrowth/code-stats
python3 .cursor/skills/code-stats-viz/scripts/code_stats_viz.py \
  --dir . \
  --output ".cursorGrowth/code-stats/$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")_code_stats.html" \
  --open
```

未在 git 仓时，去掉 `basename` 子命令，直接指定输出文件名。

**默认行为**（脚本内置，一般不必改）：

| 项 | 默认 |
|----|------|
| 文件范围 | 仅 **git 跟踪** 文件（`git ls-files`） |
| 排除目录 | `.git` `.cursor` `.cursorGrowth` `node_modules` `venv` `3rdparty` 等（见脚本 `DEFAULT_EXCLUDE_DIRS`） |
| 跳过后缀 | 模型/二进制/媒体（`.onnx` `.pt` 图片音视频等） |
| 提交统计 | **当前分支** · 最近 **365 天** |
| 子模块 | 自动排除 git submodule 内文件 |

### 2. 常用选项

```bash
# 只统计子目录（文件 + 提交日历均限定）
python3 .cursor/skills/code-stats-viz/scripts/code_stats_viz.py --dir . --subdir sdk

# 全历史 · 所有分支
python3 .cursor/skills/code-stats-viz/scripts/code_stats_viz.py --dir . --all-branches --all-history

# 含未跟踪文件（全目录 walk）
python3 .cursor/skills/code-stats-viz/scripts/code_stats_viz.py --dir . --no-git-only

# 追加排除目录
python3 .cursor/skills/code-stats-viz/scripts/code_stats_viz.py --dir . --exclude-dir vendor --exclude-dir data
```

### 3. 验收

```bash
bash .cursor/skills/code-stats-viz/scripts/verify_code_stats_viz.sh
git status   # .cursorGrowth/code-stats/ 不应出现在待提交列表
```

**禁止** `git add .cursorGrowth/code-stats/`。

## 与 disk / week 分工

| Skill | 看什么 |
|-------|--------|
| **code-stats-viz** | 代码行数 · 语言 · Git 提交节奏 |
| **disk** | 磁盘占用字节 · 目录体积变动 |
| **week** | 多仓 CHANGELOG 周报文字归纳 |

## 脚本位置

`skills/code-stats-viz/scripts/code_stats_viz.py` — 母版随 `.cursor/` 安装；**勿**在业务仓复制第二份，统一调 skill 路径。
