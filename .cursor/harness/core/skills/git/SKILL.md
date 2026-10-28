---
name: git
description: Git — 分支、提交、合并。需要 git 操作时用。
---

# git

分支：`feat/*` · `fix/*` · `chore/*` · `docs/*`  
格式：`type(scope): summary`（scope 可选）

## Conventional Commits（吸收自 awesome-cursorrules-zh）

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

| type | 用途 | SemVer |
|------|------|--------|
| `feat` | 新功能 | MINOR |
| `fix` | 缺陷修复 | PATCH |
| `docs` · `style` · `refactor` · `perf` · `test` · `build` · `ci` · `chore` | 非功能面变更 | 通常无版本跃迁 |
| `BREAKING CHANGE:` 页脚或 `type!:` | 破坏性 API/行为变更 | MAJOR |

- 一提交一逻辑变更；正文解释 **why**，不只 what
- scope 为受影响模块名（如 `feat(api): …`）

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

## GitHub 运维（`github-ops` · `gh` 有则用）

**用这个**：超出本地 `git` 的仓库运维（issue · PR · CI · release）。**不是那个**：日常 commit/push → 上节；打版清单 → **release** skill。

吸收自 SkillsMP `github-ops`（协议 only；`command -v gh` 不可用则口述步骤或跳过）。

| 场景 | 典型 `gh` 动作 | 注意 |
|------|----------------|------|
| **Issue triage** | `gh issue list` · `gh issue view` · `gh issue edit` 标签/指派 | 先读描述与关联 PR；勿批量关未复现 issue |
| **Stale 清理** | `gh issue list --search 'is:open sort:updated-asc'` · 评论后 close | 须团队政策；默认 **不**自动 close |
| **PR 状态** | `gh pr checks` · `gh pr view` · `gh run list` / `gh run view` | CI 红先读 log，再改代码 |
| **Release** | `gh release list` · `gh release create`（用户确认后） | 与 **release** skill · CHANGELOG 对齐；勿跳过 verify |

**纪律**：运维命令不写进母版必选路径；MCP `gh` 工具可用时等价遵循上表意图。

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
