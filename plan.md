# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: M-MERMAID-01 -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: true -->
<!-- ACTIVE: M-MERMAID-01-03 -->
<!-- NEXT: M-MERMAID-01-04 -->
<!-- LAST_DONE: M-MERMAID-01-02 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.1 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。样例：[`tests/samples/advanced/flowcharts.md`](tests/samples/advanced/flowcharts.md)

## ROADMAP

| # | 主题 | 优先级 | 状态 | 备注 |
|---|------|--------|------|------|
| 3 | **Mermaid 流程图支持** | P1 | **活跃** | M-MERMAID-01 · v0.5.x |
| 1 | html2docx 可选依赖文档化 | P2 | 待立项 | T-HTML-01 |
| 2 | 数学公式 LaTeX 支持 | P1 | 待立项 | v0.5.0 |
| 4 | 双向转换 DOCX→MD | P2 | 待立项 | v0.6.0 |
| 5 | 插件系统基础 | P3 | 待立项 | v1.0.0 |
| 6 | 架构建议 Suggestions 1-8 | P3 | 远期 | |

## 活跃 Sprint · M-MERMAID-01 Mermaid 流程图支持

> **WHY**：`docs/plan.md` v0.5.0 · 当前 ` ```mermaid ` 块走 `CodeConverter` 纯文本输出（见 `tests/samples/output/README.md`）  
> **参照**：`flowcharts.md` 含 graph / sequence / state / class / gantt / pie  
> **原则**：渐进式 · 最小依赖 · 失败可回退 · 复用图片安全体系

### 架构决策（已确认，无需再问）

| 方案 | 结论 |
|------|------|
| 渲染方式 | **mermaid.ink** 公开渲染 API（服务端构造 URL，非用户任意 URL） |
| 嵌入方式 | PNG 字节流 → `python-docx` `add_picture`（复用 `ImageConverter` 模式） |
| 失败回退 | 渲染失败时保留 **Mermaid 源码代码块** + 段落提示「（Mermaid 渲染失败）」 |
| 依赖 | 核心 `requests` 已有；**不引入 Node/mmdc**；首版仅支持 **graph/flowchart TD** |
| 安全 | 白名单 `mermaid.ink` · 超时 · 响应体大小上限（复用 `MAX_IMAGE_BYTES`） |
| 版本线 | 本 Sprint 打版 **v0.5.x**（`VERSION_LINE: 0.5`） |

**首版范围（IN）**：`graph TD/LR` 基础流程图  
**延后（OUT）**：sequence/state/class/gantt/pie、WebUI 实时 Mermaid 预览、离线 mmdc

**闭合条件**：P0 全部 ✅ · `pytest -q` 绿 · 基础 graph 样例 DOCX 含图片

**执行顺序**：`M-MERMAID-01-01` → `M-MERMAID-01-02` → `M-MERMAID-01-03` → `M-MERMAID-01-04`

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|
| M-MERMAID-01-01 | `MermaidConverter` 骨架 + `base.py` 按 `info=mermaid` 路由 | P0 | ✅ | test -f src/mddocx/converter/elements/mermaid.py | mermaid.py · base.py |
| M-MERMAID-01-02 | mermaid.ink 渲染 PNG 并插入 DOCX（graph TD） | P0 | ✅ | pytest -q tests/unit/test_elements/test_mermaid.py | mermaid.py |
| M-MERMAID-01-03 | 安全白名单 + 失败回退源码块 | P0 | ✅ | pytest -q tests/unit/test_elements/test_mermaid.py -k security | security.py · mermaid.py |
| M-MERMAID-01-04 | 集成测试 + README 说明 | P1 | 🔧 | pytest -q tests/integration/test_mermaid_integration.py | tests/ · README.md |

### 现状（为何做）

- `base.py` 所有 `fence` token 统一交给 `CodeConverter`（`token.info` 未区分语言）
- `flowcharts.md` 已有 7 类 Mermaid 样例，但无对应测试与渲染

### 已具备（不必重复立项）

- `requests`、图片大小限制、`security.py` SSRF 模式可扩展白名单
- `tests/samples/advanced/flowcharts.md` 样例文件

## 已闭合 Sprint

| Sprint | 版本 | 归档 |
|--------|------|------|
| M-CONV-01 | v0.4.9–v0.4.10 | archive/sprint/20260608_225306_… |
| M-DOC-03 | v0.4.5–v0.4.8 | archive/sprint/20260608_225037_… |

## 变更记录

- **2026-06-08** · **M-MERMAID-01 Sprint 规划** · mermaid.ink 方案 · graph TD 首版 · handoff jwrun
- **2026-06-08** · M-CONV-01 §7 闭合 · v0.4.10
