# md2docx · Sprint 编排（jwplan / jwrun 真源）

<!-- PLANNING: false -->
<!-- SPRINT: M-DOC-03 -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: M-DOC-03-03 -->
<!-- NEXT: M-DOC-03-03 -->
<!-- LAST_DONE: M-DOC-03-02 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.4 -->
<!-- RELEASED: v0.4.6 -->
<!-- MAX_LOOPS: 15 -->

> 产品愿景见 [`docs/plan.md`](docs/plan.md)。审查依据：[`审查.md`](审查.md)

## ROADMAP

| 主题 | 优先级 | 状态 | 备注 |
|------|--------|------|------|
| 审查报告代码项（C/M P0-P1） | P0 | **已闭合** | v0.4.4 · 4C + 10M 代码/安全/CI |
| 审查报告文档收尾（M-DOC-02） | P0 | **已闭合** | api.md · README 依赖/段落 |
| 审查报告残余文档（M-DOC-03） | P1 | **活跃** | architecture/testing/README 发布节 |
| 审查报告残余代码（M-CONV-01） | P2 | 待立项 | blockquote 内联 · 异常类型保留 |
| html2docx 可选依赖文档化 | P2 | 待立项 | M12 · `pip install mddocx[html]` |
| 架构建议（Suggestions 1-8） | P3 | 远期 | token 重构 · mypy · Docker 等 |
| 数学公式 LaTeX 支持 | P1 | 待立项 | docs/plan.md |
| Mermaid 流程图支持 | P1 | 待立项 | |
| jwplan/jwrun 工作流迁移 | P0 | 已闭合 | 2026-06-08 |

## 审查.md 完成度审计（2026-06-08）

> **结论：未全部完成。** 可执行的 **安全/稳定性缺陷（C + M 代码项）已在 v0.4.4 闭合**；**一般问题 4/10 未做**；**建议改进 8/8 未做**。

| 类别 | 总数 | 已完成 | 未完成 | 说明 |
|------|------|--------|--------|------|
| Critical | 4 | **4** | 0 | C1–C4 均已修复 |
| Major（代码/CI/安全） | 9 | **9** | 0 | M1–M6、M9、M11 + M4 开发默认 127.0.0.1 |
| Major（文档） | 3 | **2** | **1** | M7/M10 大部分完成；README 发布节仍写 v0.4.3、`batch_convert_test.py` |
| Major（M8/M12） | 2 | **1** | **1** | `requirements-prod.txt` 已存在；README 改口「仅 pyproject」不一致；html2docx 已入 optional 未文档化 |
| Minor | 10 | **6** | **4** | 未完成：m1 宽泛异常、m2 引用块内联、m8 architecture、m9 testing |
| Suggestions | 8 | 0 | **8** | 架构/可观测性/Docker 等远期项 |

## 活跃 Sprint · M-DOC-03 审查残余文档同步

> **WHY**：`审查.md` 行动计划第三阶段「补齐 architecture.md / testing.md」及 M7 残余  
> **参照**：审查 m8/m9 · M7 README 发布节 · `docs/api.md` Docker 占位  
> **原则**：文档与 v0.4.4 实现一致，验收可执行

**闭合条件**：P0 全部 ✅ · `pytest -q` 绿

**执行顺序**：`M-DOC-03-01` → `M-DOC-03-02` → `M-DOC-03-03` → `M-DOC-03-04`

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|
| M-DOC-03-01 | 更新 `docs/architecture.md` 项目结构（mddocx 包 · webui · security.py） | P0 | ✅ | grep -q 'webui' docs/architecture.md | docs/architecture.md |
| M-DOC-03-02 | 更新 `docs/testing.md` 导入路径与 WebUI 测试说明 | P0 | ✅ | ! grep -q 'src.converter' docs/testing.md | docs/testing.md |
| M-DOC-03-03 | 修正 README 发布节 v0.4.6、`batch_convert.py`、pytest 全量路径 | P1 | ✅ | grep -q 'v0.4.6' README.md && ! grep -q batch_convert_test README.md | README.md |
| M-DOC-03-04 | api.md 标注 Docker 为规划中或移除占位命令 | P1 | 🔧 | grep -q '规划\|未提供' docs/api.md \|\| ! grep -q 'docker build' docs/api.md | docs/api.md |

### 已具备（不必重复立项）

- WebUI bleach / CSRF / CSP、CI 含 webui tests（v0.4.4）
- `security.py`、`_reset_state()`、154 passed

### 下一 Sprint 候选（审查残余代码）

| ID | 任务 | 优先级 | 状态 | 备注 |
|----|------|--------|------|------|
| M-CONV-01-01 | 引用块支持链接/删除线/行内代码（m2） | P2 | 待立项 | blockquote.py |
| M-CONV-01-02 | `ConvertError` 保留原始异常链（m1） | P2 | 待立项 | base.py |
| T-HTML-01 | 文档化 `pip install mddocx[html]`（M12） | P2 | 待立项 | README · CONTRIBUTING |

## 变更记录

- **2026-06-08** · **审查.md 完成度审计** · C4/4 · M代码9/9 · 文档/Minor/Suggestions 未全闭合 → 立项 M-DOC-03
- **2026-06-08** · **M-DOC-02 jwrun 执行** · api.md 安全说明 · README 依赖/结构树修正
- **2026-06-08** · **M-DOC-02 Sprint 规划** · handoff jwrun
- **2026-06-08** · jwplan/jwrun 工作流迁入 `.cursor/`
