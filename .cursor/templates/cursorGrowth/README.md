# .cursorGrowth

**Git 不跟踪。** 项目特化与 Agent 产出**统一放此目录**，与通用 `.cursor/` SOP 分离。

## 目录

| 路径 | 用途 |
|------|------|
| `plan.md` | Sprint / TASK 工作副本（`runner.sh` · `/plan` · `/run`） |
| `archive/` | Sprint 笔记、审查清单等归档 |
| `learn/` | `/learn` 维护的项目认知（约定 · 模块地图 · 发版节奏） |
| `week-report/` | `/week` 生成的周报（本地 Markdown） |
| `disk-snapshots/` | `/disk` 磁盘快照 JSON 与 diff 报告 |
| `disk-paths.json` | （可选）自定义磁盘采集路径，模板见 `disk-paths.example.json` |
| `maintain-config.json` | （可选）维护脚本受保护目录与缓存列表 |
| `rules/local/` | 团队私有 `.mdc` rules（安装后常链到 `.cursor/rules/local`） |
| `logs/` | 可选：本地 hook 或会话日志 |
| `perception/` | 可选：用户偏好、临时上下文 |

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

种子：`.cursor/templates/cursorGrowth/` · **`/learn`** 在已有文件上增量更新

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
- 团队共享认知用 wiki/docs；不要 commit `.cursorGrowth/`
- `.cursorignore` 可排除 `logs/` · `perception/`；**勿** ignore 整个 `learn/` 或 `plan.md`
