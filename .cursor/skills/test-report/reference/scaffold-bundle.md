# test-report · scaffold bundle

**用这个**：新项目用 **scaffold** 附加 `test-report` bundle 生成 Report Contract 与采集/验收脚本骨架。**不是那个**：存量项目手写 — 复制 `templates/test-report-contract.example.yaml` 或 **`/report`** 从既有 verify 日志汇总。

## 命令

```bash
./.cursor/bin/scaffold.sh apply-bundle test-report --dry-run
./.cursor/bin/scaffold.sh apply-bundle test-report --stack go-api
```

| 层 | 内容 | 何时复制 |
|----|------|----------|
| **shared** | `config/test-report.yaml` · `docs/test-report.md` · collect/verify 脚本 | 所有栈 |

## apply 后

1. 编辑 `config/test-report.yaml`（`run.suites[]` · `verify.anchors`）
2. 按栈调整套件命令（默认含 `scripts/verify.sh` · `scripts/test.sh`）
3. Sprint 收尾或发版：`bash scripts/docs/collect_test_report.sh` → **`/report`** full 或 from-logs
4. L1：`bash scripts/verify/docs/verify_test_report.sh`
5. 详 SOP → 本 skill 其余 `reference/` · `design/test-report/README.md`（bundle 内）

Manifest：`templates/scaffold/manifest.json` → `bundles[]` · `test-report`。
