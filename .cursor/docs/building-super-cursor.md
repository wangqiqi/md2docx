# Building on Super Cursor

## Principles

1. **Universal only** — rules/skills must work in any repo; no hardcoded org paths.
2. **Config over fork** — behavior toggles live in `.cursor/config/*.json`.
3. **Three pillars** — `rules/communication/` · `rules/execution/` · `rules/feedback/`.
4. **Growth boundary** — project learnings in `.cursorGrowth/` only; use `/learn`（见下节「产出 ≠ 母版引用」）。
5. **Token** — 仅 `core.mdc` + `workflow.mdc` alwaysApply；细则在 skills。
6. **Immutable after install（仅目标项目）** — 母版仓库可自由演进 `.cursor/`；安装到目标项目后 Agent 不得改 `.cursor/**` 除非用户明确授权（见 **cursor-standalone**）。
7. **Cross-platform** — scripts target Linux · macOS · Git Bash; shared helpers in `.cursor/lib/platform.sh` (see `docs/platforms.md`).

不确定从哪开始 → **`/master`**（AskQuestion 路由；无该工具时正文编号选项，见 master「AskQuestion 约定」）。

## Growth：产出 ≠ 母版引用

| | `.cursor/`（母版） | `.cursorGrowth/`（产出） |
|--|-------------------|-------------------------|
| 进 git | ✅ | ❌ gitignore |
| 角色 | 通用 SOP · 路径**约定** | 本项目 plan · learn · archive · session |
| 母版文档 | 可写「写入 `learn/`」「Sprint 笔记进 `archive/`」 | **不得**在母版链 `archive/SPRINT-xxx.md` 等具体文件名 |
| 可移植记录 | 仓库根发版文件（`release.json` → `changelog_file`；**release** 维护） | archive 仅本地；`/learn` 可读 archive **吸收** |

**用这个**：config/hooks 约定 Growth 目录；Agent 运行时按需读 `learn/`。**不是那个**：把 Growth 档案写进母版 skills 当引用源。

## Cursor ignore

- **`.cursorignore`**（仓库根）— Agent / Tab / `@` **硬排除**；安装脚本与 scaffold apply 会写入/合并（含 `node_modules/` · `.venv/` · `target/` 等）
- **`.gitignore`** — 主要管 git 与索引；**不能**替代 `.cursorignore` 拦 Agent 读 `.env`
- **`.cursorGrowth/learn/`** — **不要** ignore；`logs/` · `perception/` 可 ignore

## Add a rule

Create `.cursor/rules/<topic>.mdc`:

```yaml
---
description: One-line purpose
globs: "**/*.ts"   # optional
alwaysApply: false
---
```

Use meta-skills from `~/.cursor/skills-cursor/create-rule/` when authoring.

## Add a skill

Create `.cursor/skills/<name>/SKILL.md` with `name` + `description`.

## Local overrides (target project only)

After install, a project may add:

```
.cursor/rules/local/     # symlink → .cursorGrowth/rules/local/
```

Never commit company-specific paths into the **template** repository.

### Mother repo dev bootstrap

母版仓库 `.cursor/rules/local` 为符号链接，目标在 **gitignore** 的 `.cursorGrowth/rules/local/`。首次 clone 或链接悬空时：

```bash
bash .cursor/bin/bootstrap-growth.sh
```

`template-verify.sh` 会在验收前自动调用。仅补全 `rules/local/README.md` 与 learn 种子，不覆盖已有 `plan.md`。

## Install

```bash
./install-super-cursor.sh /path/to/project
```

## Workflow modes

Edit `config/workflow.json` after install:

| Mode | Setting |
|------|---------|
| Full plan/run + hooks | defaults |
| Rules/skills only | `workflow.enabled: false`, `hooks_enabled: false` |
| Stack-specific verify hints | 默认已 `enabled: true`，对齐 `scripts/test.sh` |

See `config/README.md` for all keys. Copy `templates/plan.md` when using the plan workflow.

## Closed-loop checklist

| Step | Entry |
|------|--------|
| Plan | `/plan` · Done when 可含 `delivery 无 Blocker` |
| Implement | `/run` · `task-verify` |
| Product gate | `/delivery` · **release** §分支前建议 |
| Branch / tag | `/release` · **git** |
| Release | **release** / **ship** · verify + security + delivery |

Verify template integrity:

```bash
bash .cursor/bin/cursor-coherence.sh
bash .cursor/verify-super-cursor.sh   # layout；混合仓自动 hybrid
bash .cursor/bin/template-verify.sh   # 母版全量（含 scaffold · runner smoke）
```

**Layout 模式**（`verify-super-cursor.sh`）：**mother** = 纯母版空仓；**hybrid** = `.cursor/` 与业务树共存（自动检测 `scripts/` · `backend/` · `frontend/`）。混合仓不 FAIL 纯母版项；见 `rules/feedback/verify.mdc`。
