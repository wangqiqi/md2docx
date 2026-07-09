---
name: review
description: >-
  代码/PR 回顾 — REV-* 任务；坏味道与复杂度清单。可委派 review agent（只读）。
  ≠ 全局 skills-cursor/review（Bugbot/Security 路由）；安全专项用 security skill。
---

# review

用于 `REV-*` 或合并前结构化回顾。可委派 **review** agent（只读）。

**≠ 全局 `review`**：`~/.cursor/skills-cursor/review` 只路由 Bugbot / Security Review；本 skill 管 REV-* 与 PR 结构化清单。

## 输出格式

严重度 · file:line · 发现 · 建议

## 清单

- [ ] 范围符合 PR 描述；无 drive-by 重构
- [ ] 命名与模块边界清晰
- [ ] 重复逻辑 / 过长函数 / 深嵌套
- [ ] 错误处理一致；无吞异常
- [ ] 测试覆盖行为变更
- [ ] **security** · **api** skills 对高风险 diff 再扫一遍
- [ ] `REV-*` 范围含交付/上线 → 叠加 **delivery** skill 7 维清单（只读）

## 与 plan

- 纯回顾不写代码 → `REV-*` prefix；`next-task` 跳过但 gate 仍适用编码任务
- 交付走查 REV → 输出含 **`Decision needed`** 的文档冲突项（见 **delivery** skill）
