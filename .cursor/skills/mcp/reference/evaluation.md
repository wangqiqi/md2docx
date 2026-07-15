# MCP Server Eval（母版精简）

吸收自 anthropics mcp-builder 协议 · 母版出处 **`docs/library-index.md`** · 本文件为操作 SSOT。

## 目的

MCP 质量看 **LLM 能否仅靠工具回答真实难题**，不是工具数量或 API 覆盖率本身。

## 何时做

建服 **Phase 3 审查通过后**、接入 Cursor **之前**（或 P0 server 首次上线前）。

## 10 题门禁

每题须满足：

| 属性 | 要求 |
|------|------|
| 独立 | 不依赖其他题的写入结果 |
| 只读 | 非破坏性、幂等操作 |
| 复杂 | 多步 / 多工具调用（可数十次） |
| 真实 | 像人类会关心的检索任务 |
| 可验证 | **单一**答案，字符串可比 |
| 稳定 | 答案不随时间漂移（忌「当前点赞数」类） |

## 出题流程

1. **工具清点** — `GetMcpTools` / Inspector 列能力
2. **只读探查** — 用 READ 类工具了解数据形态
3. **写 10 题** — 按上表约束
4. **自解验证** — 人工或 Agent 独立解题，确认答案

## 输出格式（可选 XML）

```xml
<evaluation>
  <qa_pair>
    <question>…</question>
    <answer>单一可验证答案</answer>
  </qa_pair>
</evaluation>
```

## 通过标准

- 主流模型 + 仅 MCP 工具：多数题可解且答案一致
- 失败题 → 改 tool description / schema / 分页，而非加「万能」工具

## 可选脚本

upstream `mcp-builder/scripts/evaluation.py`（~12KB）可本地跑批；母版不强制安装。需用时：`pip install -r mcp/scripts/requirements-eval.txt`（若项目已拷脚本）。
