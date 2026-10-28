# Verify / test 增长协议（通用）

真源分层：**verify.mdc** L0–L3 · 本页为 **如何加能力而不叠床架屋**。

## 三件套

| 件 | 路径 | 作用 |
|----|------|------|
| **manifest** | `scripts/verify/manifest.tsv` | 什么在 merge / release / nightly 跑 |
| **changed-map** | `scripts/verify/changed-map.json` | Agent 按 diff 抬层 + 挂域 slice |
| **audit-dedup** | `scripts/verify/audit-dedup.config.json` | 测例只登记一次 |

脚手架：`scaffold apply-bundle verify-layers` 一次铺齐；成熟仓从 Growth `learn/` 记栈专属 glob，**勿**写进 `.cursor/`。运行时栈过滤 → `project-profile.json` + `manifest.tsv` **stacks** 列（`VERIFY_IGNORE_PROFILE=1` 可关）。

## verify:changed · 编排 v2

| 机制 | 说明 |
|------|------|
| **步骤去重** | `buildChangedSteps` — 相同 `bash` + argv 只执行一次 |
| **最低层** | `VERIFY_CHANGED_MIN_LAYER`（`l1` \| `l2-core` \| `l2-standard`）或 `changed-map.json` → `minLayer`；非法值 **FAIL** |
| **无 Node** | `changed-fallback.sh` + `VERIFY_CHANGED_FALLBACK`（不变） |

## 工具链依赖（矩阵）

| 能力 | bash | git | Node |
|------|------|-----|------|
| L1 `test.sh` · manifest tier | ✅ | — | — |
| `verify:changed` 全功能 | ✅ | ✅ | ✅ |
| `verify:changed` 无 Node | ✅ | — | — → `VERIFY_CHANGED_FALLBACK`（默认 `--core`） |
| registry / audit-dedup slice | ✅ | — | 可选（无则 SKIP） |

默认 `changed-map.json` 的 `prefixRules` 为空；示例路径见 `changed-map.example.json`。

## 项目 /tmp（跨栈）

| 件 | 路径 |
|----|------|
| 契约 | `.growing/temp-cleanup.json`（模板 `templates/growing/temp-cleanup.example.json`） |
| 执行器 | `.cursor/lib/project-tmp-cleanup.sh` · `workflow.json` → `temp_cleanup` |

`ephemeral` 规则在 `task-verify` / `scripts/verify.sh` / `test.sh`（`sc_project_tmp_cleanup`）成功后清理；`persistent` 靠 `max_age_hours` + `sweep`（Sprint `runner.sh verify` 末尾）。

## manifest 类型（栈无关）

| type | target | 何时用 |
|------|--------|--------|
| `bash` | `slices/verify_*.sh` | 域断言、组合检查、registry |
| `command` | 单行 shell（`npm run test:unit` · `go test ./pkg/...`） | 已有脚本即可 |
| `bundle-commands` | `bundles/*.txt` 每行一条命令 | 批量集成测、多包 |

## HYGIENE · 对称清扫

契约/类型/OpenAPI 变更时 **同 PR** 更新 docs · 生成物 · verify 锚点。卫生 Sprint **不改** HTTP 语义。详见 **doc-hygiene.mdc** §对称清扫。

全栈 mixed verify 叶拆分 → `reference/fullstack-verify-split.md`。

## 反模式

- 新 slice 里再跑一遍 L1 全量（L2 已含 `sc_verify_l1_fast`）。
- 在 `verify-layers.sh` 数组 **与** manifest **双份**维护（数组已废弃，仅 manifest）。
- 为消 flake 连跑多轮 L2-standard（定向单测 + 最多一轮 core）。
- 项目专有路径写进母版 `default-protected` / `verify.mdc`（走 Growth local）。

## 与 test 文件

- 单测文件归属 **一个** manifest 入口（`command` / `bundle-commands` / 域 slice 内唯一引用）。
- E2E / Playwright 放 L3 或 `l3` tier 的 `bash` slice。
- 框架选型 → `rules/execution/testing.mdc`；**不**为同一层引入第二套 runner。
