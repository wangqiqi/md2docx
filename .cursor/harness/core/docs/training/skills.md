# Skills 速查

**路由详表（canonical）**：[`skills/master/routes.md`](../../skills/master/routes.md)。本页为人读摘要，避免与 routes 双写长表。

入口均在 `core.mdc`。slash 命中 **skill 名**（Cursor 2.4+；母版已退役 `commands/`）。关键词触发仅适用于 **未** 设 `disable-model-invocation` 的 skill。

## Slash 三层（记【日常】即可）

| 层 | Slash | 口诀 |
|----|-------|------|
| **【日常】** | `/run` · `/plan` · `/master` | 做事 `/run` · 拆 Sprint `/plan` · 真迷路 `/master` |
| **【生命周期】** | `/scaffold` · `/learn` · `/long` · `/release` | 空仓 · Epic 长程 · Sprint 出口 |
| **【高级】** | `/delivery` · `/manual` · `/report` | 上线走查 · 说明书 · 测试报告；ux/ia/debug 为 skill-only |

**反例**：plan 里已有 ACTIVE → **`/run`** 不是 `/plan`；已知目标 → 直接 slash，**跳过** `/master`。

| Skill | 触发 | 做什么 | 不做什么 |
|-------|------|--------|----------|
| **master** | `/master` · 从哪开始 | AskQuestion 路由（≤7 项/轮） | 写代码 · apply |
| **plan** | `/plan` · 拆任务 | Sprint · SDD · **AUTONOMOUS 一次 `/run` 连跑** | 写业务代码 |
| **review** | REV-* · PR 回顾 | Standards/Spec 双轴 · SDD analyze · review agent | 写代码 |
| **learn** | `/learn` | Growth `learn/` | 改 `.cursor/` |
| **scaffold** | `/scaffold` | 8 栈骨架 · audit | 未确认覆盖 |
| **git** | commit/push · GitHub 运维 | 提交清单 · **github-ops**（`gh` 有则用） | force-push |
| **release** | `/release` · merge/PR/打版 | §分支 · §semver/tag · CHANGELOG | 跳过 verify |
| **security** | 审查 · 支付/webhook | 密钥 · auth · PII · 敏感交易触发 | — |
| **api** | API 变更 | REST/OpenAPI 清单 | — |
| **ux** | UX / 体验 · 分流 | IA⊂UX · 路由 ia/delivery/plan | 不写 checklist |
| **ia** | 信息架构 · 导航 | R1–R4 · 角色入口 · `docs/design/` | 业务路由进母版 |
| **debug** | 调试 | 隔离 · Agent 内省 · 网络抓取 | — |
| **test** | 测试 | TDD · factory/mock · E2E/`with_server.py` · L 层见 verify.mdc | — |
| **mcp** | MCP | 建服五阶段（含 Eval）· `reference/` | — |
| **refactor** | 重构 | 小步可验证 | — |
| **perf** | 性能 | 测量优先 | — |
| **run** | `/run` · 继续 | 实现 · Sprint 连跑 · converge · task-verify · commit | 无闸门硬编码 |
| **long** | `/long` · Epic 长程 | 多 Sprint plan/run 链 · checkpoint · resume | 单 Sprint（用 plan+run） |
| **delivery** | `/delivery` · 上线前 | 7 维交付 · PDF 脚本 · 反模板自检 | 替代 task-verify |
| **user-manual** | `/manual` · 使用说明书 | Manual Contract · 配图 regen · Capture Profile | 替代 delivery 走查 |
| **test-report** | `/report` · 测试报告 | Report Contract · verify 汇总 · benchmark 文档 | 替代 test 写用例 |
| **week** | 周报（**`/week`**；dmi） | CHANGELOG 多仓汇总 → Growth | 单项目任务周报（目标项目自建 skill） |
| **disk** | 磁盘快照（**`/disk`**；dmi） | 占用 · diff → Growth | 删除文件 |
| **maintain** | 环境维护（**`/maintain`**；dmi） | 诊断与安全清理 · 委托 disk | 无配置乱删 |
| **ops-deploy** | 部署（**`/ops-deploy`**；dmi） | compose · env · nginx · verify 注册 SOP | 业务功能实现 |
| **code-stats-viz** | 代码统计（**`/code-stats-viz`**；dmi） | Git 行数/语言/提交日历 → HTML 仪表板 | 磁盘占用（用 disk） |
| **pencil-design** | 视觉设计（关键词 · 无 slash） | Pencil CLI → `.pen` + PNG | IA/上线验收（用 ia/delivery） |
| **study** | 学新技术 | 最小示例 · SPIKE 归档 | 项目认知（用 learn） |

Agents：**ship**（发版）· **review** · **spike**（后二者只读）

## 推荐路径

```
迭代:     /plan（批准）→ /run **一次**（AUTONOMOUS 连跑 TASK）→ 可选 /delivery → /release
长程:     /long <Epic> → 拆 Sprint → 每 Sprint plan+run → checkpoint
空仓库:   /scaffold → /learn → /plan → /run → verify
迷路:     /master → 主菜单 7 项 → 子问
```

详表与关键词 → [`routes.md`](../../skills/master/routes.md)。

## 可选能力（无新增 skill）

| 能力 | 入口 |
|------|------|
| 任务中经验沉淀 | **learn** §经验捕获 |
| 外网 skill 安装前审计 | **security** §外部 Agent Skill · **master** → `deps` |
| 安装后裁剪（DAILY/LIBRARY） | **master** `routes.md` §DAILY/LIBRARY · **scaffold** 收尾 |
| 浏览器走查（探索） | **delivery** §10 |
| E2E / Playwright 起服 | **test** `scripts/with_server.py` |
| 使用说明书 / 配图 regen | **user-manual** `/manual` |
| 测试报告 / 全量 verify 汇总 | **test-report** `/report` |
| PDF 表单验收 | **delivery** `scripts/pdf/` |
| Greenfield 功能 spec | **plan** §SDD · `docs/specs/`（`workflow.json` `sdd.specs_dir`） |
| 网络抓取选型 | **debug** §网络与抓取 |
| 交付后摩擦记录 / 汇总 | `runner.sh friction-log` · `friction-report`（`.growing/logs/friction.jsonl`） |
| 目标项目端到端自检 | `bash .cursor/bin/consumer-smoke.sh`（install → 闸门 → hook → docs-init → 全绿） |
| docs 骨架一键搭建 | `runner.sh docs-init [--profile <p>] [--slots 03,04] [--all]`（号位=瀑布阶段） |
| 母版 verify 索引 | [migration-catalog.md](../migration-catalog.md) §母版 verify · `verify.mdc` §母版门禁清单 |

### 外网协议吸收（索引）

| 来源 | SSOT |
|------|------|
| anthropics/skills · spec-kit · SkillsMP | **`docs/library-index.md`** · `routes.md` §LIBRARY |

**git** §GitHub 运维 · **security** §支付/webhook — 见各 skill 正文。

## disable-model-invocation 策略

`disable-model-invocation: true` 的 skill **只能**由用户显式 `/skill-name` 调用，Agent **不会**按关键词自动选用——「无 slash · 关键词触发」的措辞对它们不成立。

| 桶 | 字段 | skill |
|----|------|-------|
| **主路径 / 工具** | `disable-model-invocation: true` | plan · run · learn · scaffold · release · long · week · disk · maintain · code-stats-viz · ops-deploy |
| **分流 / 按需** | 不写（默认 false） | master · delivery · debug · test · ux · ia · review · security · api · git · mcp · refactor · perf · study · user-manual · test-report · pencil-design |

`description` frontmatter **≤85 字**（用途 + 一句触发）；详触发词 → 各 skill「何时进入」· [`routes.md`](../../skills/master/routes.md)。

两者均由 `bash .cursor/bin/verify-doc-super-cursor.sh` 断言（母版门面计数纪律的一部分）。

## 8 栈 scaffold

`react-vite-ts` · `vue-vite-ts` · `nextjs-ts` · `go-api` · `rust-axum` · `python-fastapi` · `java-gradle` · `cpp-cmake`

## install profile

| profile | 说明 |
|---------|------|
| `full` | plan/run + hooks（默认） |
| `lite` | plan/run，无 hooks |
| `rules-only` | 仅 rules/skills |

详见 [quickstart.md](../quickstart.md) · [walkthrough.md](../walkthrough.md)
