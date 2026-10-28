# 列表分页 API 信封（通用）

> 高流量 `GET` 列表推荐统一 JSON 信封，便于 FE 共享 pager hook 与 OpenAPI 示例。项目特例（如嵌套 `versions` 字段）在 Growth `learn/acceptance.md` 声明兼容层。

## 推荐响应

```json
{
  "items": [],
  "total": 0,
  "offset": 0,
  "limit": 20,
  "next_cursor": null
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `items` | array | 当前页行（主列表字段名；历史 API 可用别名 + 文档说明） |
| `total` | int | 过滤后总数（keyset 模式仍建议提供，便于「共 N 条」） |
| `offset` | int | offset 模式下的有效偏移 |
| `limit` | int | 本页上限 |
| `next_cursor` | string \| null | keyset 续页；无下一页为 `null` |

## 请求参数

| 参数 | 默认 | 说明 |
|------|------|------|
| `limit` | 20 | HTTP 默认；服务层 `limit=null` 若表示内部全量，**必须**文档化且禁止对匿名列表开放 |
| `offset` | 0 | 与 `cursor` 互斥时 **cursor 优先** |
| `cursor` | — | opaque keyset token |

## 排序与 keyset

- 固定排序键（例：`created_at DESC, id DESC`）并在 OpenAPI 写明。
- `next_cursor` 编码最后一行的排序键；禁止客户端拼装 cursor 内部字段。

## Breaking 迁移

| 旧行为 | 迁移 |
|--------|------|
| 裸数组响应 | 加信封；旧客户端设 `Accept-Version` 或短期 shim 字段 |
| offset 与 cursor 混用 | 文档二选一；实现拒绝同时传 |

## 交叉引用

- FE 页码重置 · limit 对齐 → **data-list.mdc**
- 批量 ID 查询 → **data-batch**
- OpenAPI 同步 → **api** skill · **docs.mdc**
