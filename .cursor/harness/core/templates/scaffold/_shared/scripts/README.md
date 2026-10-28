# scripts/ — 分层与公因子（项目 SSOT）

本目录是**项目脚本的落点矩阵**；`plan-check` / `/run` 验收列与 `rules/feedback/verify.mdc` 的 L0–L3 分层都读这里。

## 仓库根 `onekey_start.sh`（与 `scripts/` 并列）

`scaffold apply` 会从 `_shared/onekey_start.sh` 铺到**项目根**（与 Super Cursor `templates/project-onekey/` 同源）。薄菜单入口：`test` → `scripts/test.sh` · `verify` → `scripts/verify.sh`。已 install 且 `growth.onekey_bootstrap` 为真时，`growth-init` / `install-super-cursor.sh` 亦会在根无该文件时复制同一模板（不覆盖已有）。

## 分层

| 位置 | 放什么 | 禁止 |
|------|--------|------|
| `test.sh` | **开发循环**入口（最快反馈）；收尾可 `sc_project_tmp_cleanup test` | 塞全量验收逻辑 |
| `verify.sh` | **聚合入口**（L2；可转发 `verify/tier/`） | 每个域复制一套编排 |
| `verify/tier/` | L0 / L2-core / L3 orchestrator 实现 | 根目录复制 tier 逻辑 |
| `verify/domain/` | L1 域脚本 `verify_<feature>.sh` | 根目录新建域脚本 |
| `lib/_*.sh` | **公因子**（只 `source`，不直接 `exec`） | 多脚本 copy-paste 同一段断言 |
| `ops/` | 部署 / 运维 / 数据工具 | 与 verify 域混放 |
| `dev/` | stub · fixture · 一次性脚本 | 长期堆积 |

规律：**根目录只留入口**；新实现默认落子目录；聚合脚本注册新域只 **+1 行**。

## 矩阵（填本项目的）

| 脚本 | 层 | 用途 | 何时跑 |
|------|----|------|--------|
| `test.sh` | L1 | 开发中快速回归 | 每次改动 |
| `verify.sh` | L2 | 任务收尾 / P0 闭合 | TASK 验收列 |
| `verify/domain/verify_*.sh` | L1 | 单域验收 | 该域改动时 |
| `verify/tier/*` | L0/L3 | 全量 / nightly | Sprint 收尾 · 打版前 |

## 公因子

`lib/_common.sh` 提供 `sc_root` · `sc_step` · `sc_ok` · `sc_fail` · `sc_require_cmd` · `sc_summary`。
新增共享断言/环境探测 → 加到这里，**不要**复制进每个域脚本。

> 完整规则与 Growth 侧（`archive/{domain}/`）同源 → `.cursor/skills/plan/reference/growth-layout.md`
