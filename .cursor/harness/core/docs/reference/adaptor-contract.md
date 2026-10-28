# Adaptor 最小契约（占位 · v1）

非 Cursor IDE 的 adaptor 在实现安装/导出前，须满足本契约，使 `install-map.example.json` 与仓库目录可机器验收。

**对照**：Harness × IDE 摘要 → [harness-ide-matrix.md](harness-ide-matrix.md)（完整 SPIKE 表在本地 `.growing/archive/meta/`）。

**v1 载体**：各 adaptor 的 `README.md` 章节 + `config/install-map.example.json` 字段；**不**要求 `adaptor.json`。

## 适用范围

| 类型 | adaptor id | 本契约 |
|------|------------|--------|
| 占位（本 Sprint） | `dsh` · `kiro` · `trae` · `opencode` | **必须** |
| 已实现 | `cursor` | 另有 hooks · plugin verify；本契约仅作字段对照，不在此 Sprint 改行为 |

## 目录布局

母版 SSOT：

```text
.cursor/adaptors/<adaptor id>/README.md
```

`verify-harness-layout.sh` 已要求上述四 id 存在 `README.md`；内容须符合下文。

## README 必备章节（机器检查）

每个占位 adaptor 的 `README.md` 须包含以下 **二级标题**（顺序不限），且文首 HTML 注释含 `adaptor-contract:v1`：

| 章节 | 内容要求 |
|------|----------|
| `## Status` | 写明 **placeholder**；官方 layout **待确认** 时直说 |
| `## Identity` | 一行 `adaptor id`: **&lt;id&gt;**（与目录名一致） |
| `## Install map` | 与 `install-map.example.json` 一致：`install_dir` · `growth_dir` · `hooks_manifest`（可为 `null`） |
| `## Includes` | 列出 `includes` 数组；说明各 token 语义（见下） |
| `## Next sprint` | 指向后续实现 Sprint ID（可多个候选，须可 grep） |

## `install-map.example.json` 字段映射

路径：`.cursor/harness/core/config/install-map.example.json` → `adaptors.<id>`。

| 字段 | 含义 |
|------|------|
| `install_dir` | 安装到目标项目时的根目录（如 `.dsh` · `.kiro`） |
| `growth_dir` | Growth 坐标（通常 `.growing`） |
| `includes` | 从 Harness Core 打入的包片段（**v1 仅文档化**，install 脚本未实现多 adaptor） |
| `hooks_manifest` | 生命周期 hooks 清单路径；无则 JSON `null`，README 写 `hooks_manifest`: **null** |

### `includes` token（v1 枚举）

以 `install-map.example.json` 为准，不得擅自新增键而不改 map：

| Token | 意图 |
|-------|------|
| `core` | Harness Core 主体（skills · rules · bin · config 等） |
| `core_rules_export` | 面向 Kiro/Trae 的 rules 导出 → [core-rules-export.md](core-rules-export.md) |
| `cursor_hooks` | Cursor 专用（仅 `cursor` adaptor） |
| `cursor_plugin_verify` | Cursor Plugin 冒烟（仅 `cursor` adaptor） |

## 占位 adaptor 对照表（与 install-map 同步）

| id | install_dir | includes | hooks_manifest |
|----|-------------|----------|----------------|
| `dsh` | `.dsh` | `core` | `null` |
| `kiro` | `.kiro` | `core_rules_export` | （map 未列则 README 写 **未定义**） |
| `trae` | `.trae` | `core_rules_export` | （同上） |
| `opencode` | `.opencode` | `core` | （同上） |

## 验收

```bash
bash .cursor/bin/verify-adaptor-contract.sh
```

母版聚合：`verify-super-cursor.sh` · `template-verify.sh`。

## 变更纪律

- 改 `install_dir` / `includes` → 同步 **install-map** · 四份 README · 本表
- 新增 adaptor id → 新建 `adaptors/<id>/` · map 条目 · 扩展 `verify-adaptor-contract.sh` 占位列表
