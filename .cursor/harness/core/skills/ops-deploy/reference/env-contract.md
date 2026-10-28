# .env.example 契约

## 结构

1. **首行**：用途（copy to `.env` / `.env.local`，勿 commit secrets）
2. **分段**：`# --- Section ---`（App · Database · Redis · Ports · Feature flags）
3. **每变量**：`KEY=value` + 上行或同行 `#` 说明（单位 · 默认 · 与 compose  service 关系）
4. **占位**：`changeme` · `localhost` · 示例端口 — 禁止真实密钥

## 命名

| 场景 | 约定 |
|------|------|
| Vite/前端公开变量 | `VITE_*` |
| Next 公开 | `NEXT_PUBLIC_*` |
| 后端 | 无前缀或项目前缀；与 `config/` 读取键一致 |
| 数据库 URL | 单一 `DATABASE_URL` 或分项 `DB_HOST` — 全仓统一一种 |

## 变更纪律

改 env 键或默认端口时同步：

- [ ] `.env.example`
- [ ] `docker-compose.yml` ports / environment
- [ ] README 安装/运行
- [ ] （若有）OpenAPI server URL · E2E baseURL
- [ ] Growth `learn/dev-conventions.md` §Deploy

## Exemplar

scaffold `react-vite-ts/.env.example` 为最小前端示例；全栈项目在此基础上扩展 Database/Redis 段。
