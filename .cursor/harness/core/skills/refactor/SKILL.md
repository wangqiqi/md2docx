---
name: refactor
description: 安全重构 — 小步、可验证、最小 diff；含死代码删除协议。
---

# refactor

## 原则

- 行为不变 refactor 与功能变更分 commit
- 每步后 `task-verify` / test 绿
- 匹配 `plan` 中 `REV-*` 或用户明确范围

## 常见动作

- 提取函数/模块；重命名用 IDE/工具链
- 去重复；缩小 public API

## 死代码删除协议（通用）

删组件、Hook、API、路由前 **必须**：

1. **grep 生产路径** — 路由表 · 页面 import · OpenAPI/客户端 SDK · 后端 router 注册
2. **区分** — 仅测试引用 vs 生产引用（仅测试 → 可删，但须删对应测试/mock）
3. **分轮** — 前端 UI 一轮 · 后端/API 一轮（避免 half-clean）；第二轮前 **SPIKE 清单** → 产品确认（见 **plan** §Follow-up）
4. **验收** — 删后 `verify` / 全量 test；CHANGELOG `### Removed` 一行摘要

细则：`single-detector.mdc`（检测逻辑）· `error-context.mdc`（失败路径）

## 禁止

- 顺手改无关文件
- 无测试的大范围重写（先 `/plan`）
- 未 grep 生产路径即删「看起来没用」的 export
