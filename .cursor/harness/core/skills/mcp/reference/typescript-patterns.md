# TypeScript MCP · 最小模式

官方 SDK 与最新 API 以 npm `@modelcontextprotocol/sdk` 文档为准。以下为母版骨架，非完整教程。

## 结构（建议）

```
src/
  index.ts
  tools/
  types/
package.json
tsconfig.json
```

## stdio 入口（示意）

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server(
  { name: "example-server", version: "1.0.0" },
  { capabilities: { tools: {} } },
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

## 工具参数

- 用 **Zod**（或等价）定义参数；`.describe()` 写入 schema 供 Agent 阅读
- `registerTool` / 等价 API：名称、description、inputSchema、handler

## 检查清单

- [ ] `npm run build` 通过
- [ ] Inspector 能列出工具并完成一次只读调用
- [ ] 错误路径返回可行动 message
