# Quickstart — 5 分钟闭环

## 1. 安装

```bash
./install-super-cursor.sh /path/to/your-project --profile full
cd /path/to/your-project
```

`full` profile 会自动复制 `plan.md`。**记三个 slash 即可**：`/run`（做事）· `/plan`（拆 Sprint）· `/master`（真迷路）。

| 层 | Slash |
|----|-------|
| 【日常】 | `/run` · `/plan` · `/master` |
| 【生命周期】 | `/scaffold` · `/learn` · `/release` |
| 【高级】 | `/delivery`（其余如 ux/ia/debug → skill-only） |

| profile | 适合 |
|---------|------|
| `full` | 团队（默认） |
| `lite` | 个人，无 hooks |
| `rules-only` | 只要规范 |

## 2. 空项目：脚手架（7 栈）

```
/master  或  /scaffold
```

```bash
./.cursor/bin/scaffold.sh list
./.cursor/bin/scaffold.sh apply go-api --dry-run
./.cursor/bin/scaffold.sh apply go-api
./scripts/verify.sh
```

## 3. 学习与规划

```
/learn
/plan
```

验收列：`./scripts/test.sh`（开发）· `./scripts/verify.sh`（收尾）

## 4. 执行与发版

```
/run
/delivery          # UI/功能 Sprint：release 或发版前建议走查
/release           # merge / PR / 打 tag（可选）
./.cursor/bin/runner.sh verify
release / ship
```

## 端到端示例

[walkthrough.md](walkthrough.md)

## 效果型效率

少拉扯才是真省 — `/plan` 对齐方向 · `task-verify` 验收收口 · 一事一对话。详见 [effective-collaboration.md](effective-collaboration.md)

## 母版自测

```bash
bash .cursor/verify-super-cursor.sh    # layout；混合仓 hybrid 自动
bash .cursor/bin/cursor-coherence.sh
bash .cursor/bin/template-verify.sh    # 纯母版全量
```

混合仓见 [platforms.md](platforms.md) §自测 · `rules/feedback/verify.mdc`。

## 跨平台

Linux · macOS · **Windows + Git Bash**。无 `rsync` 时 install/hooks 自动 `cp -a`；无 `jq` 时可用 **python3** 回退。详见 [platforms.md](platforms.md)。
