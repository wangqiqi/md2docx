# plan · run

> **效果型效率**：`/plan` 与 `gate-check` 的价值在于减少纠偏轮次，而非压短单次回复。总成本 = 固定开销 + 轮次 × token + 返工 → [effective-collaboration.md](effective-collaboration.md)

迷路或刚安装 → **`/master`** · 日常 **`/run` ↔ `/plan`** · `/learn` → `.cursorGrowth/learn/`

1. `config/workflow.json` · 复制 `templates/plan.md` → **`plan_file` 所指工作副本**（默认在 Growth 目录；**gitignore，不提交**；安装/bootstrap 会引导）
2. **`/plan`** — 先总后分：Goal · Done when → 再拆 TASK · **执行顺序**（**无 ACTIVE 时用**）
3. **`/long`**（可选）— Epic 长程：拆 Sprint → 每 Sprint plan+run → checkpoint（**单 Sprint 仍用 plan+run**）
4. **`/run`** — 按 `ACTIVE` 执行；默认 **`AUTONOMOUS:true`** → **一次 `/run`**（详 `plan/reference/autonomy-chain.md`）
5. **ia** skill（无 slash）— 导航/角色大改：先结构稿 `docs/design/*-ia*` · `ia.mdc` R1–R4
6. **`/delivery`**（【高级】）— UI/功能 Sprint：**release** §分支前建议 7 维走查；Blocker 须先报告
7. **`/report`**（【高级】）— verify 绿后可选：全量/分层测试报告汇总（**test-report** · Report Contract）；非每 TASK 必做
8. **`/manual`**（【高级】）— 可发布使用说明书 · Manual Contract（**≠** delivery 走查）
9. **`/release`** — merge / PR / 打 tag（Sprint 出口）

**反例**：plan 里已有 ACTIVE → **`/run`** 不是 `/plan`。

闸门与 CLI：见 `rules/workflow.mdc`

`task_id.prefixes_skip`（`SPIKE-` / `REV-` / `DOC-`）：`next-task` 自动推进时跳过，不 bypass `gate-check`。

```bash
./.cursor/bin/runner.sh gate-check
./.cursor/bin/runner.sh task-verify
./.cursor/bin/runner.sh verify
./.cursor/bin/runner.sh next-task
```

| Hook | 脚本 |
|------|------|
| beforeSubmitPrompt | `growth-init.sh` |
| sessionStart | `run-start.sh` |
| stop | `run-stop.sh` |

打版：**release** skill · **ship** agent · [naming.md](naming.md)
