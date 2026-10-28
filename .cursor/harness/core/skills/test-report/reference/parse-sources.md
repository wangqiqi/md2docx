# 解析来源 · parse hints

从 **log 文件** 或 **当次终端输出** 提取表格字段。解析失败 → 报告中标 `parse: manual` 并保留 log 路径。

## 通用

| 字段 | 来源 |
|------|------|
| `exit_code` | 套件命令 `$?` |
| `wall_sec` | `date +%s` 差分或 `time` 包装 |
| `status` | exit 0 → ✅ PASS；非 0 且非 optional → ❌ FAIL；optional → ⚠️ SKIP |
| `command` | Contract 原样（报告 §8 一致） |

## verify_exit

匹配行示例（不限于）：

- `OK:` / `FAIL:` / `passed` / `error`
- 聚合脚本 `verify.sh` 的 `==>` 段标题
- 最终 `exit 0` 且无 `FAIL` 字样 → PASS

墙钟：整段 log 采集时段。

## pytest

正则/行扫：

- `(\d+) passed`
- `(\d+) failed`
- `(\d+) skipped`

摘要列：`{passed} passed, {skipped} skipped`

## playwright

- `(\d+) passed`
- `(\d+) failed`
- 可选：最后一行 `tests?` 统计

## npm_script / vitest / jest

常见尾行：

- `Tests:.*passed`
- `Test Files.*passed`
- `exit code` 非 0 → FAIL

## custom_grep

Contract suite 附加：

```yaml
parse: custom_grep
patterns:
  - 'bench.*p95=([0-9.]+) ms'
  - 'violations: ([0-9]+)'
```

匹配结果写入报告子表；无匹配 → 标「未解析」。

## from-logs 纪律

- log 文件名 = `{suite.id}.log`
- 报告头注明：`基于 log · {log_dir} · 采集 {iso8601}`
- log 早于当前 commit 超过 1 天 → AskQuestion 是否重跑

## 禁止

- 从 CHANGELOG 抄数字冒充当次结果
- 合并多次 run 取最优数字而不说明
