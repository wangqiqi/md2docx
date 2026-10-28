# Quickstart — 5 分钟闭环

## 1. 安装

```bash
# 方式 A：指定目标路径
./install-super-cursor.sh /path/to/your-project --profile full

# 方式 B：母版首次 setup-shell，之后任意目录 install
cd /path/to/cursor-ai && ./install-super-cursor.sh --setup-shell
source ~/.bashrc
cd /path/to/your-project/src/any/deep/dir
install-super-cursor --replace

cd /path/to/your-project
```

`full` profile 会自动复制 `plan.md`。若仓库根尚无 `onekey_start.sh`，install / `growth-init` 会按 `growth.onekey_bootstrap`（默认开）从 `templates/project-onekey/` 铺一份薄菜单（→ `scripts/test.sh` · `scripts/verify.sh`；**不覆盖**已有文件）。`/scaffold apply` 亦经 `_shared/onekey_start.sh` 同源铺设。

**记三个 slash 即可**：`/run`（做事）· `/plan`（拆 Sprint）· `/master`（真迷路）。

| 层 | Slash |
|----|-------|
| 【日常】 | `/run` · `/plan` · `/master` |
| 【生命周期】 | `/scaffold` · `/learn` · `/long` · `/release` |
| 【高级】 | `/delivery` · `/manual` · `/report`（ux/ia/debug 等 → skill-only） |

| profile | 适合 |
|---------|------|
| `full` | 团队（默认） |
| `lite` | 个人，无 hooks |
| `rules-only` | 只要规范 |

**已有项目升级 `.cursor/`**（保留 `.growing/`）→ [consumer-refresh.md](consumer-refresh.md)（`--replace` · 自检清单）· 栈与 **按需启用** → [tech-stacks.md](tech-stacks.md)（`scaffold adapt`）。

## 2. 空项目：脚手架（8 栈）

含 `java-gradle`；完整清单 → `scaffold.sh list` · [tech-stacks.md](tech-stacks.md)。

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
/long              # Epic 长程：多 Sprint plan/run 链（单 Sprint 跳过）
/delivery          # UI/功能 Sprint：release 或发版前建议走查
/manual            # 可发布使用说明书（可选）
/report            # verify 绿后测试报告汇总（可选）
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
bash .cursor/template-verify.sh     # 纯母版全量（CI 入口；含 consumer smoke）
bash .cursor/verify-super-cursor.sh     # layout + 8 道门禁；混合仓 hybrid 自动
bash .cursor/bin/consumer-smoke.sh      # 目标项目端到端：install → 闸门 BLOCK → hook → 放行 → 全绿
bash .cursor/bin/cursor-coherence.sh    # 交叉自洽
```

门禁清单 → `rules/feedback/verify.mdc` §母版门禁清单 · 混合仓见 [platforms.md](platforms.md) §自测。
English quickstart → [quickstart.en.md](quickstart.en.md)。

## 跨平台

Linux · macOS · **Windows + Git Bash**。无 `rsync` 时 install/hooks 自动 `cp -a`；无 `jq` 时可用 **python3** 回退。详见 [platforms.md](platforms.md)。
