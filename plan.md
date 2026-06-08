# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: (none) -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: (none) -->
<!-- NEXT: (none) -->
<!-- LAST_DONE: M-MATH-01-04 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.14 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。样例：[`tests/samples/advanced/math.md`](tests/samples/advanced/math.md)

## ROADMAP

| # | 主题 | 优先级 | 状态 | 备注 |
|---|------|--------|------|------|
| 2 | **数学公式 LaTeX 支持** | P1 | **已完成** | M-MATH-01 · v0.5.11–v0.5.14 |
| 4 | 双向转换 DOCX→MD | P2 | 待立项 | v0.6.0 |
| 5 | 插件系统基础 | P3 | 待立项 | v1.0.0 |
| 6 | 架构建议 Suggestions 1-8 | P3 | 远期 | |
| 7 | 测试体系补强 | P1 | 已完成 | T-TEST-01 · v0.5.4–v0.5.10 |
| 3 | Mermaid 流程图支持 | P1 | 已完成 | M-MERMAID-01 · v0.5.0–v0.5.3 |
| 1 | html2docx 可选依赖文档化 | P2 | 已完成 | T-TEST-01-05 |

## 已闭合 Sprint · M-MATH-01 数学公式 LaTeX 支持

> **WHY（闭合后）**：ROADMAP #2 已交付 · **187 passed** · v0.5.11–v0.5.14  
> **参照**：[`archive/sprint/20260609_074531_…`](archive/sprint/20260609_074531_数学公式_M-MATH-01_Sprint闭合_打版_v0.5.14.md)

### 闭合快照（jwrun §7B）

| 维度 | 规划时（jwplan） | 闭合后（jwrun §7） | 评价 |
|------|------------------|-------------------|------|
| **解析** | commonmark 无 math | **dollarmath** → math_inline/block | ✅ 01-01 |
| **渲染** | 纯文本 `$…$` | **CodeCogs PNG** 嵌入 | ✅ 01-02 |
| **安全** | 无 | **latex.codecogs.com 白名单** | ✅ 01-03 |
| **测试** | math.md 无专项 | **11 单测 + 1 集成**（mock） | ✅ 01-04 |
| **全量** | 176 passed | **187 passed, 2 skipped** | ✅ |

**结论（闭合后）**：行内/块级 LaTeX 首版已交付；**公式编号、align 多行、OMML** 仍属远期。

### 闭合对照

| 原缺口 | 任务 | 状态 |
|--------|------|------|
| 无 dollarmath | 01-01 | ✅ |
| 无 PNG 嵌入 | 01-02 | ✅ |
| 无 URL 白名单/回退 | 01-03 | ✅ |
| 无 README/集成 | 01-04 | ✅ |
| `\ref` / align / OMML | — | 🔲 远期 |

| ID | 任务 | 状态 |
|----|------|------|
| M-MATH-01-01 ~ 04 | 见归档 | 全部 ✅ |

## 已闭合 Sprint

| Sprint | 版本 | 归档 |
|--------|------|------|
| M-MATH-01 | v0.5.11–v0.5.14 | [archive/sprint/20260609_074531_数学公式_M-MATH-01_Sprint闭合_打版_v0.5.14.md](archive/sprint/20260609_074531_数学公式_M-MATH-01_Sprint闭合_打版_v0.5.14.md) |
| T-TEST-01 | v0.5.4–v0.5.10 | [archive/sprint/20260608_230821_…](archive/sprint/20260608_230821_测试体系_T-TEST-01_Sprint闭合_打版_v0.5.10.md) |
| M-MERMAID-01 | v0.5.0–v0.5.3 | archive/sprint/20260608_225947_… |
| M-CONV-01 | v0.4.9–v0.4.10 | archive/sprint/20260608_225306_… |
| M-DOC-03 | v0.4.5–v0.4.8 | archive/sprint/20260608_225037_… |

## 变更记录

- **2026-06-09** · **M-MATH-01 §7 闭合** · v0.5.11–v0.5.14 · 187 passed · 审计快照已同步
- **2026-06-08** · **M-MATH-01 Sprint 规划** · dollarmath + CodeCogs PNG · handoff jwrun
