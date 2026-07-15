---
name: mcp
description: >-
  MCP 服务器设计与实现要点：工具边界、命名、分页、错误、传输选型；
  建服四阶段流程。参考 reference/ 精简指南。
---

# mcp

设计与实现 **Model Context Protocol** 服务器时用本 skill。密钥与鉴权清单仍走 **security**。

## 设计要点

- **一工具一职责**；schema 写清参数、默认值与错误
- **命名可发现**：一致前缀 + 动词（如 `github_list_repos`）；避免缩写堆砌
- **API 覆盖 vs workflow**：默认优先完整 API 面，便于 Agent 组合；高频多步可另加 workflow 工具
- **上下文**：描述简洁；大结果集须 **分页/过滤**（limit/cursor）；返回聚焦字段
- **可行动错误**：指出缺参、合法取值、下一步，勿只抛裸异常字符串
- **只读默认安全**；写/删须明确确认边界
- **无密钥进 repo**；env 或 Cursor MCP 配置注入；日志不泄露 token/PII

## 建服四阶段

### 1 · 调研与规划

1. 读目标服务 API（鉴权、分页、幂等、限流）
2. 列出工具清单：读优先，写操作单独标风险
3. 选型：本地 → **stdio**；远程/可扩展 → **Streamable HTTP**（或项目既有传输）
4. 语言：TS（官方 SDK + Zod）或 Python（FastMCP）— 跟团队栈

详阅：`reference/best-practices.md`

### 2 · 实现

- 参数用 schema 校验（Zod / Pydantic）
- 工具描述写「何时用 / 勿用于」
- 分页参数默认保守（如 limit≤50）
- 外部 HTTP：timeout · 有限重试 · 不吞错误体
- **Tool annotations**（SDK 支持时标注，助 Agent 选型）：
  - `readOnlyHint` — 只读查询
  - `destructiveHint` — 删改/不可逆
  - `idempotentHint` — 重复调用安全
  - `openWorldHint` — 开放域/外部实体
- 现代 TS SDK：尽量定义 `outputSchema` / `structuredContent`，便于客户端解析

精简模式见：`reference/typescript-patterns.md` · `reference/python-patterns.md`  
（完整 SDK 以官方文档为准，勿在母版内嵌整份 upstream README。）

吸收自 anthropics/skills/mcp-builder。

### 3 · 审查与测试

- [ ] 无重复巨型「万能」工具
- [ ] 错误信息可行动
- [ ] `npx @modelcontextprotocol/inspector` 或 Cursor：`GetMcpTools` → 只读 `CallMcpTool` 冒烟
- [ ] 写路径有确认/幂等说明

### 4 · Eval（LLM 可用性）

吸收自 anthropics/skills/mcp-builder · 详 `reference/evaluation.md`。

MCP 好坏看 **LLM 能否仅靠工具答真实难题**，不是工具数量。

1. Inspector / `GetMcpTools` 清点工具
2. 只读探查目标数据形态
3. 写 **10 道**独立、只读、复杂、**单一可验证答案** 的题（答案须稳定）
4. 自解或换会话验证；失败则改 schema/description/分页，而非堆万能工具

可选 XML 格式见 `reference/evaluation.md`。upstream `evaluation.py` 可批跑，非母版必选。

### 5 · 接入 Cursor

- 在项目 MCP 配置注册 server（用户/团队批准后；勿擅自装 shadow MCP）
- **调用顺序（Agent）**：先 **`GetMcpTools`**（按 `server` / `toolName` / `pattern`）取 schema → 再 **`CallMcpTool`**；未读 schema 勿盲调
- 鉴权失败 / `needsAuth` → 对该 server 调 `mcp_auth` 一次后再试；勿对未授权 server 反复 auth
- 工具名与 description 在 Agent 侧可发现
- 失败时检查：stdio 路径、env、schema 与实参类型

## 验证

```bash
# 示例：Inspector（按项目 package 调整）
npx @modelcontextprotocol/inspector
```

或在 Cursor 中：`GetMcpTools` → 对目标 tool 做一次只读 `CallMcpTool`。

## 与 rules / 其他 skill

| 关切 | 去向 |
|------|------|
| 密钥 · auth · 注入 | **security** · `security-sdlc.mdc` |
| 大批量 ID / IN 查询 | `rules/execution/data-batch.mdc` |
| 组织 MCP 治理（Runlayer 等） | 用户/插件规则；本 skill 不替代治理策略 |

## 参考目录

| 文件 | 用途 |
|------|------|
| `reference/best-practices.md` | 命名 · 分页 · 传输 · 错误 |
| `reference/typescript-patterns.md` | TS 最小骨架 |
| `reference/python-patterns.md` | FastMCP 最小骨架 |
| `reference/evaluation.md` | 10 题 eval 门禁 · XML 格式 |
