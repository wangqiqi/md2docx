# Growth · dev-conventions §Deploy 字段

项目安装 Super Cursor 后，由 **`/learn`** 填写 `.growing/learn/dev-conventions.md` §Deploy。

## 建议表格

| 字段 | 示例 | 说明 |
|------|------|------|
| compose 入口 | `docker-compose.yml` | 编排真源路径 |
| env 模板 | `.env.example` → `.env` | copy 目标 |
| nginx 示例 | `deploy/nginx.conf.example` | 无 nginx 则填「无」 |
| 默认 HTTP 端口 | `8080` | 与 README 一致 |
| verify 部署 L0 | `bash scripts/verify.sh`（含 deploy 段） | 或域脚本名 |
| systemd / k8s | （可选） | 若有则一行路径 |

## 禁止

- 把具体项目 IP/域名写进母版 `.cursor/skills/ops-deploy/`
- 在 learn 里复制整份 nginx — 只记路径与端口真源

模板真源：`.cursor/templates/growing/learn/dev-conventions.md` §Deploy
