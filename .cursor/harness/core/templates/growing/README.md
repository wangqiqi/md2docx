# .growing

**Git 不跟踪。** 项目特化与 Agent 产出**统一放此目录**，与通用 `.cursor/` SOP 分离。

## 目录

| 路径 | 用途 |
|------|------|
| `plan.md` | Sprint / TASK 工作副本（`runner.sh` · `/plan` · `/run`） |
| `archive/` | Sprint 笔记、审查清单等归档 |
| `learn/` | `/learn` 维护的项目认知（约定 · 模块地图 · 发版节奏） |
| `week-report/` | **week** skill 生成的周报（本地 Markdown） |
| `disk-snapshots/` | **disk** skill 磁盘快照 JSON 与 diff 报告 |
| `disk-paths.json` | （可选）自定义磁盘采集路径，模板见 `disk-paths.example.json` |
| `maintain-config.json` | （可选）维护脚本受保护目录与缓存列表 |
| `rules/local/` | 团队私有 `.mdc` rules（安装后常链到 `.cursor/rules/local`） |
| `logs/` | 可选：本地 hook 或会话日志 |
| `perception/` | 可选：用户偏好、临时上下文 |
| `session/persona.json` | 当前呼叫人格 id（会话态；`run-start` 优先注入） |
| `session/aliases.json` | （可选）项目昵称 → `persona_id`；覆盖母版 nicknames |
| `project-profile.json` | **机器可读**：主栈 · verify 启用面（`scaffold adapt --write`）；Schema 见同目录 `project-profile.schema.json` |
| `project-profile.example.json` | 安装种子（不覆盖已有 `project-profile.json`） |

### `learn/` 文件（安装或首条 prompt 自动种子）

| 文件 | 内容 |
|------|------|
| `learn/plan-conventions.md` | archive 命名 · 可选 plan 段落 · Sprint 标题 |
| `learn/dev-conventions.md` | verify 命令 · 分支 · 目录约定 |
| `learn/module-map.md` | 模块边界与依赖 |
| `learn/release-rhythm.md` | 发版与 CHANGELOG 习惯 |
| `learn/changelog-insights.md` | 近期变更摘要 |
| `learn/last-sync.md` | `/learn` 同步元数据 |
| `learn/acceptance.md` | （可选）delivery 验收路径 |
| `learn/cursor-platform.md` | Cursor 官方配置面对齐摘要 |

可选复制（`*.example.md` / `*.example.mdc`，按需改名去掉 `.example`）：

| 模板 | 用途 |
|------|------|
| `learn/ui-reference.example.md` | 跨仓库只读 UI 参考记录 |
| `learn/dual-dialect.example.md` | 双方言数据访问摘要 |
| `learn/release-tag-datetime.example.md` | 时间戳 tag 发版变体 |
| `rules/local/agent-verify.example.mdc` | Agent 分层验收 |
| `rules/local/dual-dialect.example.mdc` | 双方言查询纪律 |
| `temp-cleanup.example.json` | 测试 `/tmp` glob 契约 |

### Bugbot（可选 · 不进 `.growing/`）

PR 自动化审查配置在 **`.cursor/`**（非本目录）。模板：

| 模板 | 复制到 |
|------|--------|
| `templates/growing/BUGBOT.md` | `.cursor/BUGBOT.md` |
| `templates/growing/config/bugbot.yaml.example` | `.cursor/config/bugbot.yaml` |

启用：Dashboard 连接仓库 · Automations 打开 Bugbot。本地 `REV-*` 仍用 **review** skill。

### MCP · Cloud（可选 · 不进 `.growing/`）

| 模板 | 复制到 |
|------|--------|
| `templates/growing/mcp.json.example` | `.cursor/mcp.json` |
| `templates/growing/environment.json.example` | `.cursor/environment.json`（仅 `install`） |
| `templates/growing/environment.docker.json.example` | 可选：合并 `build` 段或整文件替换 |

详述 → `.cursor/docs/cursor-cloud.md` · 部署面 → **ops-deploy** skill。

种子：`.cursor/templates/growing/` · **`/learn`** 在已有文件上增量更新

## 如何更新

| 动作 | 入口 |
|------|------|
| 填约定、吸收 CHANGELOG | **`/learn`** |
| 改 Sprint / TASK | **`/plan`** · **`/run`** → `plan.md` |
| 加团队 rules | `rules/local/*.mdc` |

## 读取顺序（Agent）

1. `.cursor/rules` — 通用 SOP
2. `.cursor/config` — 路径与开关
3. **本目录** — `plan.md` · `learn/` · `archive/` 索引

## 注意

- 勿把 learn / plan / archive 内容复制进 `.cursor/` 再提交
- 团队共享认知用 wiki/docs；不要 commit `.growing/`
- `.cursorignore` 可排除 `logs/` · `perception/`；**勿** ignore 整个 `learn/` 或 `plan.md`
