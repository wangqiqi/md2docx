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
| **plan** | `/plan` · 拆任务 | Sprint · 先总后分 · plan 工作副本 | 写业务代码 |
| **run** | `/run` · 继续 | 实现 · task-verify · commit | 无闸门硬编码 |
| **learn** | `/learn` | Growth `learn/` | 改 `.cursor/` |
| **scaffold** | `/scaffold` | 8 栈骨架 · audit | 未确认覆盖 |
| **git** | commit/push | 提交前清单 · 规范 commit | force-push |
| **release** | `/release` · merge/PR/打版 | §分支 · §semver/tag · CHANGELOG | 跳过 verify |
| **security** | 审查 | 密钥 · auth · PII 清单 | — |
| **api** | API 变更 | REST/OpenAPI 清单 | — |
| **ux** | UX / 体验 · 分流 | IA⊂UX · 路由 ia/delivery/plan | 不写 checklist |
| **ia** | 信息架构 · 导航 | R1–R4 · 角色入口 · `docs/design/` | 业务路由进母版 |
| **debug** | 调试 | 隔离 · 模式聚类 | — |
| **test** | 测试 | 单测/集成/E2E · TDD（L 层见 verify.mdc） | — |
| **mcp** | MCP | 建服四阶段 · `reference/` | — |
| **refactor** | 重构 | 小步可验证 | — |
| **perf** | 性能 | 测量优先 | — |
| **review** | REV-* · PR 回顾 | 坏味道清单 · 委派 review agent | 写代码 |
| **delivery** | `/delivery` · 上线前 | 7 维交付验收 | 替代 task-verify |
| **week** | 周报（关键词 / master） | CHANGELOG 汇总 → Growth | 打 tag |
| **disk** | 磁盘快照（关键词 / master） | 占用 · diff → Growth | 删除文件 |
| **maintain** | 环境维护（关键词 / master） | 诊断与安全清理 · 委托 disk | 无配置乱删 |
| **study** | 学新技术 | 最小示例 · SPIKE 归档 | 项目认知（用 learn） |

Agents：**ship**（发版）· **review** · **spike**（后二者只读）

## 推荐路径

```
迭代:     /plan → /run（循环）→ 可选 /delivery → /release
空仓库:   /scaffold → /learn → /plan → /run → verify
迷路:     /master → 主菜单 7 项 → 子问
```

详表与关键词 → [`routes.md`](../skills/master/routes.md)。

## 8 栈 scaffold

`react-vite-ts` · `vue-vite-ts` · `nextjs-ts` · `go-api` · `rust-axum` · `python-fastapi` · `java-gradle` · `cpp-cmake`

## install profile

| profile | 说明 |
|---------|------|
| `full` | plan/run + hooks（默认） |
| `lite` | plan/run，无 hooks |
| `rules-only` | 仅 rules/skills |

详见 [quickstart.md](../quickstart.md) · [walkthrough.md](../walkthrough.md)
