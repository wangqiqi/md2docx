# Tests

| 层级 | 路径 | 用途 |
|------|------|------|
| 单元 | `internal/handler/*_test.go` | handler 逻辑 |
| 组件 | `internal/server/*_test.go` | 路由表 / mux |
| 集成 | `tests/integration/` | 端到端 HTTP 行为 |

```bash
./scripts/test.sh          # 仅测试（开发中快速闭环）
go test -v ./tests/...     # 集成测试详情
./scripts/verify.sh        # 测试 + 构建（plan/run 验收）
```
