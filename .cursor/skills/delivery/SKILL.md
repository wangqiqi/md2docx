---
name: delivery
description: 交付验收（/delivery）：视觉 · i18n · 文档对齐 · 后端对接 · 组件完整度 · 可维护性 · 生产就绪。Sprint 收尾或 /release 分支前走查。说「交付验收」「上线前检查」「生产就绪」时用。
---

# delivery · 交付验收

**用这个**：功能已绿、要上线前 7 维走查。**不是那个**：还在规划导航结构 → **`/ia`** / **`/ux`**；自动化脚本绿/红 → **verify** / **run**（本 skill 不替代）。

功能已实现、**task-verify** 已绿之后，在 **`/release`**（merge/PR）或 Sprint **Done when** 要求时，做 **7 维度**走查。不替代 **run** 三公理审计或自动化 **verify**。

项目特化路径（design tokens、i18n 库、OpenAPI 位置）→ `.cursorGrowth/learn/acceptance.md`（若无则 **AskQuestion** 或 grep 惯例）。

**详单**：`reference/checklist-core.md`（§1–7）· `reference/checklist-optional.md`（§埋点 · §8–11）

## 何时进入

- 用户说 **`/delivery`** · 「交付验收」「上线前检查」「生产就绪」
- **release** §分支前：UI/功能 Sprint **建议**先走一遍（见 **release** skill）
- plan **Done when** 含 `delivery 无 Blocker`
- `REV-*` 任务范围含交付走查 → 可委派 **review** agent（只读）+ 本清单

## 流程

1. 读 `learn/acceptance.md`（若有）· 扫 `plan.md` Sprint Goal / Done when
2. 按 **checklist-core** §1–7 逐项检查（grep · Read · 对照 docs/OpenAPI）
3. 按需勾选 **checklist-optional** §8–11（长任务 / 导入 / 浏览器 / a11y）
4. 第 4 条 API 子集 → 对照 **api** skill；第 7 条 → **security** · `security-sdlc.mdc`
5. 输出报告；**Blocker** 须用户决策后再 **release**

## 输出格式

与 **review** 一致，每条一行：

```text
严重度 · file:line · 发现 · 建议
```

| 严重度 | 含义 |
|--------|------|
| **Blocker** | 不可 merge/上线；须修或用户明确接受风险 |
| **High** | 应在本 Sprint 内修 |
| **Medium** | 可跟 issue；不挡 release |
| **Low** | 风格/ nit |

**文档 ↔ 实现冲突**（第 3、4 条）须标 **`Decision needed`**，列：文档说法 · 实现现状 · 建议 · **等你决策**（Agent 不擅自改 spec）。

## 与下游分工

| 阶段 | delivery | 不做 |
|------|----------|------|
| **ia** | — | 结构规划 · `docs/design/*-ia*`（先于大改） |
| **run** | — | 实现 · task-verify · 三公理审计 |
| **delivery** | 7 维走查 · 可选 §8–§11 · 冲突上报 | 不写业务代码（除非用户 steering 修 Blocker） |
| **release** | Blocker 须先报告 | 不跳过 verify |

UX 分流不明时 → **ux** skill；结构问题回流 **ia**，非结构抛光留在本 skill。

## PDF 交付工具（吸收自 anthropics/skills/pdf）

**脚本**：`scripts/pdf/`（8 个轻量 `.py`）· **许可**：`scripts/pdf/LICENSE-anthropics.txt`（source-available）  
**黑盒**：先 `python <script>.py --help` 或读 SKILL 指引，**勿**默认读源码进上下文。

| 场景 | 脚本 |
|------|------|
| 检查可填字段 | `check_fillable_fields.py` |
| 提取表单结构/字段 | `extract_form_structure.py` · `extract_form_field_info.py` |
| 填写表单 | `fill_fillable_fields.py` · `fill_pdf_form_with_annotations.py` |
| 转图验收 | `convert_pdf_to_images.py` · `create_validation_image.py` |
| 边界框检查 | `check_bounding_boxes.py` |

**Office 整包**（docx/pptx/xlsx 含 office/ 子树）本 Sprint **不纳入**；需深度编辑 → **master** deps 建议用户装 upstream 或 MCP。

## 禁止

- 有 **Blocker** 仍建议 silent merge
- 文档冲突时擅自改 spec 或改实现而不 **`Decision needed`**
- 用 delivery 替代 **task-verify** 或跳过 **security** 对高风险 diff
