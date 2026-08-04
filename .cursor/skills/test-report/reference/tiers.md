# 分层 · 与 verify.mdc 对齐

**层定义真源**：`rules/feedback/verify.mdc` §分层验收。本 skill **不重复** L0–L3 表，只映射到报告结构。

| tier（Contract） | verify.mdc | 报告默认位置 |
|------------------|------------|--------------|
| `l0` | L0 存在性 / harness | §2.1 |
| `l1` | L1 单测 / 静态 / 快门禁 | §1 摘要 + §2.1 |
| `l2` | L2 契约 / migration | §2.1 |
| `l3` | L3 `--full` 集成 | §1 摘要 + §2.1 |
| `e2e` | 浏览器 / 端到端 | §2.2 |
| `perf` | 性能探针 / bench | §4 |
| `delivery` | 走查结论摘录 | §5 |
| `custom` | 项目专项 | §2.3 或 §3 |

## 默认套件顺序（推荐）

1. 环境预检（`custom` · optional）
2. `l1` verify
3. `l3` verify（发版档）
4. 域 `test.sh` / FE lint（`l1`）
5. E2E 矩阵（`e2e`）
6. perf（`perf` · optional）

## 与 test skill

- **test**：定义怎么写测、怎么红绿
- **test-report**：verify 跑完后**汇总成文档**；不新增断言

## 与 delivery

delivery §1–7 结论可手工或从 archive 粘贴进 §5；`delivery.include: true` 时 full regen **建议**先 `/delivery` 无 Blocker。
