# plan · Follow-up 与对外门面（详）

### Follow-up 立项闸门

候选 Sprint 名含 `follow-up` / `hotfix` / 或与 CHANGELOG/learn **同症状簇** 已 ≥2 次 patch 时：

| 条件 | 必须 |
|------|------|
| 同用户可见症状 **≥2** 个已发布 patch | 先 **`SPIKE-*`**（模板 `.cursor/templates/spike-regression-cluster.md`）或 **合并进原 Sprint**，禁止只加第三个 symptomatic patch |
| 仅 UX 微调、根因已闭环 | **`/delivery`** 走查确认缺口后再立项；plan 写 **与上版差异** |
| `workflow.followup_gate.require_spike` = true | 无 `SPIKE-*` 归档则 **AskQuestion** 是否豁免 |

立项表须含：**根因类型**（对照 `async-progress` · `long-running-ui` · `modal-layering` · `error-context` · `single-detector`）· **为何本次一次性修完** · **回归测矩阵**（L1/L2）。

### 对外门面 · README（禁止事后补 DOC Sprint）

根目录 `README.md` 是 Super Cursor **产品首页**。凡 Sprint 改变用户可见能力，**须在同一 Sprint 内**同步 README，**禁止**「功能 Sprint ✅ → 另开 SPRINT 专补 README」。

| 变更类型 | 规划要求 |
|----------|----------|
| 新增/改名 skill · agent · `/` 指令 | Done when 含 `cursor-coherence.sh`；最后一项 P0 或各 TASK 的 Target 含 `README.md` |
| 仅内部 refactor · archive · 无对外行为 | README 可不碰 |
| 用户抱怨「文档滞后」 | 回流阶段 1：把 README 写进 **Done when**，勿只加 `DOC-*` |

阶段 2 拆 TASK 时：

- **推荐**：末位 P0 · Target `README.md` · Acceptance `bash .cursor/bin/cursor-coherence.sh`（与功能 TASK **同 Sprint**）
- **或**：每个改 `.cursor/skills/` · `agents/` · `master/` 的 TASK，Target 列 **同时** 写 `README.md`（同 commit 增量同步）
- **勿** 为补 README 单独开 Sprint，除非 Sprint Goal 本身就是文档重写
