# Verify layers（scaffold bundle）

与 Super Cursor `rules/feedback/verify.mdc` · **test** skill `reference/verify-growth.md` 对齐。

## 分层

| 层 | 命令 | 用途 |
|----|------|------|
| **L1** | `./scripts/verify.sh` | 开发循环 · 每个 TASK（**仅** `scripts/test.sh`；lint/build 登记 manifest） |
| **L2-core** | `./scripts/verify-core.sh` | merge 前 P0 |
| **L2** | `./scripts/verify-release.sh` | Sprint 收尾 / 打版 |
| **L3** | `./scripts/verify.sh --full` | CI / nightly |

## 增长纪律（防重复劳动）

1. **SSOT**：`scripts/verify/manifest.tsv` — 每个 tier 一行一入口（`bash` · `command` · `bundle-commands`）；可选第 4 列 **`stacks`**（`*` = 通用）。
2. **累积 tier**：`l2-standard` 自动包含 `l2-core` 行；`l3` 含全部 tier。勿在 L2 里再抄一遍 L1 命令。
3. **新能力**：优先 `command` 或 `bundle-commands` 登记已有测试命令；域断言才新建 `slices/verify_<feature>.sh` 并 **只加一行 manifest**。
4. **禁止双登记**：同一测例文件/命令不得在多个 slice 或 bundle 重复出现 — 复制 `audit-dedup.config.example.json` → `audit-dedup.config.json`，CI 设 `failOnDuplicate: true`。
5. **空即失败**：manifest 某 tier 无行、或 `bundle-commands` 空文件 → `run-manifest-tier.sh` / `verify_manifest_integrity.sh` FAIL（不静默跳过）。

## 扩展新 slice

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/load.sh"
sc_cd_root
# … domain checks only; do not re-run whole test suite if already in manifest command/bundle …
sc_pass "verify_<feature>"
```

在 `manifest.tsv` 增加一行，例如：

```text
l2-standard	bash	slices/verify_<feature>.sh	*
l2-standard	command	npm run lint	nodejs,react,vue
```

## 按需启用（project-profile）

整包 `.cursor` · 运行时过滤（见 `.cursor/docs/tech-stacks.md`）：

| 条件 | `run-manifest-tier.sh` 行为 |
|------|-----------------------------|
| 无 `.growing/project-profile.json` | 与旧版一致，不过滤 |
| 有 profile | `verify.enabled_tiers` 限制可跑的 **tier**；`stacks` 列与 `stacks.primary[]` 无交集则 **SKIP** 该行 |
| `VERIFY_IGNORE_PROFILE=1` | 强制不过滤（排障 / CI） |

`adapt --write` 后栈专属行需**取消注释**并写上正确 `stacks` 列；通用 slice 用 `*`。

登记检查：

```bash
bash scripts/verify/slices/verify_layers_registry.sh
VERIFY_REGISTRY_STRICT=1 bash scripts/verify/slices/verify_layers_registry.sh
```

## 全栈 mixed 叶

单仓 **frontend + backend** 共用 verify 且存在混合断言脚本时，见 **test** skill `reference/fullstack-verify-split.md`（物理拆分 · `resolve_leaf` · shim）。

## 增量验收（verify:changed）

1. 默认 `changed-map.json` 的 `prefixRules` 为空 — 复制 `changed-map.example.json` 中的示例规则，或按仓库目录自建 `prefixRules`。
2. `VERIFY_CHANGED_DRY=1 ./scripts/verify.sh --changed`
3. `VERIFY_CHANGED_BASE=master`（无 `origin/main` 时）
4. **无 Node**：与 registry slice 一致，不跑 `changed-plan.mjs`；回退 `VERIFY_CHANGED_FALLBACK`（默认 `--core`）并打印说明。全功能增量规划需 Node + git。
5. **最低层**：`VERIFY_CHANGED_MIN_LAYER=l2-core` 或 `changed-map.json` 的 `minLayer`（抬升计划层，不降低）。
6. **去重**：`run-changed.mjs` 经 `buildChangedSteps` — 完全相同的命令行只跑一次。

## 并行

互不共享可变状态的条目由 `run-manifest-tier.sh` 并行（`VERIFY_SLICE_PARALLEL`，默认 4）；`command` 行含空格时依赖 `xargs -n 1` 整串传入，勿改回 `-I{}`（会拆词导致 `[verify] manifest:` 后为空）。共享 DB/seed 请设 `VERIFY_SLICE_PARALLEL=1`。
