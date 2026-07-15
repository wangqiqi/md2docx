---
name: ux
description: UX 总入口与分流（/ux）— IA 为结构层特化。说「UX」「体验」「界面乱」「不好用」且未明确 IA/交付时用；再路由到 ia 或 delivery。
---

# ux · 用户体验（路由）

**用这个**：体验问题类型不明（「不好用 / 界面乱」）。**不是那个**：已明确导航 → **`/ia`**；已明确上线走查 → **`/delivery`**。

**不重复** ia / delivery 的清单；只做 **分层判断 + handoff**。Garrett 五层详表 → `rules/execution/ux.mdc` §Garrett 分层。

## UX 在母版中的位置

```
用户体验 UX
├── 战略/范围        → plan · SPIKE-*
├── 结构层 IA        → ia skill · rules/execution/ia.mdc
├── 骨架/交互        → ia（分支点）· delivery §5
├── 表现/视觉        → 项目设计规范 · delivery §1
└── 内容/i18n        → delivery §2
```

**IA 是 UX 的子集**，不是并列模块。

## 何时进入

- 用户说 **UX / 体验 / 不好用 / 界面乱**，但未指明「导航」或「上线验收」
- `/master` 分流后仍模糊（既像迷路又像 UI 丑）
- 新功能问「要不要先做 IA」

**不要**拦截已明确的 **`/ia`**、**`/delivery`**、**`/plan`** 路径。

## 分流（AskQuestion · ≤4 项）

工具不可用时：同表正文编号选项（见 **master**「AskQuestion 约定」）。

| 选项 | 典型信号 | handoff |
|------|----------|---------|
| **结构 / 导航** | 找不到入口、角色不该同一首页、工作流交叉、Dashboard 歧义 | **ia** · `docs/design/*-ia*` |
| **交付 / 抛光** | 要上线、视觉不一致、缺空态、i18n 漏翻、按钮无反馈、**新 UI 像 AI 模板** | **delivery**（§1 反模板自检） |
| **规划 / 范围** | 功能该不该做、拆 Sprint、大改范围 | **plan** |
| **调研 / 学习** | 学 NN/g、可用性方法、竞品 | **study** · `SPIKE-*` |

若 **结构 + 交付** 兼有：先 **ia** 定导航与分支 → 实现 → **delivery** 收尾。

## 项目文档落点

| 类型 | 路径 |
|------|------|
| IA 讨论稿 | `docs/design/<产品>-ia.md` |
| 视觉 / 壳型 | 项目 `设计规范` 或 `docs/design/` |
| 验收约定 | `.cursorGrowth/learn/acceptance.md` |

## 禁止

- 在 **ux** 内写业务路由或长 checklist（去 **ia** / **delivery**）
- 用 delivery 替代 IA 规划（先结构后抛光）
- 未读 `ia.mdc` 就大改侧栏/默认着陆
