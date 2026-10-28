---
name: run
description: 执行（/run）：gate-check→ACTIVE→验收→审计→CHANGELOG→README→plan→必 commit；任务/Sprint 收尾自动提交。
disable-model-invocation: true
---

# run

**日常三指令之二**：`/plan` 拆好任务 → **`/run`** 做到底。Sprint 收尾后 merge/打版 → **`/release`**。

闸门见 `rules/workflow.mdc`。先读 `learn/`（若有）。规划侧见 **plan** skill「先总后分」— run 负责 **按坐标执行**、**归档** 与 **及时 commit**。

```bash
./.cursor/bin/runner.sh gate-check   # BLOCK → /plan
```

## Sprint 连跑（`AUTONOMOUS:true`）

plan handoff 默认自治时，用户 **只说一次 `/run`**；Agent **同会话**按 **执行顺序**做完 Sprint P0 TASK（verify+commit），**仅决策点**打断。

| 必须 | 禁止 |
|------|------|
| 每 TASK 收尾后 **立即**续下一 `ACTIVE`（`next-task` / 读 plan） | TASK ✅ 后停住等用户再说 `/run` |
| 决策清单命中 → AskQuestion 或 `⚠️` → `/plan` | 静默扩 scope · 跳过 verify |
| 人格/行为 → **super-cursor-persona** · `role.default`（默认 professional） | 因语气跳过高风险确认 |

触点矩阵 → **plan** `reference/autonomy-chain.md` · `workflow.json` → `autonomy.interrupt_on`。

## 执行期递归边界

`/run` 只实现当前 `ACTIVE` TASK 所属的 Theme/Slice：

- TASK 内的文件、命令和实现步骤属于 L4 Steps，不自动升级为新的 TASK；
- 发现仍在当前边界内的细节，继续完成并在同一验收中收敛；
- 发现新的独立结果，先停在当前任务边界，记录为同层候选，不直接修改；
- 发现不同 Theme、横向依赖或新的产品/架构决策，标记 `⚠️` 并回 `/plan`；
- 不以“顺便统一”“顺便补齐”“顺便重构”为理由跨越 `Target` 或 `Out of scope`；
- 自治只允许沿已批准的执行顺序前进，不允许自治扩展任务树。

判断标准：如果改动不能用当前 TASK 的一个主验收命令证明完成，就不是当前 TASK 的内部步骤。

## 单轮（含必做 commit）

**禁止**在任务 ✅ 后仅更新 plan/CHANGELOG 却留给用户手动 commit。单轮顺序固定：

ACTIVE → 🔧 → 实现 → `task-verify` → **closeout review（若触发）** → **审计复核** → CHANGELOG（若有用户可见变更）→ **README 同步（若触发）** → **更新 plan.md** → **`git commit`（必做）** → **`release-tag`（`tag-per-commit` 时必做）** → `next-task`

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
| **Sprint 全部 ✅ 收尾** | CHANGELOG / 已跟踪文件更新后 commit；Sprint 笔记进 `.growing/archive/` |
| **仅改 `.growing/plan.md`** | **勿** commit（`.growing/` gitignore） |
| **push** | 默认 **不** push；用户说 push 或 **ship** / **release** §分支 再推 |

Message 须含任务 ID（`TASK-003` · `DOC-001` · `SPIKE-002`）。格式：`type(scope): summary (ID)`。

无改动可提交（罕见）→ 在回复中说明「working tree clean」，**勿**伪造 empty commit。

## 验收列

| 阶段 | 推荐命令 |
|------|----------|
| 开发任务 | `./scripts/test.sh` 或域脚本 **L1**（`bash scripts/verify_<feature>.sh`） |
| 任务收尾 / P0 闭合 | `./scripts/verify.sh` 或域脚本 **`--full`（L3）** |

分层定义 → `rules/feedback/verify.mdc` · 测试侧重 → **test** skill。

`task_verify_heuristics.enabled=true`（`full` profile 默认）时，描述性验收列会回退到 `./scripts/test.sh`（若存在）。

**fail-closed**：既非可执行命令、又无兜底脚本时，`task-verify` **直接 FAIL**（不再静默 SKIP 返回 0）。确需人工验收 → 验收列写 `` `manual: <步骤与证据要求>` ``，并在 plan/CHANGELOG 留证据；`plan-check` 会在**开工前**先 WARN。语义 → `rules/feedback/verify.mdc` §task-verify 语义。

失败自修 ≤2 轮（须按 **debug** 循环：复现→假设→隔离→验证；**禁止无复现盲改**）· 仍失败 `⚠️` → `/plan` · 打版读 **release** skill

**经验沉淀**：用户纠正或 `⚠️` 且根因已定位时，回复中**提议** `/learn` 记一条（**ERRORS** / **LEARNINGS**，见 **learn** §经验捕获）；不自动写 `.growing/`。

## 按需细则（reference/）

- **Sprint 收尾（全部任务 ✅）** → [reference/sprint-closeout.md](reference/sprint-closeout.md)（verify · archive/{domain} · plan reconciliation · CHANGELOG · 摩擦记录 · commit）
- **对外文档同步 · 文档/Office 触发表** → [reference/doc-sync.md](reference/doc-sync.md)
- **审计复核 · Closeout review** → [reference/audit.md](reference/audit.md)（单任务收尾与可选复核清单）

## plan 维护（单任务 · 不提交）

`.growing/plan.md` 在 **`.gitignore`** — 只更新本地，**禁止** `git add .growing/`。

`task-verify` 与审计通过后、**commit 前**更新本地 plan：

1. `<!-- LAST_DONE: TASK-xxx -->`（或 DOC-/SPIKE-）
2. `./.cursor/bin/runner.sh next-task` → 更新 `<!-- ACTIVE: ... -->` 与 `<!-- NEXT: ... -->`
3. TASK 表该行标 **✅**（或清理已完成行）· 更新 **执行顺序**
4. Sprint 内仍有 ⬜/🔧 → 继续下一 `ACTIVE`；表空 → 进入 **Sprint 收尾**

**禁止**只改 `LAST_DONE` / `ACTIVE` 而留 **Done when** 未勾、TASK 表无 ✅、可选基线段落仍写「未交付」——头部与正文须同步（见 **Sprint 收尾 · plan 正文 reconciliation**）。

勿把长叙事写进 plan；细节进 CHANGELOG 或 `.growing/archive/`。

## 与 plan 分工

| 时机 | run | plan |
|------|-----|------|
| 单任务 ✅ + commit + README（门面） | ✅ | |
| Sprint 收尾 README/coherence + 归档 | ✅ | |
| 阶段 1 门面进 Done when · 禁事后 DOC Sprint | | ✅ |
| 新开 Sprint | | 阶段 1 总 → 阶段 2 分 |
| `⚠️` 阻塞 | 标状态 | 重排；Goal 偏了 → 阶段 1 |
