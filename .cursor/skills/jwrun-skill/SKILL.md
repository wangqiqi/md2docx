---
name: jwrun-skill
description: md2docx 自治开发执行 skill（入口 /jwrun）：gate-check → ACTIVE → 实现 → 任务级验收 → CHANGELOG → commit → 打版归档 → 链下一项。用户说「继续」「jwrun」「自治开发」「dev-run」或 /jwrun、stop hook 时使用。规划用 jwplan-skill。
---

# jwrun · 开发执行（skill `jwrun-skill`）

> **入口**：Command **`/jwrun`**（短名）→ 加载本 skill。Command 与 skill 分层，避免同名混淆。

## 目标

在**最少人工介入**下，按根目录 `plan.md` 推进编码：一项一 ACTIVE，测过才 ✅，**每任务必须 git commit + patch 打版 tag**（CHANGELOG + 版本文件）。规划由 **`jwplan-skill`**（`/jwplan`）完成；遇 ⚠️ 阻塞回流 **`/jwplan`**。

## 自治策略（`AUTONOMOUS: true` 时默认开启）

**jwrun 一旦启动，按本 skill 建议直接执行，不向用户确认「是否继续」「要不要 push/打版」等例行步骤。**

仅以下两类**必须暂停并征得用户同意**：

| 须确认 | 示例 |
|--------|------|
| **高风险删除** | `rm`、覆盖大文件、批量删目录 |
| **项目外操作** | 改 `md2docx` 仓库根目录以外的路径、动其他 git 仓库、系统级配置 |

**高风险删除的替代做法**（禁止直接 `rm`）：

```bash
mkdir -p archive/_delete/YYYYMMDD_HHMMSS_删除_简述
mv <待删路径> archive/_delete/YYYYMMDD_HHMMSS_删除_简述/
```

- `archive/` 为本地归档区（已 gitignore），用户可事后清空或恢复

**无须确认、直接做**：gate-check · task-verify · commit · 打版 tag · 链下一 ACTIVE · 修验收失败 ≤2 轮

## 启动闸门（必须先过，否则立即停止）

```bash
./.cursor/bin/dev_runner.sh gate-check
```

| 结果 | 动作 |
|------|------|
| `BLOCK: PLANNING=true` | 停止，提示 `/jwplan` |
| `BLOCK: 无 PLAN_APPROVED` | 停止，提示 `/jwplan` 确认并写日期 |
| `OK` | 继续单轮 |

**禁止**在闸门未过时写业务代码。

## 启动时必读

1. `plan.md` 元数据（`ACTIVE` · `NEXT` · `SPRINT` · `PLAN_APPROVED`）与活跃 Sprint 任务表
2. `<!-- PLANNING: true -->` 时 **停止**：提示 `/jwplan`
3. `.cursor/hooks/state/jwrun.json`（若存在）
4. 规则：`code_quality` · `ci_cd_quality` · `docs/testing.md`
5. `./.cursor/bin/dev_runner.sh next_version`

## 单轮流程（严格顺序）

```
gate-check → … → patch 打版 → 推进 ACTIVE → [Sprint 全 ✅] → verify → **刷新审计快照** → 归档 → /jwplan
```

### 1. 锁定任务

- `ACTIVE` 来自 plan 注释或任务表 `🔧` 行
- 若无 ACTIVE：`<!-- NEXT -->` 或 `next-task`（**执行顺序**优先）；写入 `<!-- ACTIVE -->` 并标 `🔧`
- **禁止**同时多个 ACTIVE
- **禁止**完成后留空 ACTIVE：立即写下一项 ID + `<!-- NEXT -->`

### 2. 实现

- 只改「落点/验收」列涉及文件
- 不顺手重构无关模块
- 遵循 `code_quality` 与 `docs/development.md`

### 3. 分层验收（必须执行，禁止空口完成）

**每任务**（快路径）：

```bash
./.cursor/bin/dev_runner.sh task-verify
./.cursor/bin/dev_runner.sh task-verify M-CONV-01-01
```

优先级：

1. 任务表「验收」列若为 shell 命令 → 直接执行
2. 否则 CLI 按 pytest 启发式推断
3. 仍无法执行 → Agent 按验收列**手动跑**并贴退出码

**全量 VERIFY**（慢路径，里程碑时机）：

- Sprint **全部 ✅** 闭合归档前
- 每 **5** 个 patch 打版或 P0 段落闭合时（取先到者）
- 或任务验收列明确写「全量」

```bash
./.cursor/bin/dev_runner.sh verify
```

失败：自修 ≤ **2** 轮；仍失败标 `⚠️ 阻塞`、**停止自治链**、回流 **`/jwplan`**。

### 4. 文档收尾

- `🔧` → `✅`
- `CHANGELOG.md` **[Unreleased]** 追加（行为 + WHY）；若无 `[Unreleased]` 节则先创建
- **按执行顺序推进**：

```bash
next="$(./.cursor/bin/dev_runner.sh next-task)"
```

写入 `<!-- ACTIVE: ${next} -->` 与 `<!-- NEXT: ${next} -->`；更新 `<!-- LAST_DONE: 刚完成ID -->`

### 5. Git 提交（每任务必须）

```bash
git commit -m "$(cat <<'EOF'
M-CONV-01-01 修复 CLI 帮助信息多语言切换。

EOF
)"
```

### 6. Patch 打版（每任务 commit 后**必须**，禁止堆积无 tag）

**禁止**多任务共用一个 tag 或只写 [Unreleased] 不打版。

```bash
ver="$(./.cursor/bin/dev_runner.sh next_version)"
```

> **版本线**：`next_version` 读 plan `<!-- VERSION_LINE: 0.4 -->`，打版 tag 为 **v0.4.x**。

**Step A** — `CHANGELOG.md`：当前任务条目从 `[Unreleased]` 升为 `## [${ver}]`（保留空 `[Unreleased]` 占位）  
**Step B** — 同步版本号：`pyproject.toml` `[project].version`、`src/mddocx/__init__.py` 的 `__version__`  
**Step C** — `plan.md`：`<!-- RELEASED: v${ver} -->` · 基线行同步  
**Step D** — `git add CHANGELOG.md plan.md pyproject.toml src/mddocx/__init__.py` → `git commit` + `git tag v${ver}`

```bash
git commit -m "$(cat <<EOF
release: v${ver} ${TASK_ID} ${摘要一句}。
EOF
)"
git tag "v${ver}"
```

### 7. Sprint 闭合归档（表内全部 ✅ 时，在 §6 之后）

**Step A** — `./.cursor/bin/dev_runner.sh verify` 全量（记录 `N passed, M skipped` 与可选 `--cov` 摘要）  
**Step B** — **刷新 plan 审计快照**（见下节，**禁止**只改任务表而留 jwplan 旧 ⚠️）  
**Step C** — plan `AUTONOMOUS: false` · Sprint 标题 `活跃` → `已闭合` · ROADMAP 对应行 → **已完成**  
**Step D** — 写入 `archive/sprint/YYYYMMDD_HHMMSS_{主题}_{SPRINT_ID}_Sprint闭合_打版_vX.Y.Z.md`（含 verify 输出与任务/tag 表）  
**Step E** — `## 已闭合 Sprint` 表补归档链接 · `## 变更记录` 追加 §7 一行  
**Step F** — ROADMAP 有余项 → 建议 **`/jwplan`**

#### 7B · 刷新审计快照（Sprint 闭合必做）

jwplan 写入的 **审计叙事**（如 `### …审计结论`、`| 维度 | 现状 |`、`**结论**`、`**WHY**`）是**开工前快照**；Sprint 全部 ✅ 后必须用 **verify 实测** 更新为 **闭合快照**，否则 plan 与代码/CI 脱节。

**触发**：仅 Sprint 表内任务**全部 ✅** 时（最后一项打版后、归档前）。单任务轮次**不**改审计表。

**必改块**（Sprint 节内，按 jwplan 实际标题匹配）：

| 块 | 动作 |
|----|------|
| `> **WHY**` | 补闭合后基线（如 `176 passed · ~81% cov`、版本区间） |
| `### …审计结论` | 改为 **规划快照 vs 闭合快照** 对照表（或更新「闭合后」列） |
| `**结论**` | 写闭合后评价 + **仍开放的远期债务**（未在本 Sprint 范围者） |
| `### 现状（为何做）` | 改为 **`### 闭合对照`**：原缺口 → 任务 ID → ✅/🔲 |
| `## 活跃 Sprint` 标题 | → `## 已闭合 Sprint · {SPRINT_ID}` |
| `## ROADMAP` | 本 Sprint 行 → **已完成** + 版本备注 |
| `## 已闭合 Sprint` | 补 `archive/sprint/…` 链接（勿留「待 §7 归档」） |

**闭合快照数据来源**（须实际执行，禁止抄旧数）：

```bash
./.cursor/bin/dev_runner.sh verify          # passed/skipped 真源
# 可选：pytest tests/ src/mddocx/webui/tests/ --cov=src --cov-report=term | tail -5
```

**对照表写法**（三列示例）：

```markdown
| 维度 | 规划时（jwplan） | 闭合后（jwrun §7） | 评价 |
| **规模** | 169 passed, 2 skipped | **176 passed, 2 skipped** | ✅ 01-01~06 |
```

**无专用审计节的 Sprint**：在 Sprint 节末增 **`### 闭合快照（jwrun §7）`** 小节，至少含 verify 结果、版本 tag 区间、闭合条件核对。

**变更记录**追加示例：

```markdown
- **YYYY-MM-DD** · **{SPRINT_ID} §7 闭合** · vX.Y.A–vX.Y.Z · {N} passed · 审计快照已同步
```

**禁止**：Sprint 已闭合仍保留 jwplan 时代的 ⚠️（如「advanced 未自动化」）而不标注已闭合。

### 8. 链式继续

- Sprint 闭合：**§6 打版已逐任务完成** → 再 §7 归档
- `AUTONOMOUS: true` 且已 commit：**同 session 继续**
- `MAX_LOOPS` / ⚠️：停止

## 禁止

- 跳过 gate-check / task-verify 宣称完成
- **Sprint 闭合后仍留 jwplan 审计旧快照**（未执行 §7B）
- **commit 后不打版**（无 tag）
- 每任务都跑全量 `pytest`（patch 打版仅需 task-verify）
- `PLANNING: true` 时编码
- 遇阻塞硬跑

## stop hook 协作

`jwrun-stop.sh` 注入 `followup_message` 时：**立即**执行本 skill（含 gate-check + task-verify + commit）。

## 命令行辅助

```bash
./.cursor/bin/dev_runner.sh gate-check
./.cursor/bin/dev_runner.sh task-verify
./.cursor/bin/dev_runner.sh verify
./.cursor/bin/dev_runner.sh next-task
./.cursor/bin/dev_runner.sh release-check
```
