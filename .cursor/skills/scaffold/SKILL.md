---
name: scaffold
description: 脚手架（/scaffold）：空项目创建栈模板，已有项目审计与建议。说「初始化」「创建项目」「脚手架」时用。须用户确认后再创建。
disable-model-invocation: true
---

# scaffold

模板：`.cursor/templates/scaffold/`（**standard+**：lint/test/verify/README + **CI** + `.env.example`）· CLI：`.cursor/bin/scaffold.sh` · 目录见 [catalog.md](catalog.md)

**说明**：脚手架是 **scaffold skill** 驱动的**模板文件**，不是多个 skill；日常编码细则仍由 `rules/tech/*.mdc` 按 glob 加载。

**闸门**：脚手架创建属于**用户明确授权**的仓库初始化；空仓库（`detect` → `state=empty`）可在无 `plan.md` 时执行。**已有代码**必须先 `audit` + AskQuestion 确认，默认 `--dry-run`，禁止静默覆盖。

## 触发

- `/scaffold` · 「初始化项目」「创建脚手架」「空仓库怎么开始」
- `/plan` 中用户要新建项目 → 在 `PLANNING:true` 阶段用本 skill 流程提问，确认后 apply 或写入 `TASK-001` 验收列
- 任意模式：先沟通再动手

## 流程（空项目）

1. **检测**

```bash
./.cursor/bin/scaffold.sh detect
./.cursor/bin/scaffold.sh list
```

2. **AskQuestion**（至少确认栈；可多轮）

| 问题 | 选项示例 |
|------|----------|
| 项目类型 | frontend · backend · systems |
| 技术栈 | `react-vite-ts` · `vue-vite-ts` · `nextjs-ts` · `go-api` · `rust-axum` · `python-fastapi` · `java-gradle` · `cpp-cmake` |
| 模块路径（Go） | 默认 `example.com/app`，问用户是否替换 |
| 包管理器 | npm / pnpm（前端）；venv（Python） |

3. **预览** — 用户确认前必须执行：

```bash
./.cursor/bin/scaffold.sh info <id>
./.cursor/bin/scaffold.sh apply <id> --dry-run
```

用表格列出将 **CREATE** / **SKIP** 的文件；说明 `post_apply` 与 `verify`。

4. **创建** — 用户明确说「确认」「创建」「apply」后：

```bash
./.cursor/bin/scaffold.sh apply <id>
```

5. **收尾**（建议，非自动 commit）

- 执行 manifest 中的 `post_apply`（`npm install`、`go mod tidy` 等）
- 跑 `./scripts/verify.sh` 或更新 `config/workflow.json` → `verify_default`
- `cp .cursor/templates/plan.md ./plan.md` → **`/plan`** 拆首个 Sprint（`plan.md` 已在 `.gitignore`，不提交）
- **`/learn`** 写入栈与目录约定到 `.cursorGrowth/learn/`

## 测试闭环（plan/run / 自主开发）

每套 **standard** 脚手架均含：

| 脚本 | 用途 |
|------|------|
| `scripts/test.sh` | **开发中**快速回归（仅测试） |
| `scripts/verify.sh` | **任务/Sprint**全量验收（lint+test+build 等） |
| `tests/README.md` | 测试目录说明（Java 为 `src/test/README.md`） |

**plan.md 验收列建议**：

- 开发任务：`./scripts/test.sh` 或栈内等价（`npm run test` · `go test ./...` · `pytest`）
- 合并/打版前：`./scripts/verify.sh`
- 调试：前端 `npm run test:watch` · Go `go test -v ./tests/...` · Python `pytest -v tests/unit`

manifest 字段 `test` / `verify` 见 `templates/scaffold/manifest.json`。

## 流程（已有项目）

1. `detect` + `audit` — 不直接 apply
2. **audit 维度**（汇报表格）：
   - **结构**：目录/module 边界、入口、配置散落
   - **依赖**：lockfile、audit 命令、过时 major
   - **质量**：lint/test/verify 脚本、CI、README、plan.md
3. AskQuestion：全量脚手架 / 仅补 `scripts/verify.sh` / 只给建议
4. 若补文件：`--dry-run` → 确认 → `apply`（**无 `--force` 除非用户明确要求覆盖**）
5. 建议对齐 `rules/tech/*` 与 `/learn`

## 与 plan/run

| 场景 | 做法 |
|------|------|
| 空仓库先搭架 | `/scaffold` 确认 → apply → `/plan` |
| 规划阶段纳入 | Sprint 加 `TASK-001` 初始化，验收：`./.cursor/bin/scaffold.sh apply <id> && ./scripts/verify.sh` |
| 仅建议 | `SPIKE-` 调研选型，结论归档后再 `TASK-*` |

`/run` 执行脚手架任务时仍须 `gate-check` 通过。

## 禁止

- 未确认就 `apply`（尤其 `established` 仓库）
- 默认 `--force` 覆盖用户文件
- 把项目特化路径写进 `.cursor/templates/scaffold/`（应走 `/learn` 或 `rules/local/`）
