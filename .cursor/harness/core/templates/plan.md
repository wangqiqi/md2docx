<!-- 工作副本：.growing/plan.md（gitignore）· 模板 .cursor/templates/plan.md -->
<!-- 纪律：禁止删除 ⬜/🔧/⚠️ TASK · 见 skills/plan/reference/task-retention.md -->
<!-- PLANNING: false -->
<!-- SPRINT: (none) -->
<!-- PLAN_APPROVED: (none) -->
<!-- AUTONOMOUS: true -->
<!-- SPRINT_STATUS: closed -->
<!-- ACTIVE: (none) -->
<!-- NEXT: (none) -->
<!-- LAST_DONE: (none) -->
<!-- VERIFY: ./scripts/verify.sh -->
<!-- 禁止写 runner.sh verify — CLI 入口会读本行；指回自身会无限递归 -->
<!-- MAX_LOOPS: 15 -->
<!-- VERSION_LINE: (optional · major.minor，如 4.22；省略则 release-tag 读最新 v* tag) -->
<!-- VERSION_TARGET: (optional) -->

# Plan

无 Active Sprint / 未完成任务。新开 → `/plan`（能力 Sprint）或 Epic → `/long`。Sprint 闭合：笔记写入运行时 `archive_dir`；**打 tag / merge** → **`/release`**（勿立项为 Sprint，见 plan `sprint-goal-gate.md`）。

---

## Active sprint · SPRINT-01 Example

（有进行中 Sprint 时保留本区块；**全部 ✅ 后整段删除**，勿留「已闭合」正文。）

**Goal**: …

**Done when**（示例 — 勾选适用项）:

- P0 tasks ✅ · `bash ./scripts/verify.sh`（或 plan `VERIFY`）
- （可选）交付走查无 Blocker
- （可选）`/release` §分支 · `/release` §打版

**Out of scope**（可选）: …

| ID | Task | Priority | Status | Acceptance | Target |
|----|------|----------|--------|------------|--------|
| TASK-001 | Example feature | P0 | ⬜ | `./scripts/test.sh` | `src/` |

**验收列规则**（`task-verify` **fail-closed**，描述性文字会直接 FAIL）：

- ✅ 首选**可执行命令**：`` `./scripts/test.sh` `` · `` `npm run test` `` · `` `pytest tests/unit` `` · `` `bash scripts/verify_<feature>.sh` ``
- ✅ 确需人工验收 → 显式写 `` `manual: <步骤与证据要求>` ``（唯一豁免；证据须落 plan/CHANGELOG）
- ❌ 不要写「功能正常」「UI 没问题」这类无法判定的描述

**执行顺序**: `TASK-001` → …

---

## 下一 Sprint · （候选 · 待 `/plan`）

| 候选 | Goal | 依赖 |
|------|------|------|
| SPRINT-02 | … | … |
