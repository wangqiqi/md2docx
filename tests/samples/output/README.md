# Markdown to DOCX 转换示例文档

本目录为**手工/批量转换**生成的 DOCX 参考输出（非 CI golden file）。源文件位于 `tests/samples/`。

## 自动化回归（CI）

以下路径已由 pytest 覆盖，无需依赖本目录二进制对比：

| 样例 | 测试 |
|------|------|
| `basic/*.md` | `test_convert_all_samples`（含标题/表格结构断言） |
| `advanced/*.md` | `test_convert_advanced_samples`（mermaid mock） |
| `test.md` | `test_convert_root_test_md` |

全量：`pytest tests/ src/mddocx/webui/tests/` → **176 passed, 2 skipped**

## 文件列表（历史参考）

### 基础语法
- `basic_*.docx` — 对应 `../basic/*.md`

### 高级功能
- `advanced_tables.docx` · `advanced_math.docx` · `advanced_flowcharts.docx`

> Mermaid graph/flowchart/sequence/gantt 在 v0.5.34+ 渲染为 PNG 嵌入；其他类型仍回退源码。

## 重新生成

```bash
python scripts/batch_convert.py --input-dir tests/samples --output-dir tests/samples/output
```

---

*基线同步：2026-06-08 · T-TEST-01*
