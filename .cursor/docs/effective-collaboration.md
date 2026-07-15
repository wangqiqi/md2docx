# 效果型效率 · 少拉扯才是真省

Super Cursor 的目标不是「让 Agent 说得更短」，而是 **更快、沿正确方向、一次到位地交付可验证结果**。单次会话压 token，若带来更多轮纠偏或返工，**总成本反而上升**。

## 总成本怎么算

```text
总成本 ≈ 固定开销（rules · skills 描述 · 会话历史）
        + 轮次 ×（输入 + 输出）
        + 返工（改错方向 · 补测 · 回滚 · 重讲背景）
```

**智效式省钱**：减少轮次与返工，而不是砍掉 thoroughness。

| 做法 | 单次会话 | 多轮合计 | 质量 |
|------|----------|----------|------|
| 压短回复、压缩 rules/memory | 可能更低 | 拉扯增多时常 **更贵** | 易降 |
| 先对齐再动手、`task-verify` 收口 | 可能略高 | **更省** | 保持或提升 |

## Super Cursor 如何落实

| 机制 | 防什么 | 对应入口 |
|------|--------|----------|
| **先总后分** | 方向猜错、一次改太多 | `/plan` · `gate-check` |
| **逐条验收** | 「看起来完了」的假完成 | `task-verify` · Acceptance 列 |
| **glob 按需 rules** | 每条消息背负无关栈细则 | `rules/*.mdc`（仅 `core` + `workflow` 常驻） |
| **项目认知沉淀** | 新会话重复解释结构 | `/learn` → `.cursorGrowth/learn/` |
| **探索与执行分离** | 主会话被检索日志淹没 | explore / spike 子 agent |
| **可验证才 commit** | 隐性返工 | `verify` · **delivery**（发版前） |

## 日常习惯（与母版正交）

1. **一事一对话** — 目标清晰的开局；做完可关，避免历史互相污染。
2. **模糊先 `/plan`** — 大改、多文件、边界不清时，先 Goal · Done when，再 `/run`。
3. **强模型押关键决策** — 架构、安全、疑难 bug 用强；机械小改用 fast；**错一次比多付一轮更贵**。
4. **精准投喂** — `@文件`、复现步骤、报错原文；少让 Agent 全仓猜。
5. **固定税做减法** — 卸载不用的全局 skill（`npx skills list -g`）；用户 rules 只留高频约束。

## 不建议

- 为省 token **压缩** `AGENTS.md` / rules / memory — 丢约束 → 返工更贵。
- 安装「压回复风格」类 skill — 细节被砍，轮次反增。
- 长会话硬扛 — 上下文过半仍「继续」→ 重读与幻觉成本陡增。

## 与 skills 市场的关系

[skills.sh](https://skills.sh/) 上有 `save-tokens`、`token-saver` 等 skill，多数面向 **叙述压缩** 或 **文件压缩**。若你的标准是 **不降智**，优先：

- 本仓 **plan/run 闸门**（结构防拉扯）
- 可选：[context-engineering](https://skills.sh/addyosmani/agent-skills/context-engineering)（喂对上下文）
- 谨慎：[savethetokens](https://skills.sh/redclawww/savethetokens/savethetokens)（强调正确性优先于压缩）

**Skill 本身也是 markdown** — 装太多未使用的 skill，固定开销反而上升。

## 一句话

> **快速按正确方向生成可验证答案 = 真省；单次少说几句但多拉扯几轮 = 假省。**

相关：[plan/run](plan-run.md) · [quickstart](quickstart.md) · [walkthrough](walkthrough.md)
