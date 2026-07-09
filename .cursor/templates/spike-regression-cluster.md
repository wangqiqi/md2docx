# SPIKE · 症状簇回归（模板）

> 复制到 `.cursorGrowth/archive/` 或 SPIKE 产出。命名：`YYYYMMDD_HHMMSS_SPIKE-<id>_<symptom>_regression.md`

## 症状簇（一句话）

（例：大包上传后 UI 卡在 extract 0%）

## 历史 fix（CHANGELOG / commit grep）

| 版本/日期 | 摘要 | 根因类型 |
|-----------|------|----------|
| | | |

## 根因假设（待验证）

1.
2.

## 一次性修复范围（Out of 本 SPIKE 的 patch 链）

- [ ] 合并为 **一个 Sprint** / **一个 TASK** 而非 follow-up 链
- [ ] 涉及规则：`async-progress` · `long-running-ui` · `modal-layering` · `error-context` · `single-detector`

## 回归测矩阵

| 场景 | L1 单测 | L2 集成 | L3 smoke |
|------|---------|---------|----------|
| | | | |

## 结论

- [ ] 立项 TASK-* / 合并进 Active Sprint
- [ ] 关闭 follow-up 候选（写 plan 理由）
- [ ] 无需改代码（文档/配置即可）

## 项目符号（仅 Growth，SPIKE 正文可引用）

（progress store 类名、stage 枚举、verify 脚本路径 — 来自 `.cursorGrowth/learn/`）
