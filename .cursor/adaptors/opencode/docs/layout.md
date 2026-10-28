# OpenCode `.opencode/` 布局（Super Cursor · `includes: core`）

OpenCode 官方安装根 **待确认**（见 [opencode.ai/docs](https://opencode.ai/docs)）；本布局与 **dsh** 相同假设：Harness Core 平铺到 `.opencode/`。若官方规范冲突，以 SPIKE 更新本文件与 `install-adaptor-opencode.sh`。

## 目标路径

| 项 | 值 |
|----|-----|
| 安装根 | **`.opencode/`** |
| Growth | **`.growing/`**（共享） |
| hooks | **无**（`hooks_manifest`: null） |

## 目录树（安装后）

与 [dsh layout](../../dsh/docs/layout.md) 同构（将 `.dsh` 换为 `.opencode`）：

```text
.opencode/
├── README.md
├── AGENTS.md
├── skills/
├── rules/
├── bin/
├── config/
├── templates/
├── docs/
├── agents/
└── lib/
```

**刻意不含**：`harness/` · `adaptors/` · 母版 `verify-super-cursor.sh` · cursor-only 切片。

## `core` 包映射

| 源（母版） | 目标 |
|------------|------|
| `.cursor/harness/core/*` | `.opencode/*` |
| 排除 `harness/core/rules/local` | — |
| `.cursor/adaptors/opencode/README.md` | `.opencode/README.md` |

## 安装

```bash
bash .cursor/harness/core/bin/install-adaptor-opencode.sh /path/to/project
install-super-cursor /path/to/project --adaptor opencode
```

## 验收

`bash .cursor/bin/verify-install-opencode.sh`
