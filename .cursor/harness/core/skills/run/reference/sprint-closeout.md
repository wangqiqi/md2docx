# run · sprint-closeout

> 由 `run/SKILL.md` 移出（C5 去重）：主流程留在 SKILL，细节按需加载。

## Sprint 收尾（全部任务 ✅）

当前 Sprint 任务表无 ⬜/🔧 时：

1. `./.cursor/bin/runner.sh verify` — **须满足 Sprint Done when**（母版含 `cursor-coherence.sh` · README 与 CHANGELOG 对齐）
   - **可选** — Done when 含「测试报告」/ QA benchmark / 持久化 `docs/test-report.md` → **`/report`**（**test-report**；步骤 1 刚跑完 verify 时优先 **from-logs**；见 `reference/regen-gates.md` §sprint）
2. 将本 Sprint 笔记写入 **`.growing/archive/{domain}/`** — **至少一级域目录**（域表 · scripts 树 → **plan** `reference/growth-layout.md`；命名见 `learn/plan-conventions.md`）
2b. `./.cursor/bin/runner.sh archive-check` — 归档域分层（根目录 flat 超阈值即 FAIL；域表 → `learn/plan-conventions.md`）
3. **plan 正文 reconciliation**（与 archive 一致；**必做**，仅 `.growing/plan.md`）：
   - [ ] `<!-- SPRINT_STATUS: closed -->` · `<!-- ACTIVE: (none) -->` · `<!-- NEXT: (none) -->`
   - [ ] **从 plan 删除整个已闭合 Active Sprint 区块**（Goal · Done when · TASK 表）— **勿**改标题留「已闭合」正文
   - [ ] **勿**在 plan 补 ROADMAP `done` 表或「历史 Sprint」链接列表
   - [ ] **保留**「下一 Sprint 候选」表；已交付项从候选表移除（若曾立项）
   - [ ] **VERSION_TARGET**（若有）与 CHANGELOG / 打版 tag 一致
   - [ ] 团队在 `plan-conventions.md` 登记的可选段落 → 交付态或仅 archive
4. 对外变更写入 CHANGELOG `[Unreleased]`（**勿**在 plan 维护 ROADMAP 全表）
5. **摩擦记录（每个 TASK 收尾一行）** — 让"拉扯"可观测、可回归：
   ```bash
   ./.cursor/bin/runner.sh friction-log --task <TASK-ID> --rounds <本任务交互轮次> --rework <返工次数> --verify <pass|fail>
   ```
   写入 `.growing/logs/friction.jsonl`（gitignore）；`friction-report` 汇总。**/learn** 时把趋势写进 `learn/dev-conventions.md`。
6. **`git commit`（必做）** — 仅已跟踪文件；message 例：`docs: close SPRINT-NN readme sync (DOC-00N)`
7. **`/learn`** — 吸收 archive / CHANGELOG / `friction-report` 到 `.growing/learn/`（**建议**）
8. `./.cursor/bin/runner.sh plan-check` — plan 内无已闭合 Sprint 正文
9. 确认 `git status` 无意外脏文件（`.growing/` 改动可存在且不必提交）

Sprint 收尾后若需 **merge/PR 或打 tag** → **`/release`**；新开 Sprint → **`/plan`**（设 `<!-- SPRINT_STATUS: active -->`）。
