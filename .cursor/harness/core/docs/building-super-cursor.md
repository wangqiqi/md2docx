# Building on Super Cursor

## Principles

1. **Universal only** — rules/skills must work in any repo; no hardcoded org paths. Guarded by `config/denylist.txt` + `verify-super-cursor.sh`（作者标识 / 机器路径 / 公司代号 / 凭据，逐行 ERE 扫全树）。
2. **Config over fork** — behavior toggles live in `.cursor/config/*.json`；新增/改键须同步 `config/schema.json`（`verify-config.sh` 校验，未知键即 FAIL）。
3. **Three pillars** — `rules/communication/` · `rules/execution/` · `rules/feedback/`.
4. **Growth boundary** — project learnings in `.growing/` only; use `/learn`（见下节「产出 ≠ 母版引用」）。
5. **Token** — `alwaysApply: true` 只有 **4** 个文件（`core.mdc` · `workflow.mdc` · `communication/cursor-standalone.mdc` · `communication/super-cursor-persona.mdc`）；其余按 glob/描述触发，细则在 skills。改这里要知会 README/AGENTS.md 的常驻数量说明。
6. **Immutable after install（仅目标项目）** — 母版仓库可自由演进 `.cursor/`；安装到目标项目后 Agent 不得改 `.cursor/**` 除非用户明确授权（见 **cursor-standalone**）。
7. **Cross-platform** — scripts target Linux · macOS · Git Bash; shared helpers in `.cursor/lib/platform.sh`；静态守护 `verify-portability.sh`（GNU-only · 非 POSIX `\s` · 硬编码 `python3` · shebang · **reserved bash names** · **xargs -I{}**）。**技能**的平台作用域另记于 `docs/platforms.md` §技能平台作用域；Shell 数组命名见 §Shell 命名与 verify 并行。

不确定从哪开始 → **`/master`**（AskQuestion 路由；无该工具时正文编号选项，见 master「AskQuestion 约定」）。

## 母版仓 · harness 分区

**SSOT**：`.cursor/harness/core/` + `.cursor/adaptors/`。根下 `skills/` · `rules/` · `hooks/` 等为 **`link-cursor-ide.sh` 相对 symlink**（整包 `.cursor/` 可拷贝）。验收入口：**`bash .cursor/template-verify.sh`**。

**非 Cursor adaptor 布局**（安装脚本已落地；官方目录多 **待确认**）：

| id | layout 文档 |
|----|-------------|
| dsh | [adaptors/dsh/docs/layout.md](../../adaptors/dsh/docs/layout.md) |
| kiro | [adaptors/kiro/docs/layout.md](../../adaptors/kiro/docs/layout.md) |
| trae | [adaptors/trae/docs/layout.md](../../adaptors/trae/docs/layout.md) |
| opencode | [adaptors/opencode/docs/layout.md](../../adaptors/opencode/docs/layout.md) |

对照表 → [harness-ide-matrix.md](reference/harness-ide-matrix.md) · 契约 → [adaptor-contract.md](reference/adaptor-contract.md)。

## Growth：产出 ≠ 母版引用

| | `.cursor/`（母版） | `.growing/`（产出） |
|--|-------------------|-------------------------|
| 进 git | ✅ | ❌ gitignore |
| 角色 | 通用 SOP · 路径**约定** | 本项目 plan · learn · archive · session |
| 母版文档 | 可写「写入 `learn/`」「Sprint 笔记进 `archive/`」 | **不得**在母版链 `archive/SPRINT-xxx.md` 等具体文件名 |
| 可移植记录 | 仓库根发版文件（`release.json` → `changelog_file`；**release** 维护） | archive 仅本地；`/learn` 可读 archive **吸收** |

**用这个**：config/hooks 约定 Growth 目录；Agent 运行时按需读 `learn/`。**不是那个**：把 Growth 档案写进母版 skills 当引用源。

## Cursor ignore

- **`.cursorignore`**（仓库根）— Agent / Tab / `@` **硬排除**；安装脚本与 scaffold apply 会写入/合并（含 `node_modules/` · `.venv/` · `target/` 等）
- **`.gitignore`** — 主要管 git 与索引；**不能**替代 `.cursorignore` 拦 Agent 读 `.env`
- **`.growing/learn/`** — **不要** ignore；`logs/` · `perception/` 可 ignore

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
.cursor/rules/local/     # symlink → .growing/rules/local/
```

Never commit company-specific paths into the **template** repository.

### Mother repo dev bootstrap

母版仓库 `.cursor/rules/local` 为符号链接，目标在 **gitignore** 的 `.growing/rules/local/`。首次 clone 或链接悬空时：

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
bash .cursor/template-verify.sh   # 母版全量（CI 入口）
bash .cursor/bin/consumer-smoke.sh    # 目标项目端到端（install → 闸门 → hook → 全绿）
bash .cursor/verify-super-cursor.sh   # layout + 聚合门禁；混合仓自动 hybrid
bash .cursor/bin/cursor-coherence.sh  # skills/agents/rules 注册
```

### 贡献者门禁清单（改什么 → 必须绿什么）

| 你改了 | 必须绿 | 额外同步 |
|--------|--------|----------|
| 新增/改 rule | `verify-rules-globs.sh`（frontmatter/键/glob 命中）· `verify-roo-compat.sh` | `docs/rules-catalog.md` · `AGENTS.md` execution 行 |
| 新增/改 skill | `verify-doc-super-cursor.sh`（`description ≤85` · dmi 分桶 · run/plan 体积）· `cursor-coherence.sh` | README skill 名单 · `AGENTS.md` · `docs/training/skills.md` |
| 改 `config/*.json` | `verify-config.sh`（先改 `config/schema.json`） | `config/README.md` 键表 |
| 加/改 shell 脚本 | `verify-portability.sh`（GNU-only · `python3` · shebang） | `bin/` 清单（`.cursor/README.md` · 根 README） |
| 新增 `bin/verify-*.sh` | **接线自检**（必须被聚合调用）+ 至少 1 个负向测试 | `rules/feedback/verify.mdc` §母版门禁清单 · 根 README §验证 |
| 新增对外文档 | `npm run docs:build` → `docs/scripts/vitepress-build.sh`（dead link 非零退出）· `verify-doc-super-cursor.sh` | `docs/scripts/sync-cursor-docs.sh` + `.vitepress/config.ts` 侧栏 |
| 动安装/门面 | `install-smoke.sh` · `consumer-smoke.sh` | CHANGELOG `[Unreleased]` |
| **onekey bootstrap**（根 `onekey_start.sh` · SSOT `templates/project-onekey` · `growth.onekey_bootstrap`） | `verify-onekey-template.sh` · `verify-spike-onekey-bootstrap-scope.sh` · `install-smoke` · `consumer-smoke` · `scaffold-integrity.sh` · `verify-cursor-plugin-mvp` | `config/README.md` · `scaffold.md` · `_shared/scripts/README.md` · `migration-catalog` §verify 索引 · 根 README §验证 |
| 改 `docs-layout` / `templates/project-docs` | `verify-docs-layout.sh` · `verify-config.sh` | `plan-conventions.md` learn 模板 · `templates/project-docs/README.md` |
| Plugin 分发 / 三轨文档 | `verify-doc-super-cursor.sh` · `verify-spike-plugin-phase2-scope.sh` | `cursor-cloud.md` · `cursor-platform.md` learn · `.cursor-plugin/README.md` |
| Marketplace prep（**Defer 上架** · 清单文档） | `verify-spike-marketplace-prep-scope.sh` · `verify-doc-super-cursor.sh` | Growth `archive/meta/*_SPIKE_marketplace_prep_scope.md` · §Marketplace 链（learn · cloud · catalog · plugin README） · `verify-super-cursor` 接线 |
| 母版 `rules/feedback` → Plugin 子集 | `bash .cursor/bin/sync-plugin-subset.sh` · `verify-cursor-plugin-mvp.sh`（`verify.mdc` 与母版 diff parity） | `.cursor-plugin/rules/` · `plugin.json` 版本 · `.cursor-plugin/README.md` |
| 门面 / verify 索引（README · catalog） | `verify-doc-super-cursor.sh` · `verify-spike-mother-hygiene-scope.sh` | `migration-catalog.md` §母版 verify 索引 · `rules/feedback/verify.mdc` §母版门禁清单 · 根 README §验证 |

目标项目铺文档骨架：`bash .cursor/bin/runner.sh docs-init [--profile web-fullstack]` → `docs/NN_*.md`；门禁 `verify-docs-layout.sh`（母版无编号 `docs/` 时验模板）。

细则 → `rules/execution/doc-hygiene.mdc` §门面计数。

**Layout 模式**（`verify-super-cursor.sh`）：**mother** = 含 `install-super-cursor.sh` 的母版仓；**hybrid** = `.cursor/` 与业务树共存（自动检测 `scripts/` · `backend/` · `frontend/`）；两者皆非 = 已安装的目标项目（母版专属项自动 SKIP，通用门禁照跑）。见 `rules/feedback/verify.mdc`。

**Growth meta 双轨**：git 内 SSOT vs `.growing/archive/meta/` 私有 SPIKE 证据 · `sc_growth_archive_available` SKIP/FAIL → `skills/plan/reference/growth-meta-ci-dual.md`。
