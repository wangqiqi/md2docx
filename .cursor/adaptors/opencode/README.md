<!-- adaptor-contract:v1 -->

# adaptor: opencode

OpenCode · Harness Core 安装到 `.opencode/`。

## Status

**implemented（core install）** — 官方 OpenCode layout **待确认**；当前按 [docs/layout.md](docs/layout.md) 平铺 core（同 dsh 模式）。

## Identity

`adaptor id`: **opencode**

## Install map

与 `install-map.example.json` → `adaptors.opencode`：

| 字段 | 值 |
|------|-----|
| `install_dir` | `.opencode` |
| `growth_dir` | `.growing` |
| `hooks_manifest` | **null** |

## Includes

- `core` — Harness Core 主体；见 [adaptor-contract.md](../../harness/core/docs/reference/adaptor-contract.md)。

## Install

```bash
bash .cursor/harness/core/bin/install-adaptor-opencode.sh /path/to/project
install-super-cursor /path/to/project --adaptor opencode
```

布局 SSOT → [docs/layout.md](docs/layout.md) · 验收 `bash .cursor/bin/verify-install-opencode.sh`。

## Next sprint

OpenCode 官方安装根钉死后：对照 SPIKE 差距表更新 `layout.md` / `install-adaptor-opencode.sh`（另开 Sprint；当前与 dsh 同 core 平铺假设）。
