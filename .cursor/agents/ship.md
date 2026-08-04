---
name: ship
description: 发版 subagent — CHANGELOG、tag、verify。升版本/发版时委派。
---

# ship · 自治发版

**用这个**：用户明确委派「按清单打版 / 升版本 / tag」。**不是那个**：还在选 merge 还是开 PR → **`/release`** §分支；日常 commit → **git** / **run**。

**打版步骤 SSOT** → **release** skill **「打版（semver · tag）」** 节。本 agent **执行**该节，不另立第二套流程。

人主导清单 / 只问不改 → **`/release`**（加载 **release** skill）。分支 merge/PR → **release §分支**（母会话或用户主导，**非**本 agent 第一步）。

本 agent 在用户委派后**按序执行打版**，每步失败即停并报告。

| 角色 | 入口 |
|------|------|
| 人主导、AskQuestion | **`/release`** · **release** skill |
| Agent 自治打版 | **本 agent（ship）** · 跟 release **§打版** |

Config：`config/release.json` · `config/workflow.json`  
Rules：`rules/feedback/changelog.mdc` · `release.mdc` · `tag.mdc`  
命令：**git** skill · 安全：**security** skill

## 禁止

- force-push 默认分支 · 跳 hook（`--no-verify`）· 提交密钥 · 未 verify 打 tag
- 另写与 **release §打版** 冲突的版本/tag 规则

## 流程

逐步执行 **release** skill **§打版** 清单（摘要如下，细节以 skill 正文为准）：

### 1. 前置检查

```bash
./.cursor/bin/runner.sh gate-check    # 可选；无 plan 时跳过
./.cursor/bin/runner.sh verify          # 必须绿
git status                              # 无未提交 WIP
```

- [ ] plan 本版 P0 全部 ✅（若用 plan.md）
- [ ] 跑 **security** 清单（auth/密钥/PII）— 无 Critical/High 未处理
- [ ] UI/功能本版：**建议** **`/delivery`** 无 Blocker（见 **delivery** skill）
- [ ] 发版 benchmark：**可选** **`/report`** full regen（**test-report** · verify 绿后；见 **release** §打版）

### 2. 版本与 CHANGELOG

- 读 `release.json`：`tag_format` · `tag_prefix` · `changelog_file` · `order`（newest_first）
- 确认 `## [Unreleased]` 内容完整、分组正确（Added/Changed/Fixed）
- 将 Unreleased 折叠进 `## [x.y.z] - YYYY-MM-DD`（**新版在上**）
- bump manifest（`package.json` / `pyproject.toml` / `Cargo.toml` 等，按项目）

### 3. 提交

- 一逻辑一 commit：`chore(release): vX.Y.Z` 或团队约定
- message 不含密钥；不 amend 已 push 的 commit（除非用户明确要求）

### 4. Tag

```bash
# patch-per-task（默认）：ship 手动打 tag
git tag -a "<prefix><version>" -m "Release <version>: <one-line summary>"

# tag-per-commit：每 commit 已打 tag 时复核；或批量收尾：
./.cursor/bin/runner.sh release-tag
```

- annotated tag（`release.json` → `annotated_tags`）
- 已存在同名 tag → **停止**，报告需 patch 版本

### 5. Push

- 按团队策略 push commit + tag
- 默认分支 **勿 force-push**
- 完成后输出：版本号 · tag 名 · CHANGELOG 摘要 · 建议的 GitHub Release 文案

## 失败回滚

- verify 失败 → 不修 CHANGELOG/tag，先修代码
- tag 打错未 push → `git tag -d <tag>`（本地）；已 push → 报告需团队策略，**勿擅自 force-push**
