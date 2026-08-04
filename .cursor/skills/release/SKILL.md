---
name: release
description: >-
  Sprint 出口（/release）：分支 merge/PR/保留/丢弃 4 选 1 · semver · CHANGELOG · tag。
  说「收尾」「merge」「开 PR」「发版」「打 tag」「分支怎么办」时用。自治发版→ship agent。
disable-model-invocation: true
---

# release · Sprint 出口

**用这个**：`/release` 人主导（分支 4 选 1 + 可选打版清单）。**不是那个**：自治执行打版步骤 → 委派 **ship**（同一 §打版 SSOT，无第二套流程）。

Sprint/Task 代码已绿、**run** 归档后：**先汇入主轨，再打版**。不替代日常 **git** commit 纪律。

```bash
./.cursor/bin/runner.sh task-verify   # 或 verify（Sprint 收尾）
git status && git diff --stat
```

`config/release.json` · `config/workflow.json` · tag 规则见 `rules/feedback/tag.mdc`

## 分支收尾（merge / PR）

### 前置

- [ ] 当前 ACTIVE 或 Sprint P0 已 ✅（或用户明确只做分支收尾）
- [ ] 验收命令已实际执行
- [ ] 无意外脏文件 · 无密钥
- [ ] **UI/功能 Sprint**：**建议**先 **`/delivery`**；有 **Blocker** 须在 AskQuestion 前报告

### 流程

**Verify** → **（建议）delivery** → **AskQuestion（4 选 1；不可用 → 正文编号，见 master「AskQuestion 约定」）** → **执行** → 可选 **worktree 清理**（见 **git** skill）

| # | 选项 | 动作 |
|---|------|------|
| 1 | 本地 merge | checkout 基线分支 · merge feature · 跑 verify · 删本地 feature（用户确认后） |
| 2 | Push + PR | `git push -u origin HEAD` · `gh pr create`（Summary + Test plan · 含 TASK ID） |
| 3 | 保留分支 | 仅 push 或保持现状；不 merge、不删 worktree |
| 4 | 丢弃 | **须用户明确打字确认**；禁止静默 force/reset |

Detached HEAD / 无名分支：仅呈现选项 2–4。

PR 生命周期（评论、CI、拆 PR）：`babysit` · `split-to-prs`（**master** → `more` → `git`）。

### 与 run 分工

| 时机 | run | release §分支 |
|------|-----|----------------|
| 单 TASK ✅ · 更新 plan | ✅ | |
| Sprint 全 ✅ · archive | ✅ | 可选接着 **§分支** |
| merge / PR / 丢弃 | | ✅ |

### 禁止

- 共享/默认分支 `push --force`（除非用户明确）
- `reset --hard` · `clean -fdx` 无确认
- 跳过 verify 直接 merge

---

## 打版（semver · tag）

主轨已绿、需对外版本时执行本节。**分支收尾**与**打 tag** 可同一次 `/release` 会话，但须先完成 verify。

### 发版模式（`workflow.release.mode`）

| mode | 适用 | /run 收尾 |
|------|------|-----------|
| `patch-per-task`（母版默认） | 开源母版 · Sprint 批量交付 | commit；Sprint 末 **ship** 打 tag |
| `tag-per-commit` | 高频交付业务仓库 | commit + **`release-tag`** 每任务 |

### semver 原则

| 级别 | 何时用 | 自动？ |
|------|--------|--------|
| **patch** | 单 TASK、文档/修复、tag-per-commit 默认 | tag-per-commit：**是** |
| **minor** | 用户可见新能力、无 breaking | **否** — 须 `RELEASE_ALLOW_MINOR=true` |
| **major** | Breaking change | **几乎从不自动** |

### Follow-up 发版与 patch 密度

- **同一症状簇** 连续多个 patch：CHANGELOG 须能 grep 到 **根因 Sprint ID**；**`/learn`** 审计 `changelog-insights` §重复模式
- **建议**：短期 follow-up 合并为 **一次 minor** 或 **weekly tag**，避免 4 日 N patch（见 `learn/release-rhythm.md`）
- **打版前**：若本版仅 follow-up UX，**建议** **`/delivery`** §8（长任务闭环）无 Blocker
- `workflow.followup_gate` — 见 `config/workflow.json`（软闸门，plan §Follow-up 引用）

### patch-per-task 清单

- [ ] `./.cursor/bin/runner.sh release-check` — 确认 `latest_tag` · `next_version`（见下节）
- [ ] 版本已定 · plan 本版 ✅（若用）
- [ ] verify 通过 · 无 WIP
- [ ] **security**（auth/PII）
- [ ] UI/功能：**建议** **`/delivery`** 无 Blocker
- [ ] 发版 benchmark：**可选** **`/report`** full regen（**test-report** · verify 绿后）
- [ ] CHANGELOG `[Unreleased]` · manifest bump · docs
- [ ] Annotated tag · push 按团队策略

### 多架构打包（可选 · 桌面 / 原生产物）

纯 Web / 无原生安装包时跳过。有安装包或二进制分发时：

- [ ] **架构矩阵显式** — 目标 OS × CPU（如 x64 / arm64）写在 docs 或 CI，非隐式「本机 arch」
- [ ] **构建脚本 / CI job** 覆盖矩阵中每一格（或文档标明刻意不做的格）
- [ ] 原生依赖（若有）在矩阵内可解析、可复现
- [ ] 发版说明或 CHANGELOG 注明支持的平台组合

### 版本解析（打 tag 前必读）

`release-tag` / `next_version` 在**最新 git tag** 上 bump，解析顺序：

| 优先级 | 来源 | tag 匹配 |
|--------|------|----------|
| 1 | 环境变量 `VERSION_TAG_GLOB`（`workflow.json` → `version_tag_glob_env`） | 自定义 glob |
| 2 | plan `<!-- VERSION_LINE: major.minor -->` | `v{line}.*`（例 `4.22` → `v4.22.*`） |
| 3 | **（缺省）** | `v*` — **仓库最新 semver tag** |

无匹配 tag 时起始版本：plan `VERSION_DEFAULT` · 环境变量 `RELEASE_VERSION_DEFAULT` · `0.1.0`（有 `VERSION_LINE` 时为 `{line}.0`）。

```bash
./.cursor/bin/runner.sh release-check
# ready · latest_tag=v4.22.1 · tag_glob=v* · next_version=4.22.2 · tag=v4.22.2
```

**打版前**：核对 `latest_tag` 与 CHANGELOG 上一版一致；`next_version` 异常时不要打 tag。

### 命令

```bash
./.cursor/bin/runner.sh release-check
./.cursor/bin/runner.sh release-tag          # tag-per-commit 默认 patch
RELEASE_BUMP=minor RELEASE_ALLOW_MINOR=true ./.cursor/bin/runner.sh release-tag
```

自治打版（Agent 按序执行清单）→ **ship** agent（**执行本节**；入口指针见 `agents/ship.md`）· 清单以本节 + `rules/feedback/release.mdc` 为准。
