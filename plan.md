# md2docx · 待办（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: T-TEST-03 -->
<!-- PLAN_APPROVED: 2026-06-09 -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: (none) -->
<!-- NEXT: (none) -->
<!-- LAST_DONE: T-TEST-03-06 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.41 -->
<!-- MAX_LOOPS: 15 -->

> 已完成 Sprint 见 [`archive/sprint/`](archive/sprint/)。文档索引 [`docs/README.md`](docs/README.md)。

**当前**：无活跃 Sprint · **275 passed** · **v0.5.41** · **待办 1 项（可选 ARCH-R03）**

---

## 已闭合 Sprint · T-TEST-03 样例资源补全与回归断言加强

> **WHY**：闭合后 **259 passed** · v0.5.37–v0.5.40 · 样例资源自洽、集成断言加强
> **参照**：[`archive/sprint/20260609_120000_样例资源补全_T-TEST-03_Sprint闭合_打版_v0.5.40.md`](archive/sprint/20260609_120000_样例资源补全_T-TEST-03_Sprint闭合_打版_v0.5.40.md)

**闭合条件**：P0 全部 ✅ · `tests/samples/basic/1.png` 存在且被 CI 引用 · `pytest -q` 全绿 · `docs/03` 与 `samples/output/README` 数字同步

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|
| T-TEST-03-01 | 补全 `tests/samples/basic/1.png`（最小合法 PNG） | P0 | ✅ | `test -f tests/samples/basic/1.png` · `file` 显示 PNG | `tests/samples/basic/1.png` |
| T-TEST-03-02 | `image.md` 样例端到端：本地图嵌入断言 | P0 | ✅ | `pytest -q tests/integration/test_full_conversion.py -k image` · `add_picture` 被调用 | `tests/integration/test_full_conversion.py` |
| T-TEST-03-03 | `flowcharts.md` 增补 `flowchart` 关键字样例 | P1 | ✅ | `grep -q flowchart tests/samples/advanced/flowcharts.md` · advanced 集成测通过 | `tests/samples/advanced/flowcharts.md` |
| T-TEST-03-04 | `math.md` 样例 `\label`/`\ref` 端到端断言 | P1 | ✅ | `pytest -q tests/integration/test_full_conversion.py -k math` · 文档含式号引用 | `tests/integration/test_full_conversion.py` |
| T-TEST-03-05 | 同步测试文档与 output README 基线 | P1 | ✅ | `docs/03_测试指南.md` · `tests/samples/output/README.md` 反映 1.png 与 passed 数 | `docs/` · `tests/samples/output/` |
| T-TEST-03-06 | 可选：大文档样例 `tests/samples/large/chunked.md` + 集成冒烟 | P2 | ✅ | `pytest -q tests/integration/test_full_conversion.py -k chunked` | `tests/samples/large/` |

**版本**：v0.5.37（01）→ v0.5.38（02/04/06）→ v0.5.39（03）→ v0.5.40（05）

### 闭合对照

| 原缺口 | 任务 | 闭合 |
|--------|------|------|
| `1.png` 缺失 | T-TEST-03-01 | ✅ 67B PNG |
| image 断言过浅 | T-TEST-03-02 | ✅ `add_picture` 断言 |
| 无 flowchart 样例 | T-TEST-03-03 | ✅ `flowchart LR` |
| math 样例无 ref 断言 | T-TEST-03-04 | ✅ 式号 (5) |
| 文档基线过期 | T-TEST-03-05 | ✅ 259 passed |
| 无 large 样例 | T-TEST-03-06 | ✅ `chunked.md` |

### 闭合快照（jwrun §7）

| 维度 | 规划时（jwplan） | 闭合后（jwrun） | 评价 |
|------|------------------|-----------------|------|
| 测试规模 | 256 passed | **259 passed** | ✅ +3 集成测 |
| 样例资源 | 缺 1.png | **1.png 就位** | ✅ |
| 断言深度 | 冒烟级 | **image/math/chunked 专项** | ✅ |
| 版本 | v0.5.36 | **v0.5.40** | ✅ |

**仍开放**：`output/` 无 docx 二进制（刻意保持）· journey/ER Mermaid 无样例

---

## ROADMAP · 待立项

| ID | 主题 | 状态 | 说明 |
|----|------|------|------|
| T-TEST-03 | 样例资源补全 | **已完成** | v0.5.37–v0.5.40 |
| ARCH-R03 | 可观测性 metrics | ⬜ 可选 | 下一 Sprint 按需 |

---

## 待办台账

| ID | 任务 | 状态 | 验收 / 落点 |
|----|------|------|-------------|
| ARCH-R03 | 可观测性 metrics（可选） | ⬜ | — |

---

## 变更记录

- **2026-06-09** · **v0.5.41** · 样例 DOCX 程序化验收 + 合法 1.png
- **2026-06-09** · **T-TEST-03 §7 闭合** · v0.5.37–v0.5.40 · 259 passed · 审计快照已同步
- **2026-06-09** · **T-TEST-03 Sprint 规划** · 样例 1.png · image/math 断言 · flowchart 样例 · 文档同步
- **2026-06-09** · **M-MERMAID-03 §7 闭合** · v0.5.36 · state/class/pie
