# `core_rules_export`（Kiro · Trae）

`install-map` token **`core_rules_export`**：把 Harness **rules** 子集安装到项目规则型 IDE 根目录，**不**拷贝 skills · bin · config · templates 全量。

## 适用 adaptor

| id | `install_dir` | 脚本 |
|----|---------------|------|
| `kiro` | `.kiro/` | `install-adaptor-rules-export.sh --adaptor kiro` |
| `trae` | `.trae/` | `install-adaptor-rules-export.sh --adaptor trae` |

Kiro 与 Trae **导出内容相同**；仅安装根不同。官方目录规范 **待确认** — 布局见 `adaptors/kiro/docs/layout.md` · `adaptors/trae/docs/layout.md`。

## 导出范围

| 包含 | 排除 |
|------|------|
| `harness/core/rules/**` → `<install_dir>/rules/**` | `rules/local`（消费方 → `.growing/rules/local`） |
| 生成 `<install_dir>/RULES.md`（`.mdc` 路径索引） | skills · bin · hooks · adaptors |
| `adaptors/<id>/README.md` → `<install_dir>/README.md` | |

拷贝：`sc_copy_tree` + `rules/local` exclude（与 `.dsh` core 安装同策略）。

## Growth

`growth_dir` 仍为 **`.growing/`**（共享，不写入 `.kiro`/`.trae`）。安装脚本会 `mkdir -p .growing/archive`（若不存在）。

## 验收

```bash
bash .cursor/bin/verify-install-rules-export.sh
```

聚合：`verify-super-cursor.sh` · `install-smoke.sh`（可选步骤）。

## 相关

- [adaptor-contract.md](adaptor-contract.md) §`includes` token
- dsh 全量 core → [adaptors/dsh/docs/layout.md](../../../adaptors/dsh/docs/layout.md)
