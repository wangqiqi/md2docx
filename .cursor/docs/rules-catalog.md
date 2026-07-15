# Rules catalog · 社区索引与 local 引用

Super Cursor 母版仅含 **通用** rules（`core` · `workflow` · `execution/*` · `tech/*` 等）。栈专用 rules 请放入目标项目 **`.cursor/rules/local/`**（见 [local/README](../rules/local/README.md)）。

## 四模式（Cursor / 社区最佳实践）

| 模式 | frontmatter | 用途 |
|------|-------------|------|
| Always | `alwaysApply: true` | 母版仅 `core` + `workflow` |
| Auto | `globs: [...]` | `tech/*` · `testing.mdc` 等 |
| Agent | `description` 清晰 | Agent 按任务 relevance 加载 |
| Manual | `@ruleName` | 显式引用 |

保持 alwaysApply ≤2 · 单 rule 宜 <500 行 · 细节进 skills 或 `references/`。

## 社区策展（高引用 · 只链不拷）

| 资源 | 说明 |
|------|------|
| [PatrickJS/awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | ~40k ⭐ · 最大 .mdc 列表 |
| [LessUp/awesome-cursorrules-zh](https://github.com/LessUp/awesome-cursorrules-zh) | PatrickJS **中文镜像** · 132 栈规则 · 通用项已蒸馏进母版 |
| [sickn33/agentic-awesome-skills](https://github.com/sickn33/agentic-awesome-skills) | ~43k ⭐ · 跨工具 SKILL 合集 |
| [spencerpauly/awesome-cursor-skills](https://github.com/spencerpauly/awesome-cursor-skills) | Cursor 原生向 skill 策展（browser QA 等） |
| [cursor.directory](https://cursor.directory/) | 社区 rule 浏览 |
| [digitalchild/cursor-best-practices](https://github.com/digitalchild/cursor-best-practices) | 规则组织与模式 |
| [Cursor Docs · Rules](https://cursor.com/docs/rules) | 官方 globs / RULE.md |

### 吸收门禁（母版）

| 做 | 不做 |
|----|------|
| 栈专用 → 目标项目 **`.cursor/rules/local/`** | **禁止**整仓拷贝进母版 `.cursor/skills/` / `rules/` |
| 通用缺口 → 蒸馏进**现有** skill/rule（过通用性门禁） | 为追星新建第 N 个平行入口 skill |
| 本表外链仅作策展索引 | 把业务包名/产品路径写进母版 |

## 母版已吸收（通用蒸馏）

| 社区主题 | 母版落点 |
|----------|----------|
| anti-overengineering | `rules/execution/scope.mdc` |
| anti-sycophancy（精选） | `rules/communication/agent-discipline.mdc` |
| Vitest/Playwright testing | `rules/execution/testing.mdc` |
| PR review 分角 | `rules/communication/collaboration.mdc` |
| Svelte 5 | `rules/tech/svelte.mdc` |
| Next Supabase auth | `rules/tech/nextjs.mdc` § Auth |
| IA / 导航迷路 / 角色入口 | `rules/execution/ux.mdc` · `rules/execution/ia.mdc` · **ux** / **ia** skills |
| 交付 UX 验收 | `rules/execution/delivery.mdc` · **delivery** §5 导航与 IA |
| 数据访问批处理（IN 分块） | `rules/execution/data-batch.mdc`（吸收自跨项目通用护栏） |
| 开源优先 / vendor 溯源 | `rules/execution/oss-first.mdc` · `submodule.mdc`（吸收自跨项目通用护栏） |
| 输入边界 / 安全默认 | `rules/execution/input-bounds.mdc` |
| 扩展宿主（可选） | `rules/execution/extensibility.mdc`（三级 · glob） |
| Prompt / Agent 安全 | `rules/execution/prompt-security.mdc` |
| BDD / Gherkin | `rules/execution/testing.mdc` § BDD |
| 评审清单 · Issue 模板 | `collaboration.mdc` · `bugfix.mdc` |
| Conventional Commits 速查 | **git** skill |
| awesome-cursorrules-zh 通用蒸馏 | 上四行 · 栈专用仅本表外链 |

## 引用到 local/

```bash
# 示例：从 awesome 复制 Next+Supabase 专 rule（勿 commit 进母版仓库）
curl -o .cursor/rules/local/my-stack.mdc \
  'https://raw.githubusercontent.com/PatrickJS/awesome-cursorrules/main/rules/...'

# 中文镜像（栈专用 · 同上门禁）
curl -o .cursor/rules/local/flutter.mdc \
  'https://raw.githubusercontent.com/LessUp/awesome-cursorrules-zh/master/docs/rules/mobile/flutter/flutter-app-expert/.cursorrules'
```

安装后编辑 `alwaysApply: false` · 收窄 `globs` · 与母版 `tech/*` 互补而非重复。

## 与 skills 分工

- **Rules** — 纪律、栈约定、globs 触发
- **Skills** — 多步流程（plan/run/release/git）
- 流程不要写进长 rule；rule 不要重复 skill 全文
