<!-- adaptor-contract:v1 -->

# adaptor: trae

Trae 项目规则 · `core_rules_export`。

## Status

**implemented（rules export）** — 官方 Trae layout **待确认**；当前导出 [docs/layout.md](docs/layout.md) · SSOT [core-rules-export.md](../../harness/core/docs/reference/core-rules-export.md)。

## Identity

`adaptor id`: **trae**

## Install map

与 `install-map.example.json` → `adaptors.trae`：

| 字段 | 值 |
|------|-----|
| `install_dir` | `.trae` |
| `growth_dir` | `.growing` |
| `hooks_manifest` | **null** |

## Includes

- `core_rules_export` — 与 Kiro 同导出集；见 [adaptor-contract.md](../../harness/core/docs/reference/adaptor-contract.md)。

## Install

```bash
bash .cursor/harness/core/bin/install-adaptor-rules-export.sh --adaptor trae /path/to/project
install-super-cursor /path/to/project --adaptor trae
```

验收：`bash .cursor/bin/verify-install-rules-export.sh`。

## Next sprint

Trae 官方规则目录公开后：SPIKE 差距表驱动 `layout.md` / 导出范围（另开 Sprint）。
