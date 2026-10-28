# Super Cursor harness（位于 `.cursor/harness/`）

**分区 SSOT 在 `.cursor/` 包内**，不在仓库根目录。拷贝整个 **`.cursor/`**（或改名为 `.kiro` / `.trae` 等）即可迁移；勿再跑「平铺复制」。

| 路径 | 角色 |
|------|------|
| `.cursor/harness/core/` | Harness Core（skills · rules · bin[core] · config · …） |
| `.cursor/adaptors/cursor/` | Cursor 能力（hooks · cursor-only verify · 部分 docs） |
| `.cursor/adaptors/{dsh,kiro,trae,opencode}/` | 占位 · 后续 adaptor Sprint |
| `.cursor/rules` · `skills/` · `hooks/` … | **相对 symlink** → core / adaptor（Cursor/Roo 协议路径，**非第二份文件树**） |

```bash
bash .cursor/harness/link-cursor-ide.sh       # 缺链时补齐（install / CI 也会调）
bash .cursor/harness/clean-assembled.sh     # 删掉误生成的实体目录副本（保留 harness+adaptors）
bash .cursor/template-verify.sh             # 母版 CI（先 link 再验）
bash .cursor/bin/verify-harness-layout.sh
```

**改文件只动 `harness/core` / `adaptors`**。根下 symlink 让 IDE 仍读 `.cursor/rules` 等默认路径。

映射草案 → `config/install-map.example.json`。占位 adaptor 最小契约 → `harness/core/docs/reference/adaptor-contract.md`（`bash .cursor/bin/verify-adaptor-contract.sh`）。
