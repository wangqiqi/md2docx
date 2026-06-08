# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: M-CONV-01 -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: true -->
<!-- ACTIVE: -->
<!-- NEXT: -->
<!-- LAST_DONE: M-CONV-01-02 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.4 -->
<!-- RELEASED: v0.4.10 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。审查依据：[`审查.md`](审查.md)

## ROADMAP

| 主题 | 优先级 | 状态 | 备注 |
|------|--------|------|------|
| 审查报告残余代码（M-CONV-01） | P2 | **已闭合** | v0.4.9–v0.4.10 |
| html2docx 可选依赖文档化 | P2 | 待立项 | T-HTML-01 |
| 架构建议（Suggestions 1-8） | P3 | 远期 | |
| 数学公式 LaTeX 支持 | P1 | 待立项 | |

## 活跃 Sprint · M-CONV-01 审查残余代码

> **WHY**：`审查.md` m1/m2 未完成  
> **闭合条件**：P0 全部 ✅ · `pytest -q` 绿

**执行顺序**：`M-CONV-01-01` → `M-CONV-01-02`

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|
| M-CONV-01-01 | 引用块支持链接/删除线/行内代码（m2） | P0 | ✅ | pytest -q tests/unit/test_elements/test_blockquote.py | blockquote.py |
| M-CONV-01-02 | `ConvertError` 保留原始异常链（m1） | P1 | ✅ | grep -q 'from e' src/mddocx/converter/base.py | base.py |

## 变更记录

- **2026-06-08** · **M-CONV-01 jwrun 闭合** · blockquote 内联 · 异常链 · v0.4.10
- **2026-06-08** · **M-CONV-01 Sprint 启动** · AUTONOMOUS true · 承接审查 m1/m2
- **2026-06-08** · **M-DOC-03 jwrun 闭合** · v0.4.8
