# test-report · 五段流水线

与具体技术栈无关；变的仅是 Contract 中的 **套件命令** 与 **解析器 hint**。

## 1. 范围（Scope）

- 明确**读者**（研发 / QA / 运维 / 产品）与**定位**（发版 benchmark · 回归 · 专项）
- Contract `report.audiences` · 报告头「读者」「定位」
- 模板 → `report-template.md` §0

## 2. 套件表（Suites）

Contract `run.suites[]` 为 SSOT：

| 字段 | 含义 |
|------|------|
| `id` | 稳定标识（写入报告表格行） |
| `tier` | `l0` `l1` `l2` `l3` `e2e` `perf` `delivery` `custom` |
| `command` | 可复现 shell 一行 |
| `cwd` | 可选工作目录（相对仓库根） |
| `parse` | 解析 hint（见 `parse-sources.md`） |
| `optional` | `true` 时 FAIL 记为 skip 而非 Blocker |

顺序：先 **verify 分层**（L1 → L3），再 **E2E / perf / 专项**（项目自定）。

## 3. 采集（Collect）

| 步 | 动作 |
|----|------|
| 1 | `mkdir -p` Contract `run.log_dir`（建议 gitignore） |
| 2 | 每套件：`{id}.log` 捕获 stdout+stderr；记录 `exit_code` · `wall_sec` |
| 3 | 可选：`run.collect_script` 封装顺序与 env（项目脚本，非母版硬编码） |
| 4 | 失败不静默：exit ≠ 0 须在摘要表标 ❌ 并写 Blocker 节 |

## 4. 渲染（Render）

1. 解析各 log → 结构化行（见 `parse-sources.md`）
2. 按 `report-template.md` 填 §1 摘要 · §2 矩阵 · §3–§6 项目节 · §8 复现 · §10 结论
3. 写入 `report.doc_path`；`docs/README` 索引行由项目 verify 锚点保证
4. 版本头：`report.version` + 日期 + sprint + `baseline_commit`（`git rev-parse --short HEAD`）

## 5. 验收（Verify）

| 层 | 内容 |
|----|------|
| **L1 机械** | 文件存在 · 必备 grep 锚点 · 复现命令块 · README 索引 |
| **L2 语义** | 数字与 log 一致 · Blocker 与 delivery 对齐 · 读者能复现 |

L1 绿 **不** 等于测试已重跑。`from-logs` 须在报告注明 log 时间。

## 与 verify 顺序

```text
开发中：task-verify / scripts/test.sh
  → Sprint 收尾：scripts/verify.sh（L1 或 --full）
  → [可选] delivery 走查
  → test-report full 或 from-logs
  → L1 报告锚点 verify
  → release
```

档位详见 `regen-gates.md` · 分层定义真源 `rules/feedback/verify.mdc`。
