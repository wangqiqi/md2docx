# Python MCP · 最小模式（FastMCP）

官方包与最新 API 以 `mcp` / FastMCP 文档为准。以下为母版骨架。

## 结构（建议）

```
src/
  server.py
  tools/
tests/
pyproject.toml
```

## FastMCP 示意

```python
from mcp.server.fastmcp import FastMCP

app = FastMCP("example-server")

@app.tool()
def get_status() -> dict:
    """Return service health. Read-only."""
    return {"ok": True}
```

## 低级 stdio（示意）

```python
from mcp.server import Server
from mcp.server.stdio import stdio_server

server = Server("example-server")
# 注册 list_tools / call_tool 后：
# async with stdio_server() as (read, write):
#     await server.run(read, write, ...)
```

## 检查清单

- [ ] `python -m py_compile` / 类型检查通过
- [ ] Inspector 或 Cursor 只读冒烟
- [ ] Pydantic/注解参数有描述；写工具标明副作用
