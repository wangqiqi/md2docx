# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: M-DOC-02 -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: -->
<!-- NEXT: -->
<!-- LAST_DONE: M-DOC-02-03 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.4 -->
<!-- RELEASED: v0.4.4 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。审查依据：[`审查.md`](审查.md)

## ROADMAP

| 主题 | 优先级 | 状态 | 备注 |
|------|--------|------|------|
| 审查报告文档收尾 | P0 | **已闭合** | M-DOC-02 · v0.4.5 待打版 |
| 数学公式 LaTeX 支持 | P1 | 待立项 | docs/plan.md |
| Mermaid 流程图支持 | P1 | 待立项 | |
| jwplan/jwrun 工作流迁移 | P0 | 已闭合 | 2026-06-08 |

## 活跃 Sprint · M-DOC-02 审查文档同步

> **WHY**：`审查.md` M7 文档偏差收尾  
> **闭合条件**：P0 全部 ✅ · `pytest -q` 绿 · **154 passed**

**执行顺序**：`M-DOC-02-01` → `M-DOC-02-02` → `M-DOC-02-03`

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|
| M-DOC-02-01 | 修正 api.md 安全说明（bleach 消毒 + CSRF） | P0 | ✅ | grep -q 'bleach' docs/api.md | docs/api.md |
| M-DOC-02-02 | 移除 README 对 requirements-prod.txt 的过时引用 | P0 | ✅ | ! grep -q requirements-prod README.md | README.md |
| M-DOC-02-03 | 合并 README 重复「已完成」段落 | P1 | ✅ | pytest -q | README.md |

## 变更记录

- **2026-06-08** · **M-DOC-02 jwrun 执行** · api.md 安全说明 · README 依赖/结构树修正
- **2026-06-08** · **M-DOC-02 Sprint 规划** · handoff jwrun
- **2026-06-08** · jwplan/jwrun 工作流迁入 `.cursor/`
