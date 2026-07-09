# master · 路由表

AskQuestion 选项与关键词 → 下游 skill / agent / rules。  
与 `.cursor/README.md` **场景速查** 对齐；详表在本文件，README 为摘要链。

## 主路由（第 1 轮 · ≤7 项）

| 选项 id | 意图 | 入口 | 关键词（中英） |
|---------|------|------|----------------|
| `scaffold` | 新建 / 空项目 | **scaffold** `/scaffold` | 脚手架、初始化、空仓库、new project、bootstrap |
| `plan` | 规划 / Sprint / 调研 / 文档 | **plan** `/plan` | 规划、需求、Sprint、SPIKE、DOC、归档 |
| `run` | 继续开发 | **run** `/run` | 继续、做任务、ACTIVE、next task |
| `learn` | 了解项目 | **learn** `/learn` | 了解项目、约定、onboarding、术语 |
| `fix` | bug / 验收 / 闸门 | bugfix · **run**/**plan** | bug、hotfix、verify 失败、gate-check、卡住 |
| `ship` | 发版 | **release** · **ship** | 打版、发版、CHANGELOG、tag、release |
| `more` | 审查 / 文档 / 依赖 / 配置 | 见下表 | commit、PR、security、api、submodule、config |

## `more` 子路由（第 2 轮 · ≤7 项）

| 子 id | 意图 | 入口 | rules / 命令 |
|-------|------|------|----------------|
| `git` | Git / PR / Review / 收尾 | **git** · **release** · **review** · `babysit` · `split-to-prs` | `commit.mdc` · collaboration |
| `pr` | PR 描述 / Review / babysit | **git** · **review** · `babysit` | collaboration |
| `security` | 安全审查 | **security** | — |
| `api` | API 设计 | **api** | `rules/execution/api.mdc` |
| `delivery` | 交付验收 / 上线前 | **delivery** | `rules/execution/delivery.mdc` |
| `ux` | UX / 体验不好 / 界面乱（未明 IA/交付） | **ux** | `rules/execution/ux.mdc` → **ia** / **delivery** |
| `ia` | 信息架构 / 导航迷路 / 角色首页 | **ia** | `rules/execution/ia.mdc` · `docs/design/*-ia*` |
| `docs` | 文档同步 | **plan** `DOC-*` 或直述 | `rules/execution/docs.mdc` |
| `deps` | 依赖 / submodule | 直述 + 规范 | `rules/execution/submodule.mdc` |
| `config` | verify / 本地 rules / 母版自测 | 见 [扩展场景](#扩展场景) | `config/workflow.json` |
| `style` | 人格 / 沟通语气 | `config/roles.json` | 见 [人格预设](#人格预设-style) |

## 人格预设 (`style`)

> 仅改语气，**全能**；默认 `professional`。12 项分两轮 AskQuestion（每轮 ≤7）。

**轮 1 · 日常/硬核**：`professional` · `zhiyin` · `tough_guy` · `strict` · `old_master` · `dashu` · `pretty_boy`

**轮 2 · 个性**：`loli` · `maid` · `tsundere` · `seductive` · `queen`

## 扩展 skill 路由

| 关键词 | 入口 |
|--------|------|
| 调试、隔离、根因 | **debug** |
| 测试、E2E、Playwright | **test** |
| MCP、工具服务器 | **mcp** |
| 重构 | **refactor** |
| UX、体验、不好用、界面乱 | **ux** |
| 信息架构、导航、迷路、Dashboard、角色入口、工作流分支 | **ia** |
| 性能、慢、瓶颈 | **perf** |
| 代码回顾、REV | **review** · **review** agent |
| 学新技术、study | **study** |
| 调研只读、SPIKE | **spike** agent · **plan** `SPIKE-*` |
| 周报、本周总结、weekly report | **week** · `/week` |
| 磁盘快照、空间变动、disk snapshot | **disk** · `/disk` |
| 环境维护、清理缓存、系统维护 | **maintain** · `/maintain` |
| 分支收尾、merge、开 PR、打 tag | **release** · **git** |
| PR 评论、CI 循环 | `babysit`（`more` → `git`） |
| 拆 PR、大 diff | `split-to-prs`（`more` → `git`） |

## 扩展场景

README 场景速查中无独立主菜单、经 `more` → `config` 或关键词命中：

| 我想… | 路由 |
|-------|------|
| 配置或排查 verify | `config/workflow.json` · `./.cursor/bin/runner.sh verify` · `rules/feedback/verify.mdc` |
| 加项目私有 rules | `.cursor/rules/local/`（目标项目自建，不 commit 进母版） |
| 验证 Super Cursor 母版完整性 | `bash .cursor/verify-super-cursor.sh` 或 `bash .cursor/bin/template-verify.sh` |
| 自治批量跑 TASK | **plan** 设 `AUTONOMOUS:true` → **run** |
| 仅要规范不要闸门 | `workflow.json` → `workflow.enabled: false`（`rules-only` profile） |
| 技术栈开发细则 | **run**/**plan** 执行时自动加载 `rules/tech/*` glob |

## 关键词索引

自由描述时 grep 本表：

| 关键词 | 路由 |
|--------|------|
| help、从哪开始、不知道、怎么用 | **master**（已在 master 内则继续子问） |
| 脚手架、空仓库、初始化 | **scaffold** |
| 规划、Sprint、拆任务、TASK | **plan** |
| 调研、POC、可行性、SPIKE | **plan** · `SPIKE-*` |
| 只写文档、README、DOC | **plan** · `DOC-*` · `docs.mdc` |
| 归档、ROADMAP、Sprint 做完 | **plan** · `archive/` |
| 继续、实现、ACTIVE | **run** |
| 了解项目、learn、模块地图 | **learn** |
| bug、hotfix、线上、报错 | **fix** → bugfix |
| 验收失败、verify 红、task-verify | **fix** → verify.mdc · **run**/**plan** |
| gate-check、PLAN_APPROVED、被挡 | **fix** → **plan** |
| 发版、CHANGELOG、tag | **ship** → release / ship |
| commit、push、分支 | **more** → **git** |
| PR、Review、合并请求 | **more** → **git** · **review** · **release** · `babysit` |
| 分支收尾、merge、发版 | **release** · **git** |
| 拆 PR、split | `split-to-prs` · **more** → **git** |
| 密钥、PII、鉴权、安全 | **more** → **security** |
| REST、OpenAPI、接口 | **more** → **api** |
| 交付验收、上线前、生产就绪、i18n、视觉一致性 | **more** → **delivery** · `/delivery` |
| 周报、本周总结、CHANGELOG 汇总 | **week** · `/week` |
| 磁盘快照、空间占用、哪个目录变大 | **disk** · `/disk` |
| 环境维护、清理磁盘、dev maintenance | **maintain** · `/maintain` |
| submodule、vendor、依赖升级 | **more** → submodule.mdc |
| workflow.json、hooks、profile | **more** → config |
| 本地 rules、local | **more** → `.cursor/rules/local/` |

## 上下文捷径

| 检测信号 | 优先建议 |
|----------|----------|
| `scaffold.sh detect` → empty | **scaffold** |
| 无 `plan.md` 且要做功能 | **scaffold** 或 **plan**（AskQuestion） |
| `gate-check` OK 且有 ACTIVE | **run** |
| `gate-check` BLOCK | **plan** 或 **fix** → 闸门 |
| `PLANNING:true` | **plan**（继续规划） |
| `task-verify` / `verify` 失败 | **fix** → **run**；仍失败 **plan** `⚠️` |
| 用户贴 CHANGELOG / 说升版本 | **ship** |
| 母版仓库 / 改 `.cursor/` 验收 | `template-verify.sh`（须用户明确授权才改母版） |

## 推荐路径（给用户看，一行）

```
空仓库:  master → scaffold → learn → plan → run → verify
迭代:    master → plan → run（循环）
卡住:    master → fix → run 或 plan
迷路:    master → （≤7 项选对）→ 对应 slash
```

## 文档

- [quickstart.md](../../docs/quickstart.md) — 5 分钟闭环
- [walkthrough.md](../../docs/walkthrough.md) — 端到端示例
- [training/skills.md](../../docs/training/skills.md) — 全 skill 表
- [scaffold.md](../../docs/scaffold.md) · [plan-run.md](../../docs/plan-run.md)
- [README 场景速查](../../README.md) — 摘要表 + 链回本文件
