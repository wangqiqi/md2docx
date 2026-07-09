# Super Cursor — `.cursor/`

通用 SOP 目录。安装到目标项目后默认**只读**；项目认知 → `.cursorGrowth/learn/`（git 忽略）。

## 结构

| 始终加载 | `rules/core.mdc` · `rules/workflow.mdc` |
| 按需 | skills · glob rules · `learn/` |

```
rules/   communication · execution · feedback · tech
skills/  master plan run learn scaffold git release …（SOP 正文；日常只记 plan/run/master）
commands/ 三层 slash（薄入口 → 加载 skill；见下表）
agents/  ship review spike（子进程委派；日常不必记）
hooks/   growth-init run-start run-stop
config/  workflow.json release.json roles.json
bin/     runner.sh scaffold.sh install-smoke.sh cursor-coherence.sh platform-check.sh template-verify.sh
lib/     platform.sh（跨平台工具）
templates/scaffold/   manifest + stack templates
```

```bash
bash .cursor/bin/template-verify.sh          # 母版全量（推荐）
bash .cursor/verify-super-cursor.sh          # layout 存在性
bash .cursor/bin/cursor-coherence.sh         # 交叉自洽
bash .cursor/verify-system.sh                # 同上 layout（alias）
```

命名：[docs/naming.md](docs/naming.md)

## Slash 入口（三层 · 记前两层即可）

slash 菜单按 **【日常】→【生命周期】→【高级】** 标注；Agent 可自动选用的 skill **不必死记 slash**。

### 【日常】80% 时间

| Command | 何时用 | Skill |
|---------|--------|-------|
| **`/run`** | 已有 TASK · 写代码 · 修 bug（**默认入口**） | run |
| **`/plan`** | 新开 Sprint · 拆 Goal/TASK（无 ACTIVE 时） | plan |
| **`/master`** | 真迷路 · 刚安装 · 不知 slash（**勿滥用**） | master |

### 【生命周期】Sprint 前后

| Command | 何时用 | Skill |
|---------|--------|-------|
| `/scaffold` | 空仓库建栈 · 已有项目 audit | scaffold |
| `/learn` | 让 Agent 了解本项目 | learn |
| `/release` | merge / PR / 打 tag（Sprint 出口） | release |

### 【高级】按需 · Agent 也常自动选用

| Command | 何时用 | Skill |
|---------|--------|-------|
| `/delivery` | UI/功能 Sprint 发版前 7 维走查 | delivery |
| `/ux` | 体验问题 · 类型不明先分流 | ux |
| `/ia` | 导航/角色/信息架构大改 | ia |

## 使用场景

完整路由与关键词索引 → **`skills/master/routes.md`**（master AskQuestion 的 canonical 源）。  
培训速查 → [docs/training/skills.md](docs/training/skills.md) · 端到端示例 → [walkthrough.md](docs/walkthrough.md)。

### 推荐路径

```
空仓库:  /master → /scaffold → /learn → /plan → /run → verify
迭代:    /plan → /run（循环）
卡住:    /master → fix → /run 或 /plan
迷路:    /master（主菜单 7 项 → 子路由）
```

### 技术栈细则（glob 自动加载）

| 类别 | 规则 | 典型 glob |
|------|------|-----------|
| 前端 | `typescript` · `react` · `vue` · `nextjs` · `eslint` · `javascript` | `*.ts(x)` · `*.js(x)` · `*.vue` |
| 后端 / 系统 | `python` · `go` · `rust` · `java` · `cpp` · `c` | `*.py` · `*.go` · `*.rs` · `*.java` · `*.{c,cc,cpp,h,hpp}` |

治理：`constitution.mdc` · `evolution.mdc` · `config/roles.json`（12 人格，仅语气）。  
扩展 skills：**ux** · **ia** · **debug** · **test** · **review** · **study** · **delivery** · **mcp** · **refactor** · **perf** · **disk** · **maintain** · **week**（入口见 `core.mdc`）。

### 重复劳动 SOP（rules · 通用）

| 模式 | 位置 |
|------|------|
| 分层验收 verify-layers | `rules/feedback/verify.mdc` · **test** skill |
| 全栈垂直切片 | `rules/execution/vibe.mdc` · **api** skill |
| 文档自洽 doc-coherence | `rules/execution/docs.mdc` · **delivery** skill |
| 数据批处理 IN/分块 | `rules/execution/data-batch.mdc` |
| MCP 建服 | **mcp** skill · `skills/mcp/reference/` |
| 实验闭环 experiment-loop | **spike** agent · **learn** skill |

项目路径与聚合脚本名 → Growth `learn/`（如 `dev-conventions.md`），**勿**写进母版 `.cursor/`。

### 场景速查（摘要）

完整关键词与子路由 → **`skills/master/routes.md`**（canonical）。日常只需：

| 我想… | 入口 |
|-------|------|
| 做事 / 写代码 | **`/run`** |
| 拆 Sprint | **`/plan`** |
| 真迷路 | **`/master`** |
| 空仓 / 发版 / 交付 / UX·IA | `/scaffold` · `/release` · `/delivery` · `/ux` · `/ia` |

培训表 → [docs/training/skills.md](docs/training/skills.md)。

## 更多文档

- [Naming](docs/naming.md) · [plan/run](docs/plan-run.md) · [Quickstart](docs/quickstart.md)
- [Skills 速查](docs/training/skills.md) · [跨平台](docs/platforms.md)
