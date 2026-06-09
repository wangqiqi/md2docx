# md2docx · 待办（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: T-TEST-03 -->
<!-- PLAN_APPROVED: 2026-06-09 -->
<!-- AUTONOMOUS: true -->
<!-- ACTIVE: T-TEST-03-02 -->
<!-- NEXT: T-TEST-03-02 -->
<!-- LAST_DONE: T-TEST-03-01 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.37 -->
<!-- MAX_LOOPS: 15 -->

> 已完成 Sprint 见 [`archive/sprint/`](archive/sprint/)。文档索引 [`docs/README.md`](docs/README.md)。

**当前**：活跃 Sprint **T-TEST-03** · **256 passed** · **v0.5.36** · **待办 6 项（P0×2）**

---

## 活跃 Sprint · T-TEST-03 样例资源补全与回归断言加强

> **WHY**：`tests/samples` 语法覆盖较全，但 `basic/image.md`、`basic/tables.md` 引用 `1.png` 而资源缺失；集成测对 `image`/`math` 样例断言偏浅，无法保证样例自洽与编号公式端到端。
> **参照**：上轮样例审计 · `tests/integration/test_full_conversion.py` · `docs/03_测试指南.md`
> **原则**：最小 diff · 样例即契约 · 不引入 golden docx 二进制对比

**闭合条件**：P0 全部 ✅ · `tests/samples/basic/1.png` 存在且被 CI 引用 · `pytest -q` 全绿 · `docs/03` 与 `samples/output/README` 数字同步

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|
| T-TEST-03-01 | 补全 `tests/samples/basic/1.png`（最小合法 PNG） | P0 | ✅ | `test -f tests/samples/basic/1.png` · `file` 显示 PNG | `tests/samples/basic/1.png` |
| T-TEST-03-02 | `image.md` 样例端到端：本地图嵌入断言 | P0 | ⬜ | `pytest -q tests/integration/test_full_conversion.py -k image` · `add_picture` 被调用 | `tests/integration/test_full_conversion.py` |
| T-TEST-03-03 | `flowcharts.md` 增补 `flowchart` 关键字样例 | P1 | ⬜ | `grep -q flowchart tests/samples/advanced/flowcharts.md` · advanced 集成测通过 | `tests/samples/advanced/flowcharts.md` |
| T-TEST-03-04 | `math.md` 样例 `\label`/`\ref` 端到端断言 | P1 | ⬜ | `pytest -q tests/integration/test_full_conversion.py -k math` · 文档含式号引用 | `tests/integration/test_full_conversion.py` |
| T-TEST-03-05 | 同步测试文档与 output README 基线 | P1 | ⬜ | `docs/03_测试指南.md` · `tests/samples/output/README.md` 反映 1.png 与 passed 数 | `docs/` · `tests/samples/output/` |
| T-TEST-03-06 | 可选：大文档样例 `tests/samples/large/chunked.md` + 集成冒烟 | P2 | ⬜ | `pytest -q tests/integration/test_full_conversion.py -k chunked` 或跳过并文档说明 | `tests/samples/large/` |

**执行顺序**：`T-TEST-03-01` → `T-TEST-03-02` → `T-TEST-03-03` → `T-TEST-03-04` → `T-TEST-03-05` → `T-TEST-03-06`

### 现状（为何做）

- `basic/` 目录 10 个 `.md`，无配套图片；`image.md` 七处引用 `1.png`
- `test_convert_all_samples` 对 `image` 仅 `len(text)>0`，未验证图片嵌入
- `advanced/math.md` 已有 `\label{eq:sum}` / `\ref{eq:sum}`，样例遍历无专门断言
- `flowchart` 前缀在 `mermaid.py` 支持，样例仅有 `graph TD`
- `output/` 仅 README，无 docx（保持现状，不纳入本 Sprint P0）

### 已具备（不必重复立项）

- `test_image_integration.py` 在 tmp 自建 PNG，覆盖本地/远程/错误
- `test_large_files.py` 覆盖分块逻辑；P2 仅补样例级冒烟
- Mermaid 七类已在 `flowcharts.md`；单元测在 `test_mermaid.py`
- 公式编号单元测在 `test_math.py` / `test_math_integration.py`

---

## ROADMAP · 待立项

| ID | 主题 | 状态 | 说明 |
|----|------|------|------|
| T-TEST-03 | 样例资源补全 | **活跃** | 本 Sprint |
| ARCH-R03 | 可观测性 metrics | ⬜ 可选 | Sprint 后按需 |

---

## 待办台账

| ID | 任务 | 状态 | 验收 / 落点 |
|----|------|------|-------------|
| ARCH-R03 | 可观测性 metrics（可选） | ⬜ | — |

---

## 变更记录

- **2026-06-09** · **T-TEST-03 Sprint 规划** · 样例 1.png · image/math 断言 · flowchart 样例 · 文档同步
- **2026-06-09** · **M-MERMAID-03 §7 闭合** · v0.5.36 · state/class/pie
- **2026-06-09** · **M-MATH-02 §7 闭合** · v0.5.35
