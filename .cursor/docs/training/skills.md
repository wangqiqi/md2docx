# Skills 速查

**路由详表（canonical）**：[`skills/master/routes.md`](../skills/master/routes.md)。本页为人读摘要，避免与 routes 双写长表。

入口均在 `core.mdc`。说 slash 或关键词触发。

## Slash 三层（记【日常】即可）

| 层 | Slash | 口诀 |
|----|-------|------|
| **【日常】** | `/run` · `/plan` · `/master` | 做事 `/run` · 拆 Sprint `/plan` · 真迷路 `/master` |
| **【生命周期】** | `/scaffold` · `/learn` · `/release` | 空仓/换仓/onboarding · Sprint 出口 |
| **【高级】** | `/delivery` · `/ux` · `/ia` | Agent 也常自动选用，不必死记 |

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
| **delivery** | `/delivery` · 上线前 | 7 维交付 · PDF 脚本 · 反模板自检 | 替代 task-verify |
| **week** | 周报（关键词 / master） | CHANGELOG 汇总 → Growth | 打 tag |
| **disk** | 磁盘快照（关键词 / master） | 占用 · diff → Growth | 删除文件 |
| **maintain** | 环境维护（关键词 / master） | 诊断与安全清理 · 委托 disk | 无配置乱删 |
| **pencil-design** | 视觉设计（关键词 / `/pencil-design`） | Pencil CLI → `.pen` + PNG | IA/上线验收（用 ia/delivery） |
| **study** | 学新技术 | 最小示例 · SPIKE 归档 | 项目认知（用 learn） |

Agents：**ship**（发版）· **review** · **spike**（后二者只读）

## 推荐路径

```
迭代:     /plan（批准）→ /run **一次**（AUTONOMOUS 连跑 TASK）→ 可选 /delivery → /release
空仓库:   /scaffold → /learn → /plan → /run → verify
迷路:     /master → 主菜单 7 项 → 子问
```

详表与关键词 → [`routes.md`](../skills/master/routes.md)。

## 可选能力（无新增 skill）

| 能力 | 入口 |
|------|------|
| 任务中经验沉淀 | **learn** §经验捕获 |
| 外网 skill 安装前审计 | **security** §外部 Agent Skill · **master** → `deps` |
| 安装后裁剪（DAILY/LIBRARY） | **master** `routes.md` §DAILY/LIBRARY · **scaffold** 收尾 |
| 浏览器走查（探索） | **delivery** §10 |
| E2E / Playwright 起服 | **test** `scripts/with_server.py` |
| PDF 表单验收 | **delivery** `scripts/pdf/` |
| Greenfield 功能 spec | **plan** §SDD · `docs/specs/`（`workflow.json` `sdd.specs_dir`） |
| 网络抓取选型 | **debug** §网络与抓取 |

### 外网协议吸收（索引）

| 来源 | SSOT |
|------|------|
| anthropics/skills · spec-kit · SkillsMP | **`docs/library-index.md`** · `routes.md` §LIBRARY |

**git** §GitHub 运维 · **security** §支付/webhook — 见各 skill 正文。

## 8 栈 scaffold

`react-vite-ts` · `vue-vite-ts` · `nextjs-ts` · `go-api` · `rust-axum` · `python-fastapi` · `java-gradle` · `cpp-cmake`

## install profile

| profile | 说明 |
|---------|------|
| `full` | plan/run + hooks（默认） |
| `lite` | plan/run，无 hooks |
| `rules-only` | 仅 rules/skills |

详见 [quickstart.md](../quickstart.md) · [walkthrough.md](../walkthrough.md)
