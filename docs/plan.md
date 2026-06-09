# 项目进化规划

> **Sprint 编排真源**见仓库根目录 [`plan.md`](../plan.md)（jwplan / jwrun）。本文档为产品愿景与 ROADMAP 摘要。

## 🎯 项目愿景

打造专注、可靠的**常见 Markdown → DOCX** 转换工具（单向转换，非双向、非插件框架）。

## 📋 当前状态（v0.5.26）

- **测试**：199 passed（含 WebUI）
- **核心能力**：标题/列表/表格/代码/图片/任务列表/HTML 块/Mermaid/LaTeX
- **WebUI**：Flask · bleach 预览 · CSRF · 限流 · 默认 `127.0.0.1`

## ✅ 已闭合 Sprint（摘要）

| Sprint | 版本 | 主题 |
|--------|------|------|
| M-MERMAID-01 | v0.5.0–v0.5.3 | Mermaid graph/flowchart |
| T-TEST-01 | v0.5.4–v0.5.10 | 测试体系补强 |
| M-MATH-01 | v0.5.11–v0.5.14 | LaTeX 数学公式 |
| M-HTML-01 | v0.5.15–v0.5.18 | html-for-docx 迁移 |
| M-ARCH-01 | v0.5.19–v0.5.26 | 架构建议 Suggestions 1–8 |

## 🚀 ROADMAP · 待立项

| # | 主题 | 建议 Sprint |
|---|------|-------------|
| 9 | M-ARCH 残余（mypy 全量 / 流式转换） | M-MYPY-01 / M-PERF-01 |
| 10 | 审查 Minor 代码质量 | M-MINOR-01 |
| 11 | 文档与审查清单同步 | **M-DOC-04**（进行中） |
| 12 | Mermaid 扩展（sequence / gantt） | M-MERMAID-02 |
| 13 | 公式编号与 `\ref` | M-MATH-02 |
| 14 | 测试覆盖率与缺口补强 | T-TEST-02 |

## 📋 产品增强（规划中）

- Mermaid **sequenceDiagram / gantt** 等扩展类型
- 公式 **编号与 `\ref` 引用**

## 🔲 技术债务（见根 plan 台账）

- elements 包 strict mypy
- 大文件流式/分块转换
- 预览与转换 MarkdownIt 插件对齐（dollarmath）
- Blockquote/Table Minor 改进

## 📊 历史 Phase（归档摘要）

- **Phase 1** 质量基础：CI/CD、覆盖率、pre-commit ✅
- **Phase 2** WebUI：预览、上传、响应式 ✅
- **Phase 3** 高级功能：Mermaid、LaTeX、html-for-docx ✅

---

*最后更新: 2026-06-09 · 与根 [`plan.md`](../plan.md) M-DOC-04 同步*
