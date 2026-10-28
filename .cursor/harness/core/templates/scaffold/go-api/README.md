# Go HTTP API

`cmd/server` 入口 · `internal/` 分层 · 独立 `tests/integration/` · `scripts/test.sh` 快速闭环。

## 快速开始

```bash
# 将 go.mod 中 example.com/app 改为你的模块路径
go mod tidy
go run ./cmd/server
curl http://localhost:8080/health
```

## 测试

```bash
./scripts/test.sh       # 开发中：只跑测试
./scripts/verify.sh     # 发版前：测试 + 构建
```

详见 [tests/README.md](tests/README.md)。

## 目录

| 路径 | 用途 |
|------|------|
| `cmd/server/` | 程序入口 |
| `internal/handler/` | HTTP handler |
| `internal/server/` | 路由 / mux（可测） |
| `tests/integration/` | 集成测试 |
| `scripts/test.sh` | 仅测试 |
| `scripts/verify.sh` | plan/run 全量验收 |
