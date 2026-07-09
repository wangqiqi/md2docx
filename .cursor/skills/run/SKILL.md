---
name: run
description: 执行（/run）：gate-check→ACTIVE→验收→审计→CHANGELOG→README（门面）→plan→必 commit。每任务/Sprint 收尾自动提交。
disable-model-invocation: true
---

# run

**日常三指令之二**：`/plan` 拆好任务 → **`/run`** 做到底。Sprint 收尾后 merge/打版 → **`/release`**。

闸门见 `rules/workflow.mdc`。先读 `learn/`（若有）。规划侧见 **plan** skill「先总后分」— run 负责 **按坐标执行**、**归档** 与 **及时 commit**。

```bash
./.cursor/bin/runner.sh gate-check   # BLOCK → /plan
```

## 单轮（含必做 commit）

**禁止**在任务 ✅ 后仅更新 plan/CHANGELOG 却留给用户手动 commit。单轮顺序固定：

ACTIVE → 🔧 → 实现 → `task-verify` → **审计复核** → CHANGELOG（若有用户可见变更）→ **README 同步（若触发）** → **更新 plan.md** → **`git commit`（必做）** → **`release-tag`（`tag-per-commit` 时必做）** → `next-task`

```bash
./.cursor/bin/runner.sh task-verify
git status && git diff --stat    # commit 前：无密钥、无意外文件
./.cursor/bin/runner.sh next-task
./.cursor/bin/runner.sh verify   # Sprint / 打版前全量
```

`task-verify` 非 OK 不得标 ✅、不得 commit（见 `rules/communication/constitution.mdc`）。

## 及时 commit（必做）

| 时机 | 规则 |
|------|------|
| **每个 TASK / DOC / SPIKE 归档任务 ✅** | 同轮 **必须** `git commit`（**不含** `plan.md`）；`tag-per-commit` 时同轮 **`release-tag`** |
| **Sprint 全部 ✅ 收尾** | CHANGELOG / 已跟踪文件更新后 commit；Sprint 笔记进 `.cursorGrowth/archive/` |
| **仅改 `.cursorGrowth/plan.md`** | **勿** commit（`.cursorGrowth/` gitignore） |
| **push** | 默认 **不** push；用户说 push 或 **ship** / **release** §分支 再推 |

Message 须含任务 ID（`TASK-003` · `DOC-001` · `SPIKE-002`）。格式：`type(scope): summary (ID)`。

无改动可提交（罕见）→ 在回复中说明「working tree clean」，**勿**伪造 empty commit。

## 验收列

| 阶段 | 推荐命令 |
|------|----------|
| 开发任务 | `./scripts/test.sh` 或域脚本 **L1**（`bash scripts/verify_<feature>.sh`） |
| 任务收尾 / P0 闭合 | `./scripts/verify.sh` 或域脚本 **`--full`（L3）** |

分层定义 → `rules/feedback/verify.mdc` · 测试侧重 → **test** skill。

`task_verify_heuristics.enabled=true` 时，描述性验收列会回退到 `./scripts/test.sh`（若存在）。

失败自修 ≤2 轮 · 仍失败 `⚠️` → `/plan` · 打版读 **release** skill

## 对外文档同步（必做）

**禁止**功能已交付、CHANGELOG 已写、README 仍滞后留给人手补。见 **plan** skill「对外门面 · README」。

| 本次 diff 含 | 同轮必做（commit 前） |
|--------------|----------------------|
| `.cursor/skills/` 新增/改名/职责变更 | README 开箱即用 · 指令表 · skills 计数/名单 |
| `.cursor/agents/` | README agents 行 |
| `master/` routes · 新 `/` 指令 · plan/run 工作流 | README mermaid · 机制表 · plan-run 链 |
| 安装路径 · config 公开键 · verify 链 | README 安装/验证节 |
| CHANGELOG `[Unreleased]` 有 Added/Changed（用户可见） | README 摘要与之对齐 |

母版仓库验收：

```bash
bash .cursor/bin/cursor-coherence.sh   # README ↔ 磁盘 skills/agents 一致
```

- **单 TASK**：触发上表任一行 → 该 TASK 的 commit **须含** README 变更（与代码同 commit）
- **Sprint 收尾**：对照 CHANGELOG `[Unreleased]` 审 README；coherence 绿再 commit
- 纯内部/archive-only 无触发 → 可跳过，回复中一句说明

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

## plan 维护（单任务 · 不提交）

`.cursorGrowth/plan.md` 在 **`.gitignore`** — 只更新本地，**禁止** `git add .cursorGrowth/`。

`task-verify` 与审计通过后、**commit 前**更新本地 plan：

1. `<!-- LAST_DONE: TASK-xxx -->`（或 DOC-/SPIKE-）
2. `./.cursor/bin/runner.sh next-task` → 更新 `<!-- ACTIVE: ... -->` 与 `<!-- NEXT: ... -->`
3. TASK 表该行标 **✅**（或清理已完成行）· 更新 **执行顺序**
4. Sprint 内仍有 ⬜/🔧 → 继续下一 `ACTIVE`；表空 → 进入 **Sprint 收尾**

**禁止**只改 `LAST_DONE` / `ACTIVE` 而留 **Done when** 未勾、TASK 表无 ✅、可选基线段落仍写「未交付」——头部与正文须同步（见 **Sprint 收尾 · plan 正文 reconciliation**）。

勿把长叙事写进 plan；细节进 CHANGELOG 或 `.cursorGrowth/archive/`。

## Sprint 收尾（全部任务 ✅）

当前 Sprint 任务表无 ⬜/🔧 时：

1. `./.cursor/bin/runner.sh verify` — **须满足 Sprint Done when**（母版含 `cursor-coherence.sh` · README 与 CHANGELOG 对齐）
2. 将本 Sprint 笔记写入 **`.cursorGrowth/archive/`**（命名见 `learn/plan-conventions.md`）
3. **plan 正文 reconciliation**（与 archive 一致；**必做**，仅 `.cursorGrowth/plan.md`）：
   - [ ] `<!-- SPRINT_STATUS: closed -->` · `<!-- ACTIVE: (none) -->` · `<!-- NEXT: (none) -->`
   - [ ] **从 plan 删除整个已闭合 Active Sprint 区块**（Goal · Done when · TASK 表）— **勿**改标题留「已闭合」正文
   - [ ] **勿**在 plan 补 ROADMAP `done` 表或「历史 Sprint」链接列表
   - [ ] **保留**「下一 Sprint 候选」表；已交付项从候选表移除（若曾立项）
   - [ ] **VERSION_TARGET**（若有）与 CHANGELOG / 打版 tag 一致
   - [ ] 团队在 `plan-conventions.md` 登记的可选段落 → 交付态或仅 archive
4. 对外变更写入 CHANGELOG `[Unreleased]`（**勿**在 plan 维护 ROADMAP 全表）
5. **`git commit`（必做）** — 仅已跟踪文件；message 例：`docs: close SPRINT-NN readme sync (DOC-00N)`
6. **`/learn`** — 吸收 archive / CHANGELOG 到 `.cursorGrowth/learn/`（**建议**）
7. `./.cursor/bin/runner.sh plan-check` — plan 内无已闭合 Sprint 正文
8. 确认 `git status` 无意外脏文件（`.cursorGrowth/` 改动可存在且不必提交）

Sprint 收尾后若需 **merge/PR 或打 tag** → **`/release`**；新开 Sprint → **`/plan`**（设 `<!-- SPRINT_STATUS: active -->`）。

## 与 plan 分工

| 时机 | run | plan |
|------|-----|------|
| 单任务 ✅ + commit + README（门面） | ✅ | |
| Sprint 收尾 README/coherence + 归档 | ✅ | |
| 阶段 1 门面进 Done when · 禁事后 DOC Sprint | | ✅ |
| 新开 Sprint | | 阶段 1 总 → 阶段 2 分 |
| `⚠️` 阻塞 | 标状态 | 重排；Goal 偏了 → 阶段 1 |
