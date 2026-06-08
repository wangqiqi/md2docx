# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: (none) -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: (none) -->
<!-- NEXT: (none) -->
<!-- LAST_DONE: M-HTML-01-04 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.18 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。样例：[`tests/samples/basic/html.md`](tests/samples/basic/html.md)

## ROADMAP

| # | 主题 | 优先级 | 状态 | 备注 |
|---|------|--------|------|------|
| 8 | **html-for-docx 迁移**（替代停更 html2docx） | P2 | **已完成** | M-HTML-01 · v0.5.15–v0.5.18 |
| 2 | **数学公式 LaTeX 支持** | P1 | **已完成** | M-MATH-01 · v0.5.11–v0.5.14 |
| 6 | 架构建议 Suggestions 1-8 | P3 | 远期 | |
| 7 | 测试体系补强 | P1 | 已完成 | T-TEST-01 · v0.5.4–v0.5.10 |
| 3 | Mermaid 流程图支持 | P1 | 已完成 | M-MERMAID-01 · v0.5.0–v0.5.3 |
| 1 | html2docx 可选依赖文档化 | P2 | 已完成 | T-TEST-01-05（已由 M-HTML-01 supersede） |

## 已闭合 Sprint · M-HTML-01 html-for-docx 迁移

> **WHY（闭合后）**：ROADMAP #8 已交付 · **192 passed**（装 `[html]` 时 0 skip）· v0.5.15–v0.5.18  
> **参照**：[`archive/sprint/20260609_075534_…`](archive/sprint/20260609_075534_html-for-docx_M-HTML-01_Sprint闭合_打版_v0.5.18.md)

### 闭合快照（jwrun §7B）

| 维度 | 规划时（jwplan） | 闭合后（jwrun §7） | 评价 |
|------|------------------|-------------------|------|
| **依赖** | 停更 `html2docx>=1.6.0` | **`html-for-docx>=1.1.0`** | ✅ 01-01 |
| **转换** | temp .html/.docx 合并 | **`HtmlToDocx.add_html_to_document()` 直写** | ✅ 01-02 |
| **测试** | 2 skip（无 html2docx） | **18 单测 + 6 集成**（含 html.md） | ✅ 01-03 |
| **文档** | 仍写 html2docx | **testing.md / README → html-for-docx** | ✅ 01-04 |
| **全量** | 187 passed, 2 skipped | **192 passed**（本地 `[html]`） | ✅ |

**结论（闭合后）**：MD 内嵌复杂 HTML 回退路径已迁到活跃库；CI 未装 `[html]` 时 skip 策略不变。**不做**整文件 HTML→DOCX。

### 闭合对照

| 原缺口 | 任务 | 状态 |
|--------|------|------|
| html2docx 停更 | 01-01 | ✅ |
| 临时文件转换链路过重 | 01-02 | ✅ |
| skip 用例 / 缺 html.md 集成 | 01-03 | ✅ |
| 文档仍指 html2docx | 01-04 | ✅ |

| ID | 任务 | 状态 |
|----|------|------|
| M-HTML-01-01 ~ 04 | 见归档 | 全部 ✅ |

## 已闭合 Sprint

| Sprint | 版本 | 归档 |
|--------|------|------|
| M-HTML-01 | v0.5.15–v0.5.18 | [archive/sprint/20260609_075534_html-for-docx_M-HTML-01_Sprint闭合_打版_v0.5.18.md](archive/sprint/20260609_075534_html-for-docx_M-HTML-01_Sprint闭合_打版_v0.5.18.md) |
| M-MATH-01 | v0.5.11–v0.5.14 | [archive/sprint/20260609_074531_数学公式_M-MATH-01_Sprint闭合_打版_v0.5.14.md](archive/sprint/20260609_074531_数学公式_M-MATH-01_Sprint闭合_打版_v0.5.14.md) |
| T-TEST-01 | v0.5.4–v0.5.10 | [archive/sprint/20260608_230821_…](archive/sprint/20260608_230821_测试体系_T-TEST-01_Sprint闭合_打版_v0.5.10.md) |
| M-MERMAID-01 | v0.5.0–v0.5.3 | archive/sprint/20260608_225947_… |
| M-CONV-01 | v0.4.9–v0.4.10 | archive/sprint/20260608_225306_… |
| M-DOC-03 | v0.4.5–v0.4.8 | archive/sprint/20260608_225037_… |

## 变更记录

- **2026-06-09** · **M-HTML-01 §7 闭合** · v0.5.15–v0.5.18 · 192 passed · 审计快照已同步
- **2026-06-08** · **M-HTML-01 Sprint 规划** · html-for-docx 迁移 · 4 任务 · handoff jwrun
- **2026-06-09** · **ROADMAP 调整** · 移除「插件系统」（定位：常见 Markdown → DOCX）
- **2026-06-09** · **ROADMAP 调整** · 移除「双向转换 DOCX→MD」（产品定位 md2docx 单向）
- **2026-06-09** · **M-MATH-01 §7 闭合** · v0.5.11–v0.5.14 · 187 passed · 审计快照已同步
