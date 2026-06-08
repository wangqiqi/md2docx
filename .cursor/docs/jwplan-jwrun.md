# jwplan · jwrun 开发闭环

从 [seegrow](https://github.com) 工作流适配至 md2docx。

## 结构

| 路径 | 类型 |
|------|------|
| `commands/jwplan.md` · `jwrun.md` | Command 入口 `/jwplan` `/jwrun` |
| `skills/jwplan-skill/` · `jwrun-skill/` | Agent 细则 |
| `rules/md2docx-dev-workflow/RULE.md` | 始终生效规则 |
| `bin/dev_runner.sh` | 闸门 · 验收 · 版本 CLI |
| `hooks.json` + `hooks/jwrun-*.sh` | sessionStart / stop 链式自治 |

## 用法

```
/jwplan  → 拆 Sprint 写入根 plan.md → PLAN_APPROVED
/jwrun   → gate-check → ACTIVE → task-verify → commit → tag
```

- **plan 真源**：根目录 `plan.md`（非 `docs/plan.md`）
- **验收默认**：`pytest -q`
- **打版**：`CHANGELOG.md` + `pyproject.toml` + `__version__` + `git tag`

## CLI

```bash
./.cursor/bin/dev_runner.sh status
./.cursor/bin/dev_runner.sh gate-check
./.cursor/bin/dev_runner.sh plan-check
```
