# MCP Best Practices（母版精简）

通用准则；实现细节见同目录语言骨架。官方协议以 [MCP 文档](https://modelcontextprotocol.io) 为准。

## 命名

- 描述性、一致前缀、`snake_case` 或 `kebab-case`
- 工具名反映动作：`list_*` · `get_*` · `create_*`

## 响应

- 结构化数据 → JSON；说明性长文 → Markdown
- 只返回 Agent 决策所需字段；避免整页 HTML/巨型 blob

## 分页

- 结果可能 >50 或不可控时必须支持 `limit` + `cursor`/`offset`
- 默认 limit 保守（如 10–50）；设上限防一次拉爆上下文

## 传输

| 场景 | 倾向 |
|------|------|
| 本机 IDE / 本地工具 | stdio |
| 远程、多客户端、可水平扩展 | Streamable HTTP |

## 安全与错误

- 校验全部入参；禁止把用户字符串拼进 shell/SQL
- 统一错误形：`code` · `message` · 可选 `details`（合法取值/下一步）
- 密钥仅 env；响应与日志脱敏

## 工具边界

- 一工具一事；拆读/写
- 写操作在 description 标明副作用与确认期望
