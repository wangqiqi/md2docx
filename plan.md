# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: M-HTML-01 -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: true -->
<!-- ACTIVE: M-HTML-01-04 -->
<!-- NEXT: M-HTML-01-04 -->
<!-- LAST_DONE: M-HTML-01-03 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.17 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。样例：[`tests/samples/basic/html.md`](tests/samples/basic/html.md)

## ROADMAP

| # | 主题 | 优先级 | 状态 | 备注 |
|---|------|--------|------|------|
| 8 | **html-for-docx 迁移**（替代停更 html2docx） | P2 | **活跃** | M-HTML-01 · v0.5.15+ |
| 2 | **数学公式 LaTeX 支持** | P1 | **已完成** | M-MATH-01 · v0.5.11–v0.5.14 |
| 6 | 架构建议 Suggestions 1-8 | P3 | 远期 | |
| 7 | 测试体系补强 | P1 | 已完成 | T-TEST-01 · v0.5.4–v0.5.10 |
| 3 | Mermaid 流程图支持 | P1 | 已完成 | M-MERMAID-01 · v0.5.0–v0.5.3 |
| 1 | html2docx 可选依赖文档化 | P2 | 已完成 | T-TEST-01-05（将被 01 迁移 supersede） |

## 活跃 Sprint · M-HTML-01 html-for-docx 迁移

> **WHY**：Markdown 内嵌复杂 HTML 的回退路径依赖 **停更** 的 `html2docx`；迁到活跃维护的 **html-for-docx**（import `html4docx`），提升表格/CSS 渲染且不扩大产品边界（仍仅 MD 内 HTML，不做整文件 HTML→DOCX）。  
> **参照**：[`src/mddocx/converter/elements/html.py`](src/mddocx/converter/elements/html.py) · [`tests/samples/basic/html.md`](tests/samples/basic/html.md) · [html-for-docx PyPI](https://pypi.org/project/html-for-docx/)  
> **原则**：`pip install mddocx[html]` 额外名**不变**；无 `[html]` 时自研解析 + fallback 行为不变。

**闭合条件**：P0 全部 ✅ · `pytest -q` 全绿（187+ passed，skip 策略与现网一致）· `pip install -e ".[html]"` 后 html 相关 skip 用例可跑通 · CHANGELOG + tag v0.5.15

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|
| M-HTML-01-01 | optional-dep：`html2docx` → `html-for-docx>=1.1.0` | P0 | ✅ | `grep html-for-docx pyproject.toml` · `pip install -e ".[html]"` 成功 | `pyproject.toml` |
| M-HTML-01-02 | `HtmlConverter` 改用 `HtmlToDocx.add_html_to_document()`，去掉临时文件路径（或最小化） | P0 | ✅ | `pytest -q tests/unit/test_elements/test_html.py` | `src/mddocx/converter/elements/html.py` |
| M-HTML-01-03 | 测试：`HTML_FOR_DOCX_AVAILABLE` + 保留别名；集成测 complex html.md | P0 | ✅ | `pytest -q tests/unit/test_elements/test_html.py tests/integration/test_html_integration.py` | `tests/unit/test_elements/test_html.py` · `tests/integration/test_html_integration.py` |
| M-HTML-01-04 | 文档：testing.md / README 可选依赖说明更新 | P1 | 🔧 | 文档含 `html-for-docx` · 安装命令 `mddocx[html]` 不变 | `docs/testing.md` · `README.md` |

**执行顺序**：`M-HTML-01-01` → `M-HTML-01-02` → `M-HTML-01-03` → `M-HTML-01-04`

### 现状（为何做）

- `HtmlConverter` 三层：自研正则 → **html2docx**（写 temp .html/.docx 再合并）→ strip fallback
- `pqzx/html2docx` 停更、open issue 多；**html-for-docx** 为同一 API 家族的活跃 fork
- CI 默认不装 `[html]`；2 个 skip 用例属预期，迁移后本地/可选 CI job 应能跑通

### 已具备（不必重复立项）

- ✅ `mddocx[html]` optional-dependencies 结构（T-TEST-01-05）
- ✅ `tests/samples/basic/html.md` 样例与 HtmlConverter 单测骨架
- ✅ 自研 `_custom_html_convert` 简单标签路径（迁移后仍优先）

### 架构决策

| 决策 | 选择 |
|------|------|
| PyPI extra 名 | **保持 `html`**，不新增 breaking |
| 检测常量 | 新增 `HTML_FOR_DOCX_AVAILABLE`；`HTML2DOCX_AVAILABLE` 作**别名**一版，避免外部 import 破坏 |
| 产品边界 | **不**做 `.html` 文件 CLI；仅 MD 内 `html_block` |
| 最低版本 | `html-for-docx>=1.1.0` |

## 已闭合 Sprint

| Sprint | 版本 | 归档 |
|--------|------|------|
| M-MATH-01 | v0.5.11–v0.5.14 | [archive/sprint/20260609_074531_数学公式_M-MATH-01_Sprint闭合_打版_v0.5.14.md](archive/sprint/20260609_074531_数学公式_M-MATH-01_Sprint闭合_打版_v0.5.14.md) |
| T-TEST-01 | v0.5.4–v0.5.10 | [archive/sprint/20260608_230821_…](archive/sprint/20260608_230821_测试体系_T-TEST-01_Sprint闭合_打版_v0.5.10.md) |
| M-MERMAID-01 | v0.5.0–v0.5.3 | archive/sprint/20260608_225947_… |
| M-CONV-01 | v0.4.9–v0.4.10 | archive/sprint/20260608_225306_… |
| M-DOC-03 | v0.4.5–v0.4.8 | archive/sprint/20260608_225037_… |

## 变更记录

- **2026-06-08** · **M-HTML-01 Sprint 规划** · html-for-docx 迁移 · 4 任务 · handoff jwrun
- **2026-06-09** · **ROADMAP 调整** · 移除「插件系统」（定位：常见 Markdown → DOCX）
- **2026-06-09** · **ROADMAP 调整** · 移除「双向转换 DOCX→MD」（产品定位 md2docx 单向）
- **2026-06-09** · **M-MATH-01 §7 闭合** · v0.5.11–v0.5.14 · 187 passed · 审计快照已同步
- **2026-06-08** · **M-MATH-01 Sprint 规划** · dollarmath + CodeCogs PNG · handoff jwrun
