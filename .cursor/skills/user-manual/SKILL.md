---
name: user-manual
description: 可发布软件使用说明书（/manual）— 故事线 · 配图 regen · Manual Contract · 多 Capture Profile。项目无关 · 操作者无关。说「使用说明书」「用户手册」「配图 regen」「walkthrough 截图」时用。
---

# user-manual · 软件使用说明书

**用这个**：生成或更新**可单独发布**的操作手册（故事线 + 实机截图 + 双层验收）。**不是那个**：上线前文档↔实现走查 → **`/delivery`**；行为红绿测试 → **test**；大改版 Sprint 编排 → **plan** `DOC-*`。

母版正文**零**业务词、零演示账号、零具体仓库路径。项目命令与命名 → **Manual Contract**（`config/manual.yaml` 优先；无则 `learn/user-manual.md`）。

**详文**：`reference/pipeline.md` · `reference/manual-contract-schema.md` · `reference/extract-sources.md` · `reference/capture-profiles.md` · `reference/regen-gates.md` · `reference/reader-test.md` · `reference/storyline-template.md` · `reference/scaffold-bundle.md`

## 何时进入

- 用户说 **`/manual`** · 「使用说明书」「用户手册」「配图重新生成」「walkthrough 截图」
- plan **Done when** 含可发布操作手册 / manual regen
- **`/release`** 发版前：可选 manual regen + Reader Test（见 `reference/regen-gates.md`）

## 流程（五段 · 概览）

1. **读 Contract** — `config/manual.yaml` 或 `learn/user-manual.md`；无则 AskQuestion + 用 `templates/manual-contract.example.yaml` 起草
2. **提取 / 学习** — 按 `reference/extract-sources.md` 优先级补全 storylines · shots
3. **门禁** — 项目 `verify` / `task-verify` 全绿后才 regen（发版档）；见 `reference/regen-gates.md`
4. **Capture regen** — 按 `capture.profile` 跑 walkthrough → sync assets → 更新 doc
5. **验收** — L1 脚本（文件/链接）+ L2 Reader Test（`reference/reader-test.md`）

## 与下游分工

| 阶段 | user-manual | 不做 |
|------|-------------|------|
| **ia** | — | 导航结构规划 |
| **test** | 复用 walkthrough spec 作 capture 输入 | 替代行为断言 |
| **delivery** | — | regen 截图 · 替代 7 维走查 |
| **plan** `DOC-*` | 协作写正文 · Reader Test 编排 | 替代 contract schema |
| **release** | 发版档可选 regen | 跳过 verify 门禁 |

## Capture Profile 分流

| profile | 典型栈 | 详则 |
|---------|--------|------|
| `web-fullstack` | SPA + API | `reference/capture-profiles.md` §web-fullstack |
| `web-spa-only` | 纯前端 / mock | 同上 §web-spa-only |
| `electron` | Electron 壳 | 同上 §electron |
| `flutter` | Desktop / Mobile | 同上 §flutter |
| `native-window` | MFC / Qt / 自绘 GUI | 同上 §native-window（系统 screenshot 兜底） |

Contract 未指定时：有 DOM/可访问树 → Playwright 系；仅窗口像素 → `native-window`。

## 禁止

- 在 skill 正文写死项目 URL、账号、业务术语、具体 PNG 文件名
- 无 `verify` 绿仍声称「配图已更新」
- 用 manual regen 替代 **delivery** 或 **task-verify**
- 无 Contract 时编造故事线而不标 `inferred`
