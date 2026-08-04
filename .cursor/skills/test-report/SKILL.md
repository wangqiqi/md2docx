---
name: test-report
description: 可发布测试报告（/report）— 全量/分层 verify 后汇总 · Report Contract · 日志解析 · benchmark 文档。项目无关 · 操作者无关。说「测试报告」「全量测试报告」「verify 报告」「benchmark 报告」时用。
---

# test-report · 测试报告

**用这个**：在 **verify / test 已跑或即将跑** 后，生成或更新**可单独发布**的测试报告（摘要表 · 矩阵 · 复现命令 · 结论）。**不是那个**：写/跑测试 → **test**；门禁脚本本身 → 项目 `scripts/verify.sh`；上线 7 维走查 → **`/delivery`**；Sprint 编排 → **plan** `DOC-*`。

母版正文**零**业务词、零具体套件名、零仓库路径。项目命令、文档路径、锚点 → **Report Contract**（`config/test-report.yaml` 优先；无则 `learn/test-report.md`）。

**详文**：`reference/pipeline.md` · `reference/contract-schema.md` · `reference/report-template.md` · `reference/parse-sources.md` · `reference/tiers.md` · `reference/regen-gates.md` · `reference/scaffold-bundle.md`

## 何时进入

- 用户说 **`/report`** · 「测试报告」「全量测试」「verify 后出报告」「benchmark 报告」
- Sprint **Done when** 含持久化测试报告 / QA benchmark
- **`/release`** 发版前：可选全量 regen 报告（见 `reference/regen-gates.md`）
- **单独运行**：不依赖 ACTIVE TASK；可读 Contract 后直接执行（仍须遵守 verify 门禁）

## 流程（五段 · 概览）

1. **读 Contract** — `config/test-report.yaml` 或 `learn/test-report.md`；无则 AskQuestion + `templates/test-report-contract.example.yaml` 起草
2. **执行或复用日志** — 按 Contract `run.suites[]` 跑命令，或 `--from-logs` 解析 `run.log_dir` 已有 `*.log`
3. **解析** — 按 `reference/parse-sources.md` 提取 PASS/FAIL · 计数 · 墙钟 · skip 说明
4. **渲染** — 填 `report-template.md` 结构 → 写入 `report.doc_path`；更新版本头 / sprint / commit
5. **验收** — L1 锚点脚本 + 可选 Growth `archive/reviews/` 摘要（非 SSOT）

## 运行模式

| 模式 | 何时 | 动作 |
|------|------|------|
| **full** | 发版档 / 用户要最新数字 | 顺序跑 Contract 套件 → 写 log → 渲染报告 |
| **from-logs** | 刚跑完 verify、避免重复墙钟 | 只解析 `log_dir` → 渲染 |
| **refresh** | 仅改元数据（版本/commit） | 不跑套件；更新报告头与关联链接 |

默认：**full**（发版档）或用户指定；`from-logs` 须在报告中标注 log 时间戳。

## 与下游分工

| 阶段 | test-report | 不做 |
|------|-------------|------|
| **test** | 消费测试结果 | 替代写用例 / 红绿断言 |
| **verify** | 编排 Contract 中的 verify 命令 | 改 verify 分层定义（真源 `verify.mdc`） |
| **delivery** | 可摘录 delivery 走查结论进 §5 | 替代 7 维走查 |
| **plan** `DOC-*` | 协作定报告章节与锚点 | 替代 Contract schema |
| **release** | 发版档可选 full regen | 无 verify 绿仍声称「全绿」 |

## 禁止

- skill 正文写死项目套件名、域名、GPU/中间件产品名、具体 doc 章节号
- 无套件 exit 0 / 无 log 仍写「全部 PASS」
- 用报告生成替代 **task-verify** 或 **delivery** Blocker 清零
- 无 Contract 时编造矩阵行而不标 `inferred`
