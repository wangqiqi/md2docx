# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: -->
<!-- PLAN_APPROVED: -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: -->
<!-- NEXT: -->
<!-- LAST_DONE: M-CONV-01-02 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.4 -->
<!-- RELEASED: v0.4.10 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。审查依据：[`审查.md`](审查.md)

## ROADMAP（待立项 6 项 → 请 `/jwplan`）

| # | 主题 | 优先级 | 状态 | 备注 |
|---|------|--------|------|------|
| 1 | html2docx 可选依赖文档化 | P2 | 待立项 | T-HTML-01 · M12 · `pip install mddocx[html]` |
| 2 | 数学公式 LaTeX 支持 | P1 | 待立项 | docs/plan.md v0.5.0 |
| 3 | Mermaid 流程图支持 | P1 | 待立项 | docs/plan.md v0.5.0 |
| 4 | 双向转换 DOCX→MD | P2 | 待立项 | docs/plan.md v0.6.0 |
| 5 | 插件系统基础 | P3 | 待立项 | docs/plan.md v1.0.0 |
| 6 | 架构建议 Suggestions 1-8 | P3 | 远期 | token 重构 · mypy · Docker 等 |

## 已闭合（审查相关）

| Sprint | 版本 | 归档 |
|--------|------|------|
| M-DOC-03 审查残余文档 | v0.4.5–v0.4.8 | [archive/sprint/20260608_225037_…](archive/sprint/20260608_225037_审查残余文档_M-DOC-03_Sprint闭合_打版_v0.4.8.md) |
| M-CONV-01 审查残余代码 | v0.4.9–v0.4.10 | [archive/sprint/20260608_225306_…](archive/sprint/20260608_225306_审查残余代码_M-CONV-01_Sprint闭合_打版_v0.4.10.md) |

**审查.md 可执行项**：Critical/Major 代码与文档、Minor m1–m2/m8–m9 均已闭合。剩余：M12 文档、Suggestions 远期。

## 变更记录

- **2026-06-08** · **M-CONV-01 §7 闭合归档** · verify 157 passed · AUTONOMOUS→false
- **2026-06-08** · **M-CONV-01 jwrun** · v0.4.10
- **2026-06-08** · **M-DOC-03 jwrun** · v0.4.8
