# md2docx · 待办（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: (none) -->
<!-- PLAN_APPROVED: 2026-06-09 -->
<!-- AUTONOMOUS: true -->
<!-- ACTIVE: (none) -->
<!-- NEXT: (none) -->
<!-- LAST_DONE: M-DOC-05-06 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.31 -->
<!-- MAX_LOOPS: 20 -->

> 已完成 Sprint 见 [`archive/sprint/`](archive/sprint/)。文档索引 [`docs/README.md`](docs/README.md)。

**当前**：无活跃 Sprint · **201 passed** · **v0.5.31** · **待办 8 项**

---

## ROADMAP · 待立项

| #   | 主题                             | 优先级 | Sprint       |
| --- | -------------------------------- | ------ | ------------ |
| 9b  | 大文件流式/分块转换              | P2     | M-PERF-01    |
| 12  | Mermaid 扩展（sequence / gantt） | P2     | M-MERMAID-02 |
| 13  | 公式编号与 `\ref`                | P2     | M-MATH-02    |
| 14  | 测试覆盖率与缺口补强             | P2     | T-TEST-02    |

**下一 Sprint 建议**：**M-PERF-01** 或 **T-TEST-02**

---

## 待办台账

| ID        | 任务                           | 状态 | 验收 / 落点                                   |
| --------- | ------------------------------ | ---- | --------------------------------------------- |
| REV-P2-05 | 补齐 `03_测试指南.md` 全量审计 | 🔶    | T-TEST-02                                     |
| ARCH-R02  | 大文件流式/分块转换            | ⬜    | M-PERF-01                                     |
| ARCH-R03  | 可观测性 metrics（可选）       | ⬜    | —                                             |
| TEST-G01  | 在线图片集成测加强             | ⬜    | `tests/integration/test_image_integration.py` |
| TEST-G02  | 整体覆盖率 ≥85%                | ⬜    | `pytest --cov=src --cov-report=term`          |
| TEST-G03  | `html.py` 覆盖率提升           | ⬜    | `pytest --cov=…/html.py`                      |
| FEAT-01   | Mermaid sequence / gantt       | ⬜    | M-MERMAID-02                                  |
| FEAT-02   | 公式编号与 `\ref`              | ⬜    | M-MATH-02                                     |

---

## 变更记录

- **2026-06-09** · **M-DOC-05 §7 闭合** · v0.5.31 · docs 扁平 01–07 · 删除 docs/plan.md
- **2026-06-09** · plan 精简为仅待办
