# 迁移对照表（旧 cursor-ai-rules → Super Cursor）

> 对照**旧版 cursor-ai-rules** 与 Super Cursor 的能力映射。旧版快照路径由维护者在**本地**只读参考，**勿**写入母版。

## Skills（37 → 精简）

| 旧 skill / 能力 | Super Cursor | 备注 |
|-----------------|--------------|------|
| debug / troubleshoot | **debug** | 核心 |
| test / e2e | **test** | 含 Playwright/E2E |
| mcp | **mcp** | 核心 |
| refactor | **refactor** | 核心 |
| perf | **perf** | 核心 |
| review / code-review | **review** + **review** agent | 只读 |
| study / learn-tech | **study** | ≠ **learn**（项目认知） |
| security | **security** + `security-sdlc.mdc` | audit/依赖 |
| git / commit | **git** | 已有 |
| api | **api** | 已有 |
| plan / run / learn / scaffold / master / release | 同名 | 核心 |
| finish / delivery | **release** · **delivery** | Sprint 出口 · 7 维交付验收 |
| epic / 多 Sprint 编排 | **long** | `/long` · Epic→Sprint→Task · checkpoint |
| user docs / 操作手册 | **user-manual** | `/manual` · Manual Contract |
| QA 报告 / verify 汇总 | **test-report** | `/report` · Report Contract |
| UX / IA / 工具类 | **ux** · **ia** · **week** · **disk** · **maintain** · **ops-deploy** · **code-stats-viz** · **pencil-design** | skill-only（无 slash） |
| spike / POC | **spike** agent + `SPIKE-*` | 只读调研 |
| command-center 等编排 | **master** routes | 无伪 class 引擎 |

## Rules（tech / execution）

| 旧 | 新 |
|----|-----|
| eslint 细则 | `rules/tech/eslint.mdc` |
| 纯 JS | `rules/tech/javascript.mdc` |
| java / python 加深 | `java.mdc` · `python.mdc` |
| next SSR/CWV | `nextjs.mdc` |
| 宪法三公理 | `constitution.mdc` |
| 演进 | `evolution.mdc` |
| C 与 C++ 拆分 | `c.mdc` · `cpp.mdc` |
| vibe / cli-python | `vibe.mdc` · `cli-python.mdc` |

## Agents

| 旧 | 新 | 约束 |
|----|-----|------|
| ship / release | **ship** | 发版 |
| review | **review** | readonly |
| spike | **spike** | readonly |

## 人格（roles）

- 旧 `config/roles/*.json` → 单文件 `config/roles.json`（12 archetype）
- 仅 `attitude/tone/hint`；无 greetings 台词库；全员全能

## 刻意不迁移

- 400 行伪 class 规则引擎 · 多 adjective 人格 · 母版内项目路径
- Web 控制台 · plugins 全量 · 36 hooks · `cursor-master.sh` · command-center agent
- greetings 台词库 · pptx/pdf/docx 等文档生成 skills
- 旧版 37 skills 中未列入上表的项 → 全局 Cursor skills 或项目 `/learn`

## 完整性边界

**Super Cursor 母版「完整」的定义**（自洽检查 `cursor-coherence.sh` 覆盖）：

| 范围 | 标准 |
|------|------|
| 结构 | 28 skills · 3 agents · 54 rules · config/hooks/bin 齐全（无 `commands/`） |
| 注册 | 每个 `rules/**/*.mdc` 在 `verify-super-cursor.sh` 有 check |
| layout | **mother** 纯空仓 · **hybrid** 业务树共存（自动 SKIP 纯母版项）— `rules/feedback/verify.mdc` |
| 交叉引用 | AGENTS ↔ 磁盘 · routes ↔ skills/agents · roles=12 |
| 旧版 parity | **不要求** 1:1 全量迁移；上表「刻意不迁移」为产品边界 |

审计旧版时：对照本表 **已迁移** 列即可；未列项视为 intentional skip，非缺口。

## 分发三轨（install · skills-bundle · Plugin）

与旧版「单一路径装 rules」不同，母版对外有 **三条并行分发轨**（能力矩阵见 `learn/cursor-platform.md` §分发三轨 · SPIKE 归档 `archive/meta/*_SPIKE_plugin_phase2_scope.md`）：

| 轨 | 入口 | skills 规模 | config / hooks | 典型场景 |
|----|------|-------------|----------------|----------|
| **install 全量** | `install-super-cursor.sh`（默认） | **28** | 完整 `.cursor/config/` + `hooks/` | 目标项目 SSOT · `runner.sh` 闸门 |
| **`--skills-bundle core`** | 同上 + `--skills-bundle core` | **23**（`skill-bundles.json`） | 同 install 全量 | 精简工具 skill，**不是** Plugin |
| **`.cursor-plugin/`** | 本地加载 Plugin 子集 | **5** lifecycle + **agents** | **无** 打包 config；hooks 依赖已 install 的 `workflow.json` | 可选叠加；须 **先 install** |

Marketplace 上架：**Defer**（三轨决策见 `*_SPIKE_plugin_phase2_scope.md`）。**未来上架清单**（manifest 扩展 · 提交前门禁）→ `archive/meta/*_SPIKE_marketplace_prep_scope.md` · `bash .cursor/bin/verify-spike-marketplace-prep-scope.sh`。Plugin 与 `core` install **文件树不等价** — 仅文档矩阵对齐。

## Growth meta 归档门禁（`lib/growth-archive.sh`）

语义 SSOT → `skills/plan/reference/growth-meta-ci-dual.md`（`archive/meta` 未引导 → **SKIP**；已引导但缺文件 → **FAIL**）。

| 脚本 | 位置 |
|------|------|
| `verify-spike-docs-sync-scope` | `harness/core/bin` |
| `verify-spike-marketplace-prep-scope` | `harness/core/bin` |
| `verify-spike-tools-skills-archive` | `harness/core/bin` |
| `verify-spike-skills-bundle-scope` | `harness/core/bin` |
| `verify-spike-onekey-bootstrap-scope` | `harness/core/bin` |
| `verify-spike-mother-hygiene-scope` | `harness/core/bin` |
| `verify-cursor-platform-contract` | `adaptors/cursor/bin` |
| `verify-spike-plugin-mvp-scope` | `adaptors/cursor/bin` |
| `verify-spike-plugin-agents-scope` | `adaptors/cursor/bin` |
| `verify-spike-plugin-phase2-scope` | `adaptors/cursor/bin` |

## 母版 verify 索引（`bin/verify-*.sh`）

聚合入口：`bash .cursor/verify-super-cursor.sh`（含接线自检：每个 `bin/verify-*.sh` 须被本脚本或 `template-verify.sh` 调用）。母版 CI：`bash .cursor/template-verify.sh`（先 `harness/link-cursor-ide.sh`）。分区：`verify-harness-layout.sh`（`.cursor/harness/core` + `adaptors`）。

| 组 | 脚本 | 守护 |
|----|------|------|
| **core** | `verify-rules-globs` · `verify-portability` · `verify-config` · `verify-roo-compat` · `verify-secrets` · `verify-scripts-layout` · `verify-docs-layout` · `verify-changelog` · `verify-doc-super-cursor` · `verify-growth-layout` · `verify-harness-layout` · `verify-adaptor-contract` · `verify-mother-root-bin` · `verify-onekey-template` | 规则 glob · 可移植 · schema · 协议字段 · 密钥 · scripts/docs 布局 · CHANGELOG · 门面计数 · harness/adaptors 分区 · **占位 adaptor README + install-map** · **母版根 `bin/super-cursor-sync`** · **project-onekey 模板**（母版根不得有 `onekey_start.sh`） |
| **install** | `verify-skill-bundles-ssot` · `verify-install-skills-bundle` · `verify-install-dsh` · `verify-install-rules-export` · `verify-install-opencode` · `verify-spike-skills-bundle-scope` · `verify-spike-onekey-bootstrap-scope` | `skill-bundles.json` ↔ 磁盘 · install 冒烟 · **`.dsh/`** · **`.kiro/`/`.trae/`** · **`.opencode/`** · onekey SPIKE |
| **docs-sync** | `verify-spike-docs-sync-scope` | project-docs / docs-init SPIKE |
| **plugin** | `verify-cursor-plugin-manifest` · `verify-cursor-plugin-mvp` · `verify-spike-plugin-mvp-scope` · `verify-spike-plugin-agents-scope` · `verify-spike-plugin-phase2-scope` · `verify-spike-marketplace-prep-scope` | `.cursor-plugin/` 子集 · 三轨 · Marketplace prep 归档 |
| **platform** | `verify-cursor-platform-contract` · `verify-spike-tools-skills-archive` | 官方对齐 · tools/skills SPIKE |
| **hygiene** | `verify-spike-mother-hygiene-scope` | 门面漂移审计（`archive/meta/*_SPIKE_mother_hygiene_scope.md`） |
| **E2E** | `consumer-smoke.sh`（经 `template-verify`） | 目标项目：install → 闸门 BLOCK → hook → 全绿 |

语义与 `task-verify` fail-closed → `rules/feedback/verify.mdc` §母版门禁清单。

## 目标项目升级（install 后）

详 playbook → [consumer-refresh.md](consumer-refresh.md)。

| 步 | 动作 |
|----|------|
| 1 | 备份 `.cursor/` → `.growing/archive/pre-super-cursor-YYYYMMDD/`（可选） |
| 2 | `install-super-cursor.sh <目标> --profile full --replace` |
| 3 | 业务 rules → `.growing/rules/local/`（安装脚本会链 `rules/local`） |
| 4 | 验收：skills/agents 与母版 `diff` 空（若用 `--skills-bundle core` 则 skills 为 23）· `rules/local` 有效 · `platform-check.sh` 绿 · 根目录 `onekey_start.sh`（`growth.onekey_bootstrap` 默认开；已有文件不覆盖） |
| （可选） | 持久文档号位：`runner.sh docs-init` · `bash .cursor/bin/verify-docs-layout.sh`（契约见 `config/docs-layout.json`） |

**勿**用母版 `cursor-coherence.sh` 全绿要求目标项目根 README（门面检查仅母版仓库）。

## IDE adaptor 布局（Harness 多 IDE）

旧版无等价物；Super Cursor 用 **`adaptors/<id>/`** + `install-map.example.json` 描述非 Cursor 安装根。

| adaptor | 安装根 | 厚度 | layout SSOT |
|---------|--------|------|-------------|
| dsh | `.dsh/` | `includes: core` | [adaptors/dsh/docs/layout.md](../../adaptors/dsh/docs/layout.md) |
| opencode | `.opencode/` | `includes: core` | [adaptors/opencode/docs/layout.md](../../adaptors/opencode/docs/layout.md) |
| kiro | `.kiro/` | `core_rules_export` | [adaptors/kiro/docs/layout.md](../../adaptors/kiro/docs/layout.md) |
| trae | `.trae/` | `core_rules_export` | [adaptors/trae/docs/layout.md](../../adaptors/trae/docs/layout.md) |

机器门禁：`bash .cursor/bin/verify-adaptor-contract.sh` · 矩阵 → [harness-ide-matrix.md](reference/harness-ide-matrix.md)。

## 2026 官方面（Cursor IDE 配置）

| 官方能力 | 母版策略 | 落点 |
|----------|----------|------|
| Rules / Skills 2.4+ | 已对齐；slash **仅 skill**（`commands/` 已退役） | `skills/` · `training/skills.md` |
| Hooks + Cloud | Repo command hooks；Cloud 不跑用户 `~/.cursor/hooks` | `hooks.json` · `platforms.md` |
| MCP · Cloud env · Bugbot | **可选模板**，不默认 install | `templates/growing/`（TASK-002/003） |
| Plugins Marketplace | **install 主路径**；Plugin 为可选第三轨（**Defer 上架** · 三轨 `*_SPIKE_plugin_phase2_scope.md` · 清单 `*_SPIKE_marketplace_prep_scope.md`） | `learn/cursor-platform.md` · `cursor-cloud.md` §Marketplace · `.cursor-plugin/README.md` |
| Automations | 用户全局 `/automate`；母版不嵌密钥 | `cursor-platform.md` |
| 嵌套 `AGENTS.md` · skill `paths` | 大仓消费方指南 | `.growing/learn/cursor-platform.md` |

详矩阵 → `archive/meta/*_SPIKE_cursor_official_align.md` · 维护摘要 → `learn/cursor-platform.md`（install 后路径相同）。
