# run · audit

> 由 `run/SKILL.md` 移出（C5 去重）：主流程留在 SKILL，细节按需加载。

## 审计复核（单任务收尾，必做）

在标 ✅ 与 **commit** 之前，对照 `rules/core.mdc` 审计三公理自检：

| 检查 | 要点 |
|------|------|
| 意图主权 | 改动符合 ACTIVE **与** Sprint **Goal**；不碰 **Out of scope**；无 drive-by 重构 |
| 信号可信 | 验收命令已实际执行；关键结论可引用 `file:line` |
| 认知可审计 | CHANGELOG/plan 已更新 · **Sprint 收尾时 plan 正文 reconciliation** · **门面变更已同步 README** · **commit message 含任务 ID** |

轻量清单（不必委派 **review** agent，除非任务标 `REV-*` 或 diff 高风险）：

- [ ] 落点文件与 plan「Target」列一致
- [ ] 改动仍在 Sprint **Goal** 内；未静默扩 scope 或触碰 **Out of scope**
- [ ] 无密钥、无意外 `git status` 脏文件
- [ ] 测试/验收与行为变更匹配
- [ ] **门面触发时** README 已更新且 `cursor-coherence.sh` 绿
- [ ] 高风险面（auth、API、依赖）必要时扫 **security** · **api** skill

复核不通过 → 继续修，勿标 ✅、勿 commit。

## Closeout review（`task-verify` 后 · 可选）

**用这个**：P0 任务 `task-verify` 绿后、**commit 前**再做一轮结构化回顾。**不是那个**：日常轻量审计（上节清单已覆盖）· 专项 `REV-*` 须委派 **review** agent。

吸收自 SkillsMP `autoreview`（协议 only，不装 OpenClaw CLI）。

| 触发 | 动作 |
|------|------|
| diff 非 trivial（多文件 / 行为变更 / auth·API） | 叠加 **review** skill（Standards/Spec 双轴）或委派 **review** agent（只读） |
| 用户要求「再过一眼」「第二模型 review」 | 同上；可用另一模型会话，**禁止**无 diff 采证空评 |
| 纯文案 / 单节 skill 补协议且无行为面 | 可跳过 closeout，仅走上节审计清单 |

**顺序**（插入单轮流程）：`task-verify` ✅ → **closeout review（若触发）** → 审计复核 → CHANGELOG → commit。

输出：Blocker/High 须修或向用户说明；仅 Medium/Low 可在回复中列出，用户确认后再 commit。

### Reader Testing（DOC / 协作文档 · 吸收自 doc-coauthoring）

| 触发 | 动作 |
|------|------|
| `DOC-*` 或 plan 三阶段协作文档 **阶段 3** | 生成 5–10 个「读者会发现的问题」 |
| 验证 | 委派 **review** agent（只读）或新会话：仅给文档全文 + 单题，检查答案与歧义 |
| 失败 | 回到 plan 阶段 2 修订对应节；勿标 DOC ✅ |

用户说「不用测读者」→ 记录跳过，仍须用户最终通读确认。
