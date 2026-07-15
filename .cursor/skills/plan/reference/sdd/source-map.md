# spec-kit → Super Cursor 落点矩阵

> 出处与许可见 **`docs/library-index.md`**（§ github/spec-kit）  
> 真源仅在 **`.cursor/`**

## 许可与边界

| 项 | 说明 |
|----|------|
| 许可 | MIT — 模板可改编，保留出处 |
| 母版落点 | `.cursor/skills/plan/reference/sdd/` · `.cursor/templates/sdd/` · `config/workflow.json` `sdd` |
| **不**纳入母版 | `specify-cli` · `.specify/` 目录 · `/speckit.*` slash · extensions/presets/bundles |
| 目标项目工件 | 默认 `docs/specs/<###-slug>/`（`workflow.json` → `sdd.specs_dir`） |

## 命名冲突（必读）

| 词 | spec-kit | Super Cursor | 吸收用法 |
|----|----------|--------------|----------|
| **constitution** | 项目开发原则 | `rules/communication/constitution.mdc` **协作三公理** | 母版用 **principles** · `principles-template.md` |
| **plan** | 技术实现计划 | Sprint `.cursorGrowth/plan.md` | 技术计划 = `tech-plan-template.md` · 目录内 `plan.md` |
| **spec** | 功能需求文档 | 常指 OpenAPI | 功能 spec = `spec-template.md` · `spec.md` |

## 命令 → 母版映射（无新 slash）

| spec-kit 命令 | 母版落点 | 工件 |
|---------------|----------|------|
| `/speckit.constitution` | **plan** 阶段 0（可选） | `{sdd.principles_file}` 默认 `docs/principles.md` |
| `/speckit.specify` | **plan** Greenfield | `{specs_dir}/<id>/spec.md` |
| `/speckit.clarify` | **plan** 阶段 1 | `clarifications.md` 或 spec 内 Clarifications 节 |
| `/speckit.plan` | **plan** 阶段 1–2 | `{specs_dir}/<id>/plan.md` |
| `/speckit.tasks` | **plan** 阶段 2 | `tasks.md` → 导入 `.cursorGrowth/plan.md` TASK 表 |
| `/speckit.analyze` | **review** §SDD analyze | 只读 |
| `/speckit.implement` | **run** | 已有 |
| `/speckit.converge` | **run** 收尾 | 差距 → 新 TASK |
| `/speckit.checklist` | **delivery** / **plan** DOC | 需求完整性 |
| `/speckit.taskstoissues` | **git** §github-ops | 已有 |
| `specify-cli` | **master** deps LIBRARY | 用户 `uv tool install specify-cli` |

## SDD 模式（`/plan` AskQuestion）

| 模式 | 何时 | 工件 |
|------|------|------|
| **Sprint 增量** | 默认 · 已有代码迭代 | 仅 `.cursorGrowth/plan.md` |
| **Greenfield** | 新功能从 0→1 | principles → spec → clarify → tech plan → tasks → plan TASK |
| **Brownfield** | 存量增强 | 读代码 + 增量 `spec.md` · 不强制新目录 |

## 路径兼容

| 约定 | 路径 |
|------|------|
| Super Cursor 默认 | `docs/specs/`（`workflow.json` `sdd.specs_dir`） |
| spec-kit 默认 | `specs/` — 可在目标项目 `workflow.json` 或 `rules/local` 改为 `specs` |

## 模板文件

| 文件 | 用途 |
|------|------|
| `spec-template.md` | 功能 what/why · 用户故事 |
| `tech-plan-template.md`（源自 plan-template） | 技术 how · research · contracts |
| `tasks-template.md` | 任务分解 · `[P]` 并行 |
| `principles-template.md` | 项目原则（非三公理） |

安装复制：`.cursor/templates/sdd/` → 目标项目可由 **scaffold** 或 **learn** 引导创建 `docs/specs/`。

## 自动化键（`workflow.json`）

```json
"sdd": {
  "specs_dir": "docs/specs",
  "principles_file": "docs/principles.md",
  "feature_id_width": 3
}
```

Runner / 未来 hook 可解析 `specs_dir` 定位活跃 feature 目录。
