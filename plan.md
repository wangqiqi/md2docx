# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: M-MATH-01 -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: true -->
<!-- ACTIVE: M-MATH-01-02 -->
<!-- NEXT: M-MATH-01-03 -->
<!-- LAST_DONE: M-MATH-01-01 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.11 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。样例：[`tests/samples/advanced/math.md`](tests/samples/advanced/math.md)

## ROADMAP

| # | 主题 | 优先级 | 状态 | 备注 |
|---|------|--------|------|------|
| 2 | **数学公式 LaTeX 支持** | P1 | **活跃** | M-MATH-01 · v0.5.11+ |
| 4 | 双向转换 DOCX→MD | P2 | 待立项 | v0.6.0 |
| 5 | 插件系统基础 | P3 | 待立项 | v1.0.0 |
| 6 | 架构建议 Suggestions 1-8 | P3 | 远期 | |
| 7 | 测试体系补强 | P1 | 已完成 | T-TEST-01 · v0.5.4–v0.5.10 |
| 3 | Mermaid 流程图支持 | P1 | 已完成 | M-MERMAID-01 · v0.5.0–v0.5.3 |
| 1 | html2docx 可选依赖文档化 | P2 | 已完成 | T-TEST-01-05 |

## 活跃 Sprint · M-MATH-01 数学公式 LaTeX 支持

> **WHY**：`docs/plan.md` v0.5.x · ROADMAP #2 · 当前 `$…$` / `$$…$$` 按纯文本输出（见 `tests/samples/output/README.md` advanced_math）  
> **参照**：`tests/samples/advanced/math.md` · M-MERMAID-01 渲染嵌入模式 · `审查.md` 无 math 专项  
> **原则**：渐进式 · 复用图片安全体系 · 失败回退 LaTeX 源码 · 不引入 Node/Pandoc

### 架构决策（已确认，无需再问）

| 方案 | 结论 |
|------|------|
| 解析 | **`mdit-py-plugins` `dollarmath`** → `math_inline` / `math_block` token（新增依赖） |
| 渲染 | **latex.codecogs.com** PNG API（服务端构造 URL，非用户任意 URL） |
| 嵌入 | PNG 字节流 → `add_picture`（复用 Mermaid/Image 模式） |
| 失败回退 | 渲染失败保留 **LaTeX 源码** + 灰色提示「（公式渲染失败，已保留源码）」 |
| 安全 | 白名单 `latex.codecogs.com` · 超时 · `MAX_IMAGE_BYTES` · URL 长度上限 |
| 版本线 | 本 Sprint **v0.5.11+**（`VERSION_LINE: 0.5`） |

**首版范围（IN）**：行内 `$…$`、块级 `$$…$$`；分数/希腊字母/求和/简单矩阵（math.md 前几节）  
**延后（OUT）**：公式编号与 `\ref` · `\begin{align}` 多行对齐 · OMML 原生公式 · 离线 LaTeX 引擎

**闭合条件**：P0 全部 ✅ · `pytest -q` 绿 · `math.md` 基础公式 DOCX 含图片或合理回退

**执行顺序**：`M-MATH-01-01` → `M-MATH-01-02` → `M-MATH-01-03` → `M-MATH-01-04`

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|
| M-MATH-01-01 | 添加 `mdit-py-plugins` + `MathConverter` 骨架 + `base.py` 路由 math token | P0 | ✅ | test -f src/mddocx/converter/elements/math.py | math.py · base.py · pyproject.toml |
| M-MATH-01-02 | CodeCogs 渲染 PNG 并插入 DOCX（行内/块级） | P0 | 🔧 | pytest -q tests/unit/test_elements/test_math.py | math.py |
| M-MATH-01-03 | 白名单 URL + 渲染失败回退 LaTeX 源码 | P0 | ⬜ | pytest -q tests/unit/test_elements/test_math.py -k security | security.py · math.py |
| M-MATH-01-04 | 集成测试（math.md mock）+ README 说明 | P1 | ⬜ | pytest -q tests/integration/test_math_integration.py | tests/ · README.md |

### 现状（为何做）

- `MarkdownIt("commonmark")` 未启用 math；`$E=mc^2$` 原样进段落文本
- `tests/samples/advanced/math.md` 已有 7 类样例，集成测试未覆盖公式路径
- Mermaid Sprint 已验证「外部渲染 PNG + 白名单 + mock 测试」模式，可直接复用

### 已具备（不必重复立项）

- `requests`、 `security.py` 白名单模式、`MermaidConverter` 可作模板
- `test_full_conversion` 已遍历 advanced 样例（math 块当前仅验标题存在）

## 已闭合 Sprint

| Sprint | 版本 | 归档 |
|--------|------|------|
| T-TEST-01 | v0.5.4–v0.5.10 | [archive/sprint/20260608_230821_测试体系_T-TEST-01_Sprint闭合_打版_v0.5.10.md](archive/sprint/20260608_230821_测试体系_T-TEST-01_Sprint闭合_打版_v0.5.10.md) |
| M-MERMAID-01 | v0.5.0–v0.5.3 | archive/sprint/20260608_225947_… |
| M-CONV-01 | v0.4.9–v0.4.10 | archive/sprint/20260608_225306_… |
| M-DOC-03 | v0.4.5–v0.4.8 | archive/sprint/20260608_225037_… |

## 变更记录

- **2026-06-08** · **M-MATH-01 Sprint 规划** · dollarmath + CodeCogs PNG · 行内/块级首版 · handoff jwrun
- **2026-06-08** · plan 审计快照同步 · jwrun-skill §7B 刷新审计快照
- **2026-06-08** · **T-TEST-01 §7 闭合** · v0.5.4–v0.5.10 · 176 passed
- **2026-06-08** · **M-MERMAID-01 §7 闭合** · v0.5.0–v0.5.3
