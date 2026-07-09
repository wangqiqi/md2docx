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

## 社区策展（高引用）

| 资源 | 说明 |
|------|------|
| [PatrickJS/awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | ~40k ⭐ · 最大 .mdc 列表 |
| [cursor.directory](https://cursor.directory/) | 社区 rule 浏览 |
| [digitalchild/cursor-best-practices](https://github.com/digitalchild/cursor-best-practices) | 规则组织与模式 |
| [Cursor Docs · Rules](https://cursor.com/docs/rules) | 官方 globs / RULE.md |

## 母版已吸收（SPRINT-07）

| 社区主题 | 母版落点 |
|----------|----------|
| anti-overengineering | `rules/execution/scope.mdc` |
| anti-sycophancy（精选） | `rules/communication/agent-discipline.mdc` |
| Vitest/Playwright testing | `rules/execution/testing.mdc` |
| PR review 分角 | `rules/communication/collaboration.mdc` |
| Svelte 5 | `rules/tech/svelte.mdc` |
| Next Supabase auth | `rules/tech/nextjs.mdc` § Auth |
| IA / 导航迷路 / 角色入口 | `rules/execution/ux.mdc` · `ia.mdc` · **ux** / **ia** skills |
| 交付 UX 验收 | `rules/execution/delivery.mdc` · **delivery** §5 导航与 IA |
| 数据访问批处理（IN 分块） | `rules/execution/data-batch.mdc`（吸收自跨项目通用护栏） |

## 引用到 local/

```bash
# 示例：从 awesome 复制 Next+Supabase 专 rule（勿 commit 进母版仓库）
curl -o .cursor/rules/local/my-stack.mdc \
  'https://raw.githubusercontent.com/PatrickJS/awesome-cursorrules/main/rules/...'
```

安装后编辑 `alwaysApply: false` · 收窄 `globs` · 与母版 `tech/*` 互补而非重复。

## 与 skills 分工

- **Rules** — 纪律、栈约定、globs 触发
- **Skills** — 多步流程（plan/run/release/git）
- 流程不要写进长 rule；rule 不要重复 skill 全文
