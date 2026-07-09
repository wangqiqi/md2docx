---
name: git
description: Git — 分支、提交、合并。需要 git 操作时用。
---

# git

分支：`feat/*` · `fix/*` · `chore/*` · `docs/*`  
格式：`type(scope): summary`（scope 可选）

## 提交前

- [ ] `git status` — 无 `.env`、密钥、意外大文件；**勿** stage `plan.md`（gitignore）
- [ ] `git diff --stat` — 范围符合当前任务
- [ ] `./.cursor/bin/runner.sh task-verify`（启用 plan/run 时）
- [ ] CHANGELOG `[Unreleased]` 已更新用户可见变更（若有）
- [ ] message 引用 plan 任务 ID（如 `docs(readme): sync v4.10 summary (DOC-001)`）

## /run 自动提交

启用 plan/run 时，**run** skill 要求每任务 ✅ 与 Sprint 收尾 **同轮 commit**；`tag-per-commit` 时同轮 **`release-tag`**。

**`plan.md`** 为本地工作文件（`.gitignore`），commit 只含代码/CHANGELOG/README 等已跟踪文件。

## 分支与合并

- 短生命周期 feature 分支；共享分支默认 **勿 force-push**
- 合并前：本地 verify 绿 · 无 WIP commit
- UI/功能 PR：**建议**先 **`/delivery`**（见 **delivery** skill）；Blocker 须在 PR 描述中说明
- 受保护分支（main/master）须 PR + review（见 `rules/communication/collaboration.mdc`）

## 禁止（除非用户明确）

- `git push --force` 到共享/默认分支
- `git reset --hard` · `git clean -fdx`
- `--no-verify` / `--no-gpg-sign`

## 打版

清单 → **release** skill · 自治 → **ship** agent · tag 规则 → `rules/feedback/tag.mdc`

## Worktree 隔离（可选）

并行 TASK / 功能分支时：

```bash
git worktree add ../repo-feature-<name> -b feat/<name>
# 完成后见 **release** skill §分支 · 选项 1/4 可清理 worktree
git worktree list
git worktree remove <path>   # 须无未提交改动 · 用户确认
```

- 主 worktree 保持可发布基线
- 清理前 verify 绿 · 与 **release** §分支 4 选 1 一致
