# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: (none) -->
<!-- PLAN_APPROVED: 2026-06-09 -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: (none) -->
<!-- NEXT: (none) -->
<!-- LAST_DONE: M-DOC-04-06 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.28 -->
<!-- MAX_LOOPS: 20 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。Sprint 闭合详情见 [`archive/sprint/`](archive/sprint/)。审查来源：[`审查.md`](审查.md)

**当前状态**：无活跃 Sprint · **199 passed** · 最新 **v0.5.28** · 待办 **14 项**

---

## 已闭合 Sprint · M-DOC-04（文档与审查清单同步）

> **WHY**：台账 F 组 + 审查行动计划与代码脱节 · **闭合**：v0.5.27–v0.5.28 · 199 passed

**执行顺序**：M-DOC-04-01 → … → M-DOC-04-06

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 | Tag |
|----|------|--------|------|------|------|-----|
| M-DOC-04-01 | 审查.md 行动计划 checkbox 同步 | P2 | ✅ | `grep -q '\[x\].*BaseConverter' 审查.md` | `审查.md` | v0.5.27 |
| M-DOC-04-02 | webui README HOST/安装/CSRF | P2 | ✅ | `grep -q '127.0.0.1' src/mddocx/webui/README.md` | `src/mddocx/webui/README.md` | v0.5.28 |
| M-DOC-04-03 | 删除过时 requirements.txt 引用 | P2 | ✅ | `! grep -q 'requirements\.txt' docs/development.md` | `docs/development.md` | v0.5.28 |
| M-DOC-04-04 | README 版本/测试数/路线图同步 | P2 | ✅ | `grep -q '0.5.26' README.md && grep -q '199' README.md` | `README.md` | v0.5.28 |
| M-DOC-04-05 | architecture.md 结构刷新 | P2 | ✅ | `grep -q 'token_processor' docs/architecture.md` | `docs/architecture.md` | v0.5.28 |
| M-DOC-04-06 | docs/plan.md ROADMAP 同步 | P2 | ✅ | `grep -q 'M-MATH-01' docs/plan.md` | `docs/plan.md` | v0.5.28 |

---

## ROADMAP

### 已完成

| # | 主题 | Sprint / 版本 |
|---|------|---------------|
| 6 | 架构建议 Suggestions 1–8（首版） | M-ARCH-01 · v0.5.19–v0.5.26 |
| 8 | html-for-docx 迁移 | M-HTML-01 · v0.5.15–v0.5.18 |
| 2 | 数学公式 LaTeX | M-MATH-01 · v0.5.11–v0.5.14 |
| 7 | 测试体系补强 | T-TEST-01 · v0.5.4–v0.5.10 |
| 3 | Mermaid 流程图（graph/flowchart） | M-MERMAID-01 · v0.5.0–v0.5.3 |
| 1 | html2docx 文档化 | → M-HTML-01 |
| 11 | 文档与审查清单同步 | M-DOC-04 · v0.5.27–v0.5.28 |

### 待立项（ROADMAP）

| # | 主题 | 优先级 | 建议 Sprint |
|---|------|--------|-------------|
| 9 | M-ARCH 残余（mypy 全量 / 流式转换） | P2 | M-MYPY-01 / M-PERF-01 |
| 10 | 审查 Minor 代码质量 | P3 | M-MINOR-01 |
| 12 | Mermaid 扩展（sequence / gantt） | P2 | M-MERMAID-02 |
| 13 | 公式编号与 `\ref` | P2 | M-MATH-02 |
| 14 | 测试覆盖率与缺口补强 | P2 | T-TEST-02 |

**下一 Sprint 建议**：**M-MYPY-01** 或 **M-MINOR-01**

## 全量任务台账

> 状态：**✅ 已完成** · **⬜ 待办** · **🔶 部分完成**（M-ARCH 首版已交付，残余列在 B 组）

### A. 审查报告 · P0/P1（[`审查.md`](审查.md) 行动计划）

| ID | 任务 | 来源 | 状态 | 闭合参考 |
|----|------|------|------|----------|
| REV-P0-01 | `BaseConverter` 每次 convert 重置状态 | C3 / 阶段一 | ✅ | v0.4.x `_reset_state` |
| REV-P0-02 | WebUI per-request 转换器实例 | C3 | ✅ | v0.4.x |
| REV-P0-03 | `pyproject.toml` 添加 `requests` | C2 | ✅ | v0.4.x |
| REV-P0-04 | 图片路径校验 + SSRF 防护 | C4 / M5 | ✅ | `security.py` · v0.4.x |
| REV-P1-01 | 删除 CLI 重复 `parse_args()` | M1 | ✅ | T-TEST-01-04 |
| REV-P1-02 | 预览 HTML 消毒 + CSP | M2 | ✅ | bleach · v0.4.x |
| REV-P1-03 | CSRF 防护 | M3 | ✅ | Flask-WTF · v0.4.x |
| REV-P1-04 | CI 纳入 WebUI 测试 | M6 | ✅ | T-TEST-01 |
| REV-P1-05 | CHANGELOG / README 同步 | M7/M10/M11 | ✅ | M-DOC-04-04 |
| REV-P1-06 | 开发默认 `127.0.0.1` / 生产 SECRET_KEY | M4 | ✅ | M-DOC-04-02 webui README |
| REV-P1-07 | 删除过时 `requirements*.txt` 引用 | M8 | ✅ | M-DOC-04-03 |
| REV-P2-01 | `conftest.py` converter fixture | M9 / 阶段三 | ✅ | T-TEST-01 |
| REV-P2-02 | 预览与转换 MarkdownIt 配置一致 | m6 / 阶段三 | ⬜ | 预览缺 dollarmath 等 |
| REV-P2-03 | html 覆盖率 + html-for-docx 文档 | M12 / 阶段三 | ✅ | M-HTML-01 |
| REV-P2-04 | `base.py` token 遍历重构 | S1 / 阶段三 | ✅ | M-ARCH-01-08 · TokenProcessor |
| REV-P2-05 | 补齐 `architecture.md` / `testing.md` | m8/m9 / 阶段三 | 🔶 | architecture ✅；testing 待 T-TEST-02 |

### B. M-ARCH-01 · Suggestions 1–8 残余

| ID | 任务 | 来源 | 状态 | 验收（规划） |
|----|------|------|------|--------------|
| ARCH-R01 | elements 包 **strict mypy**（CI 必过） | S2 残余 | ⬜ | `mypy src/mddocx/converter --config-file mypy.ini` 退出 0 |
| ARCH-R02 | 大文件 **流式/分块** 转换 | S3 残余 | ⬜ | 设计文档 + 1MB+ 样例不 OOM |
| ARCH-R03 | 可观测性 **metrics**（Prometheus 等） | S4 扩展 | ⬜ | 可选；当前仅 INFO 日志 |

### C. 审查报告 · Minor（[`审查.md`](审查.md) §一般问题）

| ID | 任务 | 来源 | 状态 | 落点 |
|----|------|------|------|------|
| MIN-01 | `convert()` 异常勿一律包装丢失类型 | m1 | ⬜ | `converter/base.py` |
| MIN-02 | `BlockquoteConverter` 支持链接/删除线/行内代码 | m2 | ⬜ | `elements/blockquote.py` |
| MIN-03 | `TableConverter` 对齐改用枚举非常数 | m3 | ⬜ | `elements/table.py` |
| MIN-04 | `TableConverter.__init__` 传递 `base_converter` | m4 | ⬜ | `elements/table.py` |
| MIN-05 | WebUI 移除冗余 `sys.path` 操作 | m5 | ⬜ | `webui/` |
| MIN-06 | 预览 MarkdownIt 与 BaseConverter 插件对齐 | m6 | ⬜ | `webui/app.py` · `base.py` |
| MIN-07 | `test_full_conversion.py` 重复模块 docstring | m7 | ⬜ | `tests/integration/` |
| MIN-08 | 图片缓存 LRU | m10 | ✅ | `MAX_IMAGE_CACHE_ENTRIES=64` |

### D. 测试缺口（[`审查.md`](审查.md) §测试与质量）

| ID | 任务 | 状态 | 验收 |
|----|------|------|------|
| TEST-G01 | 在线图片真实网络集成测（可选 mock 加强） | ⬜ | `tests/integration/test_image_integration.py` |
| TEST-G02 | 整体覆盖率提升（目标 ≥85%） | ⬜ | `pytest --cov=src --cov-report=term` |
| TEST-G03 | `html.py` 覆盖率提升 | ⬜ | `pytest --cov=src/mddocx/converter/elements/html.py` |

### E. 产品增强（[`README.md`](README.md) 规划中）

| ID | 任务 | 优先级 | 状态 | 验收 |
|----|------|--------|------|------|
| FEAT-01 | Mermaid **sequenceDiagram / gantt** 等 | P2 | ⬜ | 样例 md + 集成测 |
| FEAT-02 | 公式 **编号与 `\ref` 引用** | P2 | ⬜ | OMML/PNG 策略文档 + 样例 |

### F. 文档与元数据同步

| ID | 任务 | 状态 | 落点 |
|----|------|------|------|
| DOC-01 | 更新 [`审查.md`](审查.md) 行动计划 checkbox（✅/⬜ 与本文一致） | ✅ | `审查.md` |
| DOC-02 | 同步 [`docs/architecture.md`](docs/architecture.md)（webui、版本、结构） | ✅ | `docs/architecture.md` |
| DOC-03 | 同步 [`README.md`](README.md)（测试数 199、版本 badge、开发中段落） | ✅ | `README.md` |
| DOC-04 | 修正 [`src/mddocx/webui/README.md`](src/mddocx/webui/README.md) HOST 说明 | ✅ | `src/mddocx/webui/README.md` |
| DOC-05 | 同步 [`docs/plan.md`](docs/plan.md) 与根 `plan.md` ROADMAP | ✅ | `docs/plan.md` |

---

## 待办统计

| 分组 | ✅ | 🔶 | ⬜ |
|------|----|----|-----|
| A 审查 P0/P1/P2 | 14 | 1 | 1 |
| B M-ARCH 残余 | 0 | 0 | 3 |
| C Minor | 1 | 0 | 6 |
| D 测试缺口 | 0 | 0 | 3 |
| E 产品增强 | 0 | 0 | 2 |
| F 文档同步 | 5 | 0 | 0 |
| **合计** | **20** | **1** | **15** |

---

## 已闭合 Sprint（索引）

| Sprint | 版本 | 归档 |
|--------|------|------|
| M-DOC-04 | v0.5.27–v0.5.28 | [archive/sprint/20260609_080940_文档同步_M-DOC-04_Sprint闭合_打版_v0.5.28.md](archive/sprint/20260609_080940_文档同步_M-DOC-04_Sprint闭合_打版_v0.5.28.md) |
| M-ARCH-01 | v0.5.19–v0.5.26 | [archive/sprint/20260609_080200_架构建议_M-ARCH-01_Sprint闭合_打版_v0.5.26.md](archive/sprint/20260609_080200_架构建议_M-ARCH-01_Sprint闭合_打版_v0.5.26.md) |
| M-HTML-01 | v0.5.15–v0.5.18 | [archive/sprint/20260609_075534_html-for-docx_M-HTML-01_Sprint闭合_打版_v0.5.18.md](archive/sprint/20260609_075534_html-for-docx_M-HTML-01_Sprint闭合_打版_v0.5.18.md) |
| M-MATH-01 | v0.5.11–v0.5.14 | [archive/sprint/20260609_074531_数学公式_M-MATH-01_Sprint闭合_打版_v0.5.14.md](archive/sprint/20260609_074531_数学公式_M-MATH-01_Sprint闭合_打版_v0.5.14.md) |
| T-TEST-01 | v0.5.4–v0.5.10 | [archive/sprint/20260608_230821_测试体系_T-TEST-01_Sprint闭合_打版_v0.5.10.md](archive/sprint/20260608_230821_测试体系_T-TEST-01_Sprint闭合_打版_v0.5.10.md) |
| M-MERMAID-01 | v0.5.0–v0.5.3 | archive/sprint/20260608_225947_… |
| M-CONV-01 | v0.4.9–v0.4.10 | archive/sprint/20260608_225306_… |
| M-DOC-03 | v0.4.5–v0.4.8 | archive/sprint/20260608_225037_… |

## 变更记录

- **2026-06-09** · **M-DOC-04 §7 闭合** · v0.5.27–v0.5.28 · 199 passed · ROADMAP #11 ✅
- **2026-06-09** · **v0.5.27 打版** · jwplan 台账 + 审查.md 同步 + 移除 roundtrip demo
- **2026-06-09** · **jwplan 全量台账** · 审查+M-ARCH 残余+Minor+产品+文档 · 22 项待办写入 plan
- **2026-06-09** · plan 精简 · M-ARCH-01 审计移入 archive
- **2026-06-09** · **M-ARCH-01 §7 闭合** · v0.5.19–v0.5.26 · 199 passed
