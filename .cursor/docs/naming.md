# 命名与官方约定

Super Cursor 命名：**短、见名知意、不与 Cursor 内置冲突**。

## 速查

| 类型 | 本模板 | 避开 |
|------|--------|------|
| Skill | `master` `plan` `run` `learn` `scaffold` `git` `release` `security` `api` | `shell` `loop` `canvas` `sdk`…（见下） |
| Agent | **`ship`**（发版 subagent） | **`release`**（Cursor 内置 subagent） |
| Command | **【日常】** `/run` `/plan` `/master` · **【生命周期】** `/scaffold` `/learn` `/release` · **【高级】** `/delivery` `/ux` `/ia` · **【运维】** `/week` `/disk` `/maintain` |
| Config | `workflow.json` `release.json` | — |
| Hooks 脚本 | `growth-init` `run-start` `run-stop` | 事件名用官方：`sessionStart` `stop` 等 |

## Skills

- 路径：`.cursor/skills/<name>/SKILL.md`
- `name` 字段：小写、短词；与文件夹名一致
- **禁止**写入 `~/.cursor/skills-cursor/`（Cursor 内置目录）

### 内置 skill 名（勿占用）

`canvas` `loop` `shell` `sdk` `automate` `babysit` `create-skill` `create-hook` `create-rule` `create-subagent` `migrate-to-skills` `split-to-prs` `statusline` `update-cli-config` `update-cursor-settings` `onboard` `review-bugbot` `review-security`

## Agents

- 路径：`.cursor/agents/<name>.md`
- `name`：小写字母与连字符（官方要求）

### 为何 agent 叫 `ship` 而非 `release`

Cursor Task 体系有内置 subagent **`release`**。项目 `.cursor/agents/release.md` 会**覆盖**同名内置 agent。

本模板将发版 subagent 定为 **`ship`**，打版 checklist 仍用 skill **`release`**，职责分离、无冲突。

## 易混语义（非冲突）

| 名称 | 本模板 | Cursor 其他含义 |
|------|--------|-----------------|
| `plan` | 规划 skill + `/plan` | IDE **Plan 模式**（只读规划 UI；`CreatePlan` 等为模式内工具） |
| `run` | 执行 skill + `/run` | Agent 一次 run（口语） |
| `release` | Sprint 出口 **skill**（§分支 + §打版） | 内置 **release** subagent（我们用 `ship` 代替） |
| `review` | 项目 **review** skill + **review** agent（REV-* · PR 清单） | 全局 `~/.cursor/skills-cursor/review`（路由 Bugbot / Security Review） |
| `week` · `disk` · `maintain` | skill + **`/week` `/disk` `/maintain`** slash | 亦可关键词触发 |

## 官方工具与模型差异（Agent 须知）

| 工具 / 能力 | 约定 |
|-------------|------|
| **AskQuestion** | 优先用；**部分模型未注入**（官方对 Cursor Grok 曾确认）→ **正文编号选项**（**master**「AskQuestion 约定」） |
| **SwitchMode** | 平台级：通常仅 Agent → Plan；勿假定可切 Debug/Ask |
| **CreatePlan** | Plan 模式会话工具；Agent 模式 SOP 不依赖 |
| **GetMcpTools → CallMcpTool** | MCP 调用前先取 schema（见 **mcp** skill） |
| **Task** | 子代理；可用性随模式/模型变化，失败则母会话自办 |

本模板 **不绑死** Cursor 内部 tool 旧名（如已废弃的 `edit_file` / `run_terminal_cmd`）；以会话实际工具表为准。

## 五层关系（commands · skills · agents · rules · hooks）

```text
你记的 slash          commands/*.md（薄）     skills/*.md（SOP）
【日常】/run /plan /master ────────────────→ run · plan · master
【生命周期】/scaffold /learn /release ─────→ scaffold · learn · release
【高级】/delivery /ux /ia ─────────────────→ delivery · ux · ia
【运维】/week /disk /maintain ─────────────→ week · disk · maintain
git · test · api … ────────────────────────→ Agent 按 plan 自动读 skill（无 slash）

agents/     仅委派：ship（自治打版）· review/spike（只读）
rules/      编辑匹配文件时 glob 自动加载
hooks/      会话：growth-init · plan 上下文注入
```

**review**（项目内）：同名 **skill**（母会话清单）+ **agent**（只读子进程）— 委派时用 agent。  
**全局 review**（`skills-cursor/review`）只路由 Bugbot / Security — 与项目 REV-* 无关；安全专项优先 **security** skill。

## Rules

- 格式：`.mdc` + YAML frontmatter
- 文件名：短词，如 `core.mdc` `workflow.mdc` `commit.mdc`

## Hooks

- 配置：`.cursor/hooks.json`，`version: 1`
- 脚本：`.cursor/hooks/*.sh`，名称自定；**事件 key 必须用官方名**

## 项目认知

- **不得**把 CHANGELOG 摘要等写入 `.cursor/`
- 统一 → `.cursorGrowth/learn/`（git 忽略），入口 **`/learn`**

## 验证

```bash
bash .cursor/verify-super-cursor.sh
```

检查含：无 `agents/release.md`、存在 `agents/ship.md`、无旧版 jw 前缀 skill 名。
