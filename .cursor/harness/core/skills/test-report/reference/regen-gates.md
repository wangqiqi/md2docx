# regen 门禁

何时 **重跑套件** vs **仅 from-logs 渲染** vs **跳过**。

## 档位

| 档位 | 触发 | 要求 |
|------|------|------|
| **dev** | 单 TASK 收尾 | 不要求报告；可选 refresh 元数据 |
| **sprint** | Sprint QA / `DOC-*` | L1 verify 绿 + 至少 `l1` 套件 log |
| **release** | `/release` 发版档 | `verify` / plan VERIFY 全绿 + **full** 或 24h 内 from-logs |
| **benchmark** | 持久化 docs benchmark | 全 Contract 套件跑一遍 + L1 锚点 |

## 硬门禁

- [ ] `scripts/verify.sh`（或 plan VERIFY）exit 0 **之后** 才写「全部 PASS」
- [ ] 任一非 optional 套件 FAIL → Blocker 节非空 · 不得 release
- [ ] 报告 §8 命令与 Contract 一致（复制粘贴，不改参数）

## 软门禁

- perf 波动 > 合同阈值 → §10 建议专项，非 Blocker
- delivery 未跑 → §5 标「未执行」或删节

## 与 run / release

| 时机 | 动作 |
|------|------|
| **run** | TASK 验收用 `task-verify`；报告非每 TASK 必做 |
| **release** | 可选 `full` regen；CHANGELOG 可链 Sprint ID |
| **plan** `DOC-*` | Done when 含 `doc_path` + `l1_script` 锚点 |

## from-logs 例外

允许在 **刚跑完 verify** 的同会话用 `from-logs` 省墙钟；报告必须标注 log 时间戳与 commit。
