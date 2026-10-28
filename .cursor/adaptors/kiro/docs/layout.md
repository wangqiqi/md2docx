# Kiro `.kiro/` 布局（`core_rules_export`）

官方 Kiro 规则目录 **待确认**；当前与 Trae 共用 Super Cursor 导出树。SSOT → [core-rules-export.md](../../../harness/core/docs/reference/core-rules-export.md)。

```text
.kiro/
├── README.md       # adaptors/kiro/README.md
├── RULES.md        # 生成：rules/**/*.mdc 索引
└── rules/          # 来自 harness/core/rules（无 local）
```

## 与 Trae

导出文件集与 [trae layout](../../trae/docs/layout.md) **相同**；仅 `install_dir` 为 `.kiro/`。

## Growth

**`.growing/`** 共享；`rules/local` 在 `.growing/rules/local`（不写入 `.kiro/rules/local`）。

## 安装

```bash
bash .cursor/harness/core/bin/install-adaptor-rules-export.sh --adaptor kiro /path/to/project
install-super-cursor /path/to/project --adaptor kiro
```

## 验收

`bash .cursor/bin/verify-install-rules-export.sh`（kiro · trae 共用）。
