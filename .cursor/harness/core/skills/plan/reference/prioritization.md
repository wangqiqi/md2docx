# Backlog 与 Sprint 优先级（吸收自 pm-skills · MIT）

> 出处与纪律 → **`docs/library-index.md`**（§ pm-skills）· 本文件为操作 SSOT。  
> **用这个**：候选 Sprint · backlog · TASK 排序。**不是那个**：甘特路线图（与 Sprint 重叠）· 完整 pm 编排（装 upstream）。

## 何时用

| 时机 | 动作 |
|------|------|
| **阶段 1** · plan「下一 Sprint 候选」>1 行 | 与用户排序或标推荐项 |
| **阶段 2** · TASK 表 Priority 列 | P0/P1 争议或并行顺序不清时 |
| 用户说「排优先级」「先做哪个」「RICE」 | 套用下文框架，输出排序表 |

**不替代** Goal / Done when 对齐 — 排序在**边界已定**之后。

## 框架选型（≤30 秒）

| 框架 | 适用 | 核心问法 |
|------|------|----------|
| **RICE** | 功能/backlog · 要粗算影响力 | Reach × Impact × Confidence ÷ Effort |
| **ICE** | 快排 · 小团队 | Impact × Confidence × Ease |
| **Kano** | 体验分层 · 防堆「锦上添花」 | 基本型 / 期望型 / 兴奋型 |
| **MoSCoW** | 时间盒紧 · Sprint Out of scope | Must / Should / Could / Won't |

同一列表只选**一种**主框架；可 MoSCoW 定 Must 后再 RICE 排 Must 内顺序。

## RICE 速查

| 因子 | 1–5 或数量 | 提示 |
|------|------------|------|
| **Reach** | 影响用户数/次数（周期内） | 用区间估，勿精算 |
| **Impact** | 0.25 / 0.5 / 1 / 2 / 3 | 对单用户目标贡献 |
| **Confidence** | 50%–100% | 证据越少越低 |
| **Effort** | 人周（或相对 T 恤） | 含测试与发布 |

**Score** = (Reach × Impact × Confidence) ÷ Effort · 高→先。

## ICE 速查

**Score** = Impact × Confidence × Ease（各 1–10）· 适合 10 项以内快排。

## Kano 速查

| 类型 | 策略 |
|------|------|
| **基本型** | 缺了投诉 · 做了不加分 → Sprint 前 Must |
| **期望型** | 做得越好越满意 → 主 backlog |
| **兴奋型** | 惊喜 · 可选 · 资源富余再做 |

输出：每项标 Kano 类型 + 一句理由。

## 与 plan.md 衔接

### 候选 Sprint 表

排序后保留原表结构，加 **推荐** 列或重排行序；未选行**不删**。

```markdown
| 候选 | Goal | 依赖 | 推荐 |
|------|------|------|------|
| 候选 A … | … | … | ⭐ RICE 最高 |
```

### TASK 表

- Priority 列：`P0` = Must/本 Sprint Done when 必需 · `P1` = Should · `P2` = Could
- **执行顺序**行：高 RICE/ICE 的 P0 靠前；`[P]` 可并行项注明

## 输出格式（Agent）

```markdown
## 优先级建议 · <框架名>

| 项 | Score/类型 | 理由（一句） | 建议 |
|----|------------|--------------|------|
| … | … | … | 本 Sprint / 下一 Sprint / Won't |

**Decision needed**（若有）：…
```

有争议 → **AskQuestion** 让用户拍板，不静默替用户定序。

## 下游

- 写 PRD 前排序 → 链 **doc-prd-enrich.md**
- 排完仍 scope 不清 → **SPIKE-***
- 装 upstream 整包 → **master** deps · **security** §外部 skill
