# Walkthrough — 端到端闭环

跟着做一遍，约 **15 分钟** 走完安装 → 脚手架 → 规划 → 执行 → 验收。默认用 **go-api**；其他栈替换 scaffold id 即可。

## 0. 安装

```bash
/path/to/super-cursor/install-super-cursor.sh /path/to/demo-app --profile full
cd /path/to/demo-app
```

`full` profile 会引导复制 `templates/plan.md` → **`workflow.json` 的 `plan_file`**（Growth 工作副本）。不确定下一步 → 对 Agent 说 **`/master`**。

## 1. 脚手架

对 Agent 说 **`/scaffold`**，或手动：

```bash
./.cursor/bin/scaffold.sh apply go-api --dry-run   # 预览会创建什么
./.cursor/bin/scaffold.sh apply go-api
go mod tidy
./scripts/verify.sh                              # 应该全绿（scaffold 后生成）
```

## 2. 学习 + 规划

```text
/learn     → 写入模块路径、verify 命令到 .cursorGrowth/learn/
/plan      → 在 `plan_file`（Growth 工作副本）上拆真实 Sprint
```

验收列示例：

| ID | Acceptance |
|----|------------|
| TASK-001 | `./scripts/test.sh` |
| TASK-002 | `./scripts/verify.sh` |

## 3. 执行

```text
/run       → gate-check → 实现 → task-verify → commit → next-task
/ux        → 体验问题分流 → ia（结构）或 delivery（抛光）
/ia        → 导航/角色/工作流 IA 规划或审查（docs/design/*-ia*）
/delivery  → （UI/功能）release 分支或发版前 7 维走查
/release   → merge / PR / 打 tag（可选）
```

CLI 自检：

```bash
./.cursor/bin/runner.sh gate-check
./.cursor/bin/runner.sh task-verify
./.cursor/bin/runner.sh verify
```

## 4. 发版（可选）

- 清单模式：让 Agent 读 **release** skill（含 **delivery** 建议项）
- 自治模式：委派 **ship** agent
- UI/功能版本：发版前 **`/delivery`** 无 Blocker

## 栈对照

| 目标 | scaffold id |
|------|-------------|
| React SPA | `react-vite-ts` |
| Vue SPA | `vue-vite-ts` |
| Next.js | `nextjs-ts` |
| Go API | `go-api` |
| Rust API | `rust-axum` |
| Python API | `python-fastapi` |
| Java | `java-gradle` |
| C++ | `cpp-cmake` |

## profile 选择

| profile | 适合 |
|---------|------|
| `full` | 团队 · plan/run + hooks |
| `lite` | 个人 · plan/run 无 hooks |
| `rules-only` | 只要 rules/skills |

```bash
install-super-cursor.sh . --profile lite
```

回到 [根 README](../../README.md) · 更多场景见 [.cursor/README.md](../README.md)
