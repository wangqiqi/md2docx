# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: T-TEST-01 -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: (none) -->
<!-- NEXT: (none) -->
<!-- LAST_DONE: T-TEST-01-07 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.5 -->
<!-- RELEASED: v0.5.10 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。样例：[`tests/samples/advanced/flowcharts.md`](tests/samples/advanced/flowcharts.md)

## ROADMAP

| # | 主题 | 优先级 | 状态 | 备注 |
|---|------|--------|------|------|
| 7 | **测试体系补强** | P1 | **已完成** | T-TEST-01 · v0.5.4–v0.5.10 |
| 3 | Mermaid 流程图支持 | P1 | 已完成 | M-MERMAID-01 · v0.5.0–v0.5.3 |
| 1 | html2docx 可选依赖文档化 | P2 | 并入 T-TEST-01-05 | 原 T-HTML-01 |
| 2 | 数学公式 LaTeX 支持 | P1 | 待立项 | v0.5.x+ |
| 4 | 双向转换 DOCX→MD | P2 | 待立项 | v0.6.0 |
| 5 | 插件系统基础 | P3 | 待立项 | v1.0.0 |
| 6 | 架构建议 Suggestions 1-8 | P3 | 远期 | |

## 活跃 Sprint · T-TEST-01 测试体系补强

> **WHY**：`/jwplan` 审计 `tests/` — 体系**扎实但不完备**（169 passed · 81% cov），样例覆盖与断言深度不足  
> **参照**：`审查.md` §测试缺口 · `docs/testing.md` · 当前 `pytest --cov=src` 报告  
> **原则**：先补 P0 回归风险 · 断言由弱到强 · 不引入真实外网依赖

### 测试体系审计结论（2026-06-08）

| 维度 | 现状 | 评价 |
|------|------|------|
| **规模** | 171 用例 · **169 passed, 2 skipped** | ✅ 数量充足 |
| **分层** | unit / integration / webui 三层齐全 | ✅ 结构合理 |
| **元素覆盖** | 13 个 converter 均有对应 `test_*.py`（含 mermaid） | ✅ 模块映射完整 |
| **CI** | `tests/` + `webui/tests/` · 多 Python 版本 | ✅ 已对齐审查 M6 |
| **覆盖率** | 整体 **81%**（审查时 67%） | ✅ 达标；`html.py` **60%** 仍偏低 |
| **安全测试** | `test_security.py` 11 项（路径/SSRF/mermaid 白名单） | ✅ 基础具备 |
| **样例数据** | `samples/basic` 纳入集成；**`advanced/` 与 `test.md` 未自动化** | ⚠️ 缺口 |
| **断言深度** | `test_convert_all_samples` 仅 `size>0`；WebUI 连续转换仅验状态码 | ⚠️ 弱断言 |
| **可选依赖** | html2docx 路径 2 skipped · 无 optional-deps 文档 | ⚠️ 缺口 |
| **性能/e2e** | 无 benchmark · 无 `batch_convert` 脚本测试 | 🔲 远期 |

**结论**：测试体系**不算完备**，但已达到「可回归、可 CI」基线；主要债务在 **样例覆盖不全、集成断言偏浅、html/WebUI 深路径**。

### 架构决策（已确认）

| 方案 | 结论 |
|------|------|
| 样例策略 | 扩展 `conftest`：`samples_basic` + `samples_advanced`；advanced 中 mermaid 用 mock |
| 断言策略 | 集成测试增加关键文本/结构断言，**首版不做 golden DOCX 二进制对比** |
| 外网 | 图片/mermaid 集成继续 mock，不增加真实网络用例 |
| html2docx | 文档化 optional-deps；CI 保持 skip，不强制安装 |
| 版本线 | 本 Sprint 打版 **v0.5.4+**（`VERSION_LINE: 0.5`） |

**首版范围（IN）**：advanced 样例纳入 · 集成断言加强 · WebUI/CLI 深路径  
**延后（OUT）**：golden file · 真实网络 · pytest-benchmark · `start_webui.py` 覆盖

**闭合条件**：P0 全部 ✅ · `pytest -q` 绿 · `docs/testing.md` 基线同步

**执行顺序**：`T-TEST-01-01` → `T-TEST-01-02` → `T-TEST-01-03` → `T-TEST-01-04` → `T-TEST-01-05` → `T-TEST-01-06` → `T-TEST-01-07`

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|
| T-TEST-01-01 | `samples/advanced` + `test.md` 纳入集成测试 | P0 | ✅ | pytest -q tests/integration/test_full_conversion.py -k advanced | conftest.py · test_full_conversion.py |
| T-TEST-01-02 | `test_convert_all_samples` 增强结构/文本断言 | P0 | ✅ | pytest -q tests/integration/test_full_conversion.py | test_full_conversion.py |
| T-TEST-01-03 | WebUI 连续转换内容独立性断言（非仅状态码） | P0 | ✅ | pytest -q src/mddocx/webui/tests/test_basic.py -k accumulate | webui/tests/test_basic.py |
| T-TEST-01-04 | CLI `--lang en` 帮助/输出端到端 | P0 | ✅ | pytest -q tests/unit/test_cli.py -k lang | test_cli.py |
| T-TEST-01-05 | html2docx optional-deps + skip 策略文档化 | P1 | ✅ | grep -q html2docx pyproject.toml && pytest -q tests/unit/test_elements/test_html.py | pyproject.toml · docs/testing.md |
| T-TEST-01-06 | `BaseConverter` token 路由边界单测（fence/mermaid/html） | P1 | ✅ | pytest -q tests/unit/test_base_converter.py | tests/unit/test_base_converter.py |
| T-TEST-01-07 | 同步 `docs/testing.md` / `samples/output/README` 基线 | P1 | ✅ | grep -q '176 passed' docs/testing.md | docs/testing.md · samples/output/README.md |

### 现状（为何做）

- `conftest.samples_dir` 仅指向 `basic/`，`flowcharts.md` 等 advanced 样例无自动化回归
- `test_multiple_converts_do_not_accumulate`（WebUI）未验证 DOCX/响应内容隔离
- `审查.md` P2「修复 conftest」已简化修复，但「样例深度覆盖」仍未闭合

### 已具备（不必重复立项）

- 元素级单测齐全；`test_converter_reuse_does_not_accumulate` 覆盖 BaseConverter 复用
- CI 已含 WebUI；security 单测；Mermaid mock 测试模式可复用

## 已闭合 Sprint

| Sprint | 版本 | 归档 |
|--------|------|------|
| T-TEST-01 | v0.5.4–v0.5.10 | archive/sprint/（待 §7 归档） |
| M-MERMAID-01 | v0.5.0–v0.5.3 | archive/sprint/20260608_225947_… |
| M-CONV-01 | v0.4.9–v0.4.10 | archive/sprint/20260608_225306_… |
| M-DOC-03 | v0.4.5–v0.4.8 | archive/sprint/20260608_225037_… |

## 变更记录

- **2026-06-08** · **T-TEST-01 §7 闭合** · v0.5.4–v0.5.10 · 176 passed
- **2026-06-08** · **T-TEST-01 Sprint 规划** · 测试体系审计：扎实但不完备 · 7 项补强 · handoff jwrun
- **2026-06-08** · **M-MERMAID-01 §7 闭合** · v0.5.0–v0.5.3 · 169 passed
- **2026-06-08** · **M-MERMAID-01 Sprint 规划** · mermaid.ink 方案 · graph TD 首版 · handoff jwrun
- **2026-06-08** · M-CONV-01 §7 闭合 · v0.4.10
