# Report Contract · schema

项目真源（优先级）：

1. `config/test-report.yaml`（可提交 · 适合 CI）
2. `.cursorGrowth/learn/test-report.md`（gitignore · Agent 会话友好）
3. 均无 → AskQuestion 起草 · 模板 `templates/test-report-contract.example.yaml`

## 顶层

```yaml
report:
  id: string          # 稳定 id
  doc_path: string    # 持久化报告 md
  version: semver str # 报告文档版本（非产品版本）
  title: string       # 可选；项目本地化标题写在 doc 内亦可
  audiences: [string]

run:
  log_dir: string     # 原始 log · 建议 gitignore
  collect_script: string | null  # 可选一键采集
  suites: Suite[]

metadata:
  sprint_key: string | null      # 如 SPRINT-QA-01
  environment_hint: string | null  # 自由文本 · 无密钥

verify:
  l1_script: string   # 报告锚点门禁
  anchors: string[]   # 额外 grep 关键词（文档内必须出现）

delivery:
  include: boolean    # 是否要求 delivery 结论表
  source: string | null  # 如 archive 路径或「当次 /delivery」摘要
```

## Suite

```yaml
- id: verify_l1
  tier: l1
  command: bash scripts/verify.sh --l1
  cwd: null
  parse: verify_exit      # exit + 墙钟
  optional: false
  label: "L1 gate"        # 报告展示名（可选，默认 id）
```

## parse 枚举

| 值 | 提取 |
|----|------|
| `verify_exit` | exit code · 首尾 `==>` 行 · PASS/FAIL 字样 |
| `pytest` | `N passed` · `skipped` · `failed` |
| `playwright` | `N passed` · `N failed` · 用例标题行 |
| `npm_script` | exit · 常见 test runner 摘要行 |
| `custom_grep` | Contract 可附 `patterns: []` 行级匹配 |
| `manual` | 不解析；报告标「见 log」 |

## 与 manual Contract 对齐

| manual | test-report |
|--------|-------------|
| 故事线 + 截图 | 套件矩阵 + 数字 |
| walkthrough_command | `run.suites[]` |
| regen 门禁 | verify 绿后再 full regen |

完整示例 → `.cursor/templates/test-report-contract.example.yaml`。
