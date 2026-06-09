# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: (none) -->
<!-- PLAN_APPROVED: 2026-06-09 -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: (none) -->
<!-- NEXT: (none) -->
<!-- LAST_DONE: M-ARCH-01-08 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.26 -->
<!-- MAX_LOOPS: 20 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。审查来源：[`审查.md` §建议改进](审查.md)

## ROADMAP

| # | 主题 | 优先级 | 状态 | 备注 |
|---|------|--------|------|------|
| 6 | **架构建议 Suggestions 1–8** | P3 | **已完成** | M-ARCH-01 · v0.5.19–v0.5.26 |
| 8 | html-for-docx 迁移 | P2 | **已完成** | M-HTML-01 |
| 2 | 数学公式 LaTeX 支持 | P1 | **已完成** | M-MATH-01 |
| 7 | 测试体系补强 | P1 | 已完成 | T-TEST-01 |
| 3 | Mermaid 流程图支持 | P1 | 已完成 | M-MERMAID-01 |
| 1 | html2docx 可选依赖文档化 | P2 | 已完成 | M-HTML-01 supersede |

## 已闭合 Sprint · M-ARCH-01 审查架构建议

> **WHY（闭合后）**：ROADMAP #6 已交付 · **199 passed** · v0.5.19–v0.5.26  
> **参照**：[`archive/sprint/20260609_080200_…`](archive/sprint/20260609_080200_架构建议_M-ARCH-01_Sprint闭合_打版_v0.5.26.md)

### 闭合快照（jwrun §7B）

| 维度 | 规划时（jwplan） | 闭合后（jwrun §7） | 评价 |
|------|------------------|-------------------|------|
| **S8 错误** | CLI/WebUI 不一致 | **`errors.py` + `[CODE]` 前缀** | ✅ 01-01 |
| **S7 任务列表** | Unicode ☐/☑ | **Word checkbox SDT + 回退** | ✅ 01-02 |
| **S4 日志** | debug print | **`duration_ms` / `input_bytes` INFO** | ✅ 01-03 |
| **S3 限流** | 无 WebUI 限流 | **30 req/min/IP** | ✅ 01-04 |
| **S6 pre-commit** | 未强调 | **CONTRIBUTING 必装** | ✅ 01-05 |
| **S5 Docker** | 无 Dockerfile | **Dockerfile + api.md** | ✅ 01-06 |
| **S2 mypy** | CI continue-on-error | **mypy.ini + 新模块 CI** | ✅ 01-07 |
| **S1 架构** | base 492 行 | **TokenProcessor · base 220 行** | ✅ 01-08 |
| **全量** | 192 passed | **199 passed** | ✅ |

**结论（闭合后）**：审查 Suggestions 1–8 首版已落地；elements 全量 strict mypy、大文件流式转换仍属远期。

### 闭合对照

| 原缺口 | 任务 | 状态 |
|--------|------|------|
| 错误码不统一 | 01-01 | ✅ |
| Unicode checkbox | 01-02 | ✅ |
| 无结构化日志 | 01-03 | ✅ |
| WebUI 无限流 | 01-04 | ✅ |
| pre-commit 未文档化 | 01-05 | ✅ |
| 无 Docker | 01-06 | ✅ |
| mypy 软失败 | 01-07 | ✅ |
| base 圈复杂度高 | 01-08 | ✅ |

| ID | 任务 | 状态 |
|----|------|------|
| M-ARCH-01-01 ~ 08 | 见归档 | 全部 ✅ |

## 已闭合 Sprint

| Sprint | 版本 | 归档 |
|--------|------|------|
| M-ARCH-01 | v0.5.19–v0.5.26 | [archive/sprint/20260609_080200_架构建议_M-ARCH-01_Sprint闭合_打版_v0.5.26.md](archive/sprint/20260609_080200_架构建议_M-ARCH-01_Sprint闭合_打版_v0.5.26.md) |
| M-HTML-01 | v0.5.15–v0.5.18 | [archive/sprint/20260609_075534_html-for-docx_M-HTML-01_Sprint闭合_打版_v0.5.18.md](archive/sprint/20260609_075534_html-for-docx_M-HTML-01_Sprint闭合_打版_v0.5.18.md) |
| M-MATH-01 | v0.5.11–v0.5.14 | archive/sprint/20260609_074531_… |
| T-TEST-01 | v0.5.4–v0.5.10 | archive/sprint/20260608_230821_… |

## 变更记录

- **2026-06-09** · **M-ARCH-01 §7 闭合** · v0.5.19–v0.5.26 · 199 passed · 审计快照已同步
- **2026-06-09** · **M-ARCH-01 Sprint 规划** · Suggestions 1–8 · handoff jwrun
- **2026-06-09** · **M-HTML-01 §7 闭合** · v0.5.15–v0.5.18
