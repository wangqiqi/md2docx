# SDD 模板（安装种子）

出处与许可见 **`.cursor/docs/library-index.md`**（§ github/spec-kit）。母版真源：`.cursor/skills/plan/reference/sdd/`。

## 用途

目标项目 Greenfield 功能开发时，由 **plan** skill 引导创建工件（**非**母版运行时目录）：

| 模板 | 默认落点 |
|------|----------|
| `principles-template.md` | `docs/principles.md`（`workflow.json` `sdd.principles_file`） |
| `spec-template.md` | `docs/specs/<###-slug>/spec.md` |
| `tech-plan-template.md` | `docs/specs/<###-slug>/plan.md` |
| `tasks-template.md` | `docs/specs/<###-slug>/tasks.md` |

路径坐标：`config/workflow.json` → `sdd.specs_dir`（默认 `docs/specs`）。

## 工作流

用户只说 **`/plan`** → AskQuestion 选 Greenfield → Agent 按 **plan** §SDD 与 `reference/sdd/source-map.md` 执行；**`/run`** 实现。

## 与 spec-kit 完整工具链

需 `specify init` / `specify-cli` → **master** deps LIBRARY（用户自选 `uv tool install specify-cli`）；母版**不**硬依赖。
