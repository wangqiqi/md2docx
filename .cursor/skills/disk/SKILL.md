---
name: disk
description: >-
  磁盘快照（/disk）：结构化采集 HOME 与可配置路径占用，写入 .cursorGrowth/disk-snapshots/，
  并与上次快照对比变动。说「磁盘快照」「空间变动」「disk snapshot」时也触发。
disable-model-invocation: true
---

# disk · 磁盘快照

结构化采集磁盘占用，写入 **`.cursorGrowth/disk-snapshots/`**（本地、**不提交 git**），支持对比两次快照的变动。

## 何时进入

- 用户说 **`/disk`**
- 「磁盘快照」「空间占用」「哪个目录变大了」「disk snapshot」

## 流程（Agent 一次跑完）

### 1. 采集快照

```bash
python3 .cursor/skills/disk/scripts/collect-disk.py snapshot
```

可选：

- `--home ~` — HOME 目录（默认 `~`）
- `--project-dir .` — 相对路径类条目（`./build` 等）的基准目录
- `--snapshot-dir .cursorGrowth/disk-snapshots`（默认已是）
- `--config .cursorGrowth/disk-paths.json` — 自定义采集表（见模板 `templates/cursorGrowth/disk-paths.example.json`）

### 2. 对比变动（需 ≥2 份快照）

```bash
python3 .cursor/skills/disk/scripts/collect-disk.py diff
```

输出 `.cursorGrowth/disk-snapshots/diff-latest.md`，并打印 Markdown 对比表。

### 3. 查看

```bash
python3 .cursor/skills/disk/scripts/collect-disk.py list
python3 .cursor/skills/disk/scripts/collect-disk.py report
```

### 4. 确认

```bash
git status   # .cursorGrowth/ 不应出现在待提交列表
```

**禁止** `git add .cursorGrowth/disk-snapshots/`。

## 快照结构

每次快照为 JSON；默认路径见 `skills/disk/config/default-paths.json`：

| 分组 | 示例 key |
|------|----------|
| 根分区 | `disk.root` |
| Home | `home.workspace` · `home.cache` · `home.downloads` … |
| IDE | `ide.cursor` · `ide.cursor_state` · `ide.vscode` |
| 当前项目 | `pkg.build` · `pkg.node_modules` · `pkg.target`（相对 `--project-dir`） |

对比时按 **变动绝对值** 排序。可在 `.cursorGrowth/disk-paths.json` 增删路径，**勿写入个人信息**。

## 与 maintain 的分工

| 工具 | 职责 |
|------|------|
| **maintain** | 诊断 + 安全清理 |
| **disk** | 只读快照 + diff |

建议：清理前/后各 `snapshot`，中间 `--clean`，最后 `diff`。
