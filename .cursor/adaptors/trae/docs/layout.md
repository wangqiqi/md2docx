# Trae `.trae/` 布局（`core_rules_export`）

官方 Trae 规则目录 **待确认**；当前与 Kiro 共用 Super Cursor 导出树。SSOT → [core-rules-export.md](../../../harness/core/docs/reference/core-rules-export.md)。

```text
.trae/
├── README.md
├── RULES.md
└── rules/
```

## 与 Kiro

导出文件集与 [kiro layout](../../kiro/docs/layout.md) **相同**；仅 `install_dir` 为 `.trae/`。SSOT 语义 → [core-rules-export.md](../../../harness/core/docs/reference/core-rules-export.md)。

## Growth

**`.growing/`** 共享；`rules/local` → `.growing/rules/local`。

## 安装

```bash
bash .cursor/harness/core/bin/install-adaptor-rules-export.sh --adaptor trae /path/to/project
install-super-cursor /path/to/project --adaptor trae
```

## 验收

`bash .cursor/bin/verify-install-rules-export.sh`。
