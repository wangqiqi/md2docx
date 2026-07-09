---
name: debug
description: 调试方法论 — 隔离、模式聚类、与 bugfix 衔接。
---

# debug

衔接 `rules/execution/bugfix.mdc`。输出仍须 file:line 与可复现步骤。

## 隔离法

1. 最小复现或补测试
2. 注释/禁用可疑块（先备份或 git stash 思路）
3. 跑 `task-verify` / 项目 test 对比前后
4. 二分缩小范围

## 模式聚类

- 同类报错一批修（同根因别打补丁）
- 区分环境 vs 代码（config、版本、路径）

## Escalation

- 自修 ≤2 轮 → 仍失败标 `⚠️` 回流 `/plan`
- 线上 hotfix：小 diff + CHANGELOG `### Fixed`
