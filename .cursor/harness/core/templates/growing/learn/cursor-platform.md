# Cursor 平台对齐（消费方 / 母版维护）

> 差距全表 → `.growing/archive/meta/*_SPIKE_cursor_official_align.md`（母版仓）· 官方主题索引 → `.cursor/docs/library-index.md` §Cursor 官方平台。

## 已采纳（维持）

| 面 | 做法 |
|----|------|
| Rules | `.cursor/rules/*.mdc` + 根 `AGENTS.md`；Bugbot 规则**不进** `.mdc` |
| Skills | `.cursor/skills/<name>/SKILL.md`；生命周期类 `disable-model-invocation: true` → 仅显式 `/skill` |
| Hooks | `.cursor/hooks.json` + `.cursor/hooks/*.sh`（项目根相对路径） |
| Subagents | `.cursor/agents/*.md`（review · ship · spike） |
| 闸门 | `runner.sh gate-check` · `.growing/plan.md` 元数据 |

## 本 Sprint 变更中

| 项 | 状态 |
|----|------|
| slash | **仅 skill**（`commands/` 已删除）· 生命周期类 `disable-model-invocation: true` |
| MCP / Cloud / Bugbot 模板 | `templates/growing/` 可选复制，不随 install 默认注入 |
| Bugbot 启用 | 复制 `BUGBOT.md` → `.cursor/BUGBOT.md`，`config/bugbot.yaml.example` → `.cursor/config/bugbot.yaml`（见 `templates/growing/README.md`） |
| MCP / Cloud | `mcp.json.example` → `.cursor/mcp.json`；`environment.json.example` → `.cursor/environment.json`（仅 install；Docker → `environment.docker.json.example`，见 `cursor-cloud.md`） |

## Monorepo 消费方

- 子包可加嵌套 `AGENTS.md` 与 `.cursor/skills/`（官方支持目录级发现）。
- 文件级 skill 优先用 frontmatter **`paths`**（优于仅 rules 的 `globs`）。
- Cloud Agents：提交 repo hooks + 可选 `.cursor/environment.json`；密钥走 Dashboard，不进 git。

## 分发

| 方式 | 何时用 |
|------|--------|
| **`install-super-cursor.sh`** + profile | **默认 / 主路径** — 全量 `.cursor/` + Growth 引导 · `runner.sh` · `verify-super-cursor` |
| **Cursor Plugin**（`.cursor-plugin/`） | **MVP 已入库** — lifecycle 子集本地加载；**不**替代 install（见 §Plugin MVP） |
| **Agent Plugin**（根 `plugin.json`） | 仅外发 skills+MCP 子集 |

决策归档 → `.growing/archive/meta/*_plugin_distribution_decision.md` · 子集矩阵 → `*_SPIKE_plugin_mvp_scope.md`。

## Plugin MVP

| 项 | 说明 |
|----|------|
| 目录 | 仓库根 **`.cursor-plugin/`**（`plugin.json` · `super-cursor-mvp`） |
| 含 | 5 lifecycle skills · **agents**（ship · review · spike）· 11 核心 rules · 最小 hooks（**无** `commands/` · **无** `config/`） |
| 同步 | 母版改 `.cursor/` 子集后：`bash .cursor/bin/sync-plugin-subset.sh` |
| 验收 | `bash .cursor/bin/verify-cursor-plugin-manifest.sh` · `bash .cursor/bin/verify-cursor-plugin-mvp.sh` |
| 边界 | **install 仍 SSOT** — Plugin 不提供 `gate-check` / 全量 verify / 28 skills；hooks 脚本依赖 `config/` 时须已 install 或手拷 |

## 分发三轨（install · plugin · skills-bundle）

| 轨 | 典型 skills | `config/` | 用途 |
|----|-------------|-----------|------|
| **install full**（默认） | 28 | ✅ | 母版 SSOT · `runner.sh` · 全量 verify |
| **install `--skills-bundle core`** | 23 | ✅ | 去掉五工具 skill；**仍**全量 rules/agents/hooks |
| **`.cursor-plugin/`** | 5 lifecycle + agents | ❌（须目标已 install） | 本地 Plugin；`sync-plugin-subset.sh` |

`core`（23）与 Plugin（5）**不可互换**；详见 `archive/meta/*_SPIKE_plugin_phase2_scope.md`。

## Hooks 与 config（Plugin）

Plugin 携带 `hooks/run-start.sh` 等，但 **`hooks/lib/config-load.sh` 读取 `.cursor/config/workflow.json`**。仅加载 Plugin、未 install → plan 闸门与 profile 合并**不**成立。推荐顺序：**先 `install-super-cursor.sh`，再启用 Plugin**。

## Skills bundle（install）

| 项 | 说明 |
|----|------|
| 默认 | `--skills-bundle full`（28 skills，与历史行为一致） |
| **core** | 23 skills；排除五工具 skill（见 `config/skill-bundles.json`） |
| 与 profile | **独立** — `lite`/`rules-only` 仍只改 workflow，不 silent 改 bundle |
| 验收 | `bash .cursor/bin/verify-install-skills-bundle.sh` |
| 与 Plugin | **无自动对齐** — `skill-bundles.json` 管 install；Plugin 子集见 §Plugin MVP |

Cloud / MCP 可选面 → `.cursor/docs/cursor-cloud.md`（含 Plugin 与 install 分流一句）。

## Marketplace

**Defer 实际上架** — 本仓仅仓库根 `.cursor-plugin/` **本地加载**；**不**替代 `install-super-cursor.sh`。

| 文档 | 内容 |
|------|------|
| 三轨 vs Marketplace | `archive/meta/*_SPIKE_plugin_phase2_scope.md` |
| **未来上架清单**（manifest 扩展 · 提交前门禁） | `archive/meta/*_SPIKE_marketplace_prep_scope.md` |

母版维护者提交前：`bash .cursor/bin/sync-plugin-subset.sh` → `verify-cursor-plugin-manifest.sh` → `verify-cursor-plugin-mvp.sh`。归档回归：`bash .cursor/bin/verify-spike-marketplace-prep-scope.sh`。
