# Nginx 反代要点（通用）

## 文件位置

- 示例：`deploy/nginx.conf.example` 或 `deploy/nginx-media.conf.example`
- 文档：`docs/deploy/` 说明如何 copy 到 `/etc/nginx/sites-available/`

## 必须对齐

| 项 | 说明 |
|----|------|
| `upstream` 名 | 与 `docker-compose.yml` **service** 名一致 |
| `proxy_pass` | 容器网络 hostname = service 名，非 `localhost`（除非 host 网络模式文档写明） |
| `client_max_body_size` | 与 API 上传 limit · **input-bounds** 一致 |
| WebSocket | `Upgrade` · `Connection` 头；长连接路径与后端一致 |
| 静态/media | `alias` 路径与仓库 `deploy/` 或 volume 挂载一致 |

## 变更

- 改 upstream/port → grep `nginx` · `proxy_pass` · README
- 生产 TLS：cert 路径写 example + 文档，证书不进 repo

## 验收（L0 示例）

```bash
# 项目 scripts 内，非母版根目录
test -f deploy/nginx.conf.example
grep -q 'upstream' deploy/nginx.conf.example
```

扩已有 `verify_*.sh` 时只加上述断言，勿新建并行 orchestrator（见 `verify-registration.md`）。
