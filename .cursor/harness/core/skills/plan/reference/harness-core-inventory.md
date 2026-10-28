# Harness Core 清点（SPIKE-001 摘要）

完整三分类表与 rg 复现命令见 Growth 归档：`.growing/archive/meta/SPIKE-001-harness-classification.md`（本地 gitignore）。

| 分类 | 含义 | 典型路径 |
|------|------|----------|
| **core** | 换 IDE 仍保留的 SOP · 脚本 · 配置 · 模板 | `skills/` · `rules/` · `bin/runner.sh` · `config/` · `templates/` |
| **cursor-only** | 绑定 Cursor 产品能力 | `hooks/` · `hooks.json` · `verify-cursor-*` · `docs/cursor-cloud.md` |
| **vscode-family** | 多编辑器可共用的薄层 | `AGENTS.md` · `.mdc` 作为规则载体 · Copilot 指令文件 |

**硬编码（2026-10-26）**: `.cursor/bin` + `.cursor/lib` 内 `.cursor/` 字面量约 **112** 行 / **32** 文件（含 hooks 树）。收敛目标 → **SPRINT-HARNESS-INSTALL**（`SC_HARNESS_ROOT` + `install-map.json`）。
