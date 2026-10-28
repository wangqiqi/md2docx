<!-- adaptor-contract:v1 -->

# adaptor: zcode

ZCode（CLI 编码智能体）· Harness Core **独立安装**到 `.zcode/`，与 Cursor 安装并存互不影响；`.growing/` 共用。

## Status

**implemented（core install + hooks）** — 按 [docs/layout.md](docs/layout.md) 平铺 core 树；安装时对文本做运行时路径改写（`./.cursor/` → `./.zcode/`）；hooks 映射 `SessionStart` / `UserPromptSubmit` / `Stop`（脚本源自 `adaptors/cursor/hooks`，实现与 Cursor 无关）。

## Identity

`adaptor id`: **zcode**

## Install map

与 `install-map.example.json` → `adaptors.zcode`：

| 字段 | 值 |
|------|-----|
| `install_dir` | `.zcode` |
| `growth_dir` | `.growing` |
| `hooks_manifest` | `.zcode/config.json`（ZCode 原生 `hooks` 键，须 `hooks.enabled: true`） |

## Includes

- `core` — Harness Core 主体（skills · rules · bin · config 等）；见 [adaptor-contract.md](../../harness/core/docs/reference/adaptor-contract.md) §`includes` token。安装时整树做 `.cursor/` → `.zcode/` 路径改写。

## Install

```bash
bash .cursor/harness/core/bin/install-adaptor-zcode.sh /path/to/project
```

布局 SSOT → [docs/layout.md](docs/layout.md) · 验收 `bash .cursor/bin/verify-install-zcode.sh`。

## Next sprint

- Cursor 专属 frontmatter（`disable-model-invocation` 等）在 ZCode 的语义对齐（当前按未知键忽略）
- 与 ZCode 内建/plugin skills 的重名冲突审计（workspace scope 优先于 plugin，重名会遮蔽内建）
- 供 `install-super-cursor.sh --adaptor zcode` 的聚合安装接入
