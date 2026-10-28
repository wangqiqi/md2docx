# Growth meta 与 CI 双轨（SPIKE 证据 · verify SKIP）

**用这个**：git 内文档 + 门禁脚本 vs 本地 `.growing/archive/meta/` 长文证据。**不是那个**：把 SPIKE 全文提交进仓库；也不是取消本地严格校验。

## 双轨分工

| 轨 | 位置 | 入 git | 谁读 |
|----|------|--------|------|
| **A · 协议轨** | `.cursor/`（rules · skills/reference · docs · `bin/verify-*.sh`） | ✅ | 全员 · CI · fresh clone |
| **B · 证据轨** | `.growing/archive/meta/` | ❌（`.growing/` gitignore） | 母版维护者本机 · 可选团队共享 |

- **A** 写结论摘要、索引、触发表（如 `harness-ide-matrix.md` 指向 meta 全表）。
- **B** 存 SPIKE 长表、差距矩阵、决策 ADR 文件名约定：`*_SPIKE_<topic>.md`、`*_SPIKE_<topic>_scope.md` 等（各 `verify-spike-*` 脚本内写死期望 glob）。

Sprint 日常闭合摘要仍走 **`archive/{domain}/`**（`sprint/` · `spike/` · …）→ 见 [growth-layout.md](growth-layout.md)。**`meta/`** 专指母版 SPIKE 门禁期望的**固定目录**，与域表 `spike/` 并列存在（meta = 机器门禁路径，spike = 人类归档桶）。

## 门禁语义（勿改 · CI 依赖）

实现：`.cursor/lib/growth-archive.sh` → `sc_growth_archive_available <dir> [label]`

| 条件 | 行为 |
|------|------|
| `$ROOT/.growing/archive/meta/` **不存在** | 打印 `SKIP … 未引导` · 调用方 **`exit 0` 放行**（fresh clone / GitHub Actions 无本地证据） |
| 目录**存在** · 期望归档**缺失** | **FAIL**（本地回归：误删或未 SPIKE 归档） |
| 目录存在 · 归档齐全 | 继续脚本内断言（门面 · scope · 链接） |

```bash
source "$ROOT/.cursor/lib/growth-archive.sh"
sc_growth_archive_available "$ROOT/.growing/archive/meta" "verify-example" || exit 0
# 目录存在时：检查具体 * _SPIKE_*.md …
```

**目标项目** / **hybrid** 另有一套母版块 SKIP（无 `install-super-cursor.sh` 等）→ `rules/feedback/verify.mdc` §跨平台与 CI；与 meta 双轨正交。

## 本地引导（可选 · 非 CI 必须）

1. `bash .cursor/bin/bootstrap-growth.sh`（或 install 已创建 `.growing/`）
2. `mkdir -p .growing/archive/meta`
3. 跑 SPIKE 后把长文写入 meta，文件名满足对应 `verify-spike-*` / `verify-cursor-platform-contract` 期望

无 meta 时母版 **`template-verify` 仍应绿**；有 meta 后本地变为**严格**模式。

## 使用 `growth-archive.sh` 的 verify 脚本

完整表 → `docs/migration-catalog.md` §Growth meta 归档门禁。

母版聚合：`verify-super-cursor.sh`（mother-only 段）· CI：`template-verify.sh`。

## 相关 SSOT

| 文档 | 内容 |
|------|------|
| [growth-layout.md](growth-layout.md) | `archive/{domain}/` · `meta/` 域一行 |
| [verify.mdc](../../../rules/feedback/verify.mdc) | 母版门禁清单 · SKIP 摘要 |
| [building-super-cursor.md](../../../docs/building-super-cursor.md) | 改文档/verify 触发表 |
