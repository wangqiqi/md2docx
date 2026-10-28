---
name: ops-deploy
description: 部署约定（关键词）— compose/env/nginx。说「部署」「docker compose」时用。
disable-model-invocation: true
---

# ops-deploy · 部署与运维约定

**用这个**：compose / env 模板 / 反向代理 / 部署目录卫生。**不是那个**：业务功能实现 → `/run` · 交付走查 → **delivery** · 安全清单 → **security**。

跨项目 CHANGELOG 审计：**docker-compose / .env / nginx** 为高频重复劳动 — 优先复用本 skill + **deploy-ops** rule，禁止每个 Sprint 重写 env 注释块。

## 何时进入

- 新增或改 `docker-compose*.yml` · `Dockerfile` · `.env.example` · nginx 配置
- 用户说「对齐 env」「compose 归位」「nginx 反代」「部署文档」
- `/master` 或 **scaffold** 后需补部署面
- Sprint 候选 **SPRINT-NN** 类任务

## 流程（四步）

### 1 · 布局与真源

读 `reference/layout.md`：

- **compose 真源**：仓库根 `docker-compose.yml`（或 `compose/` 仅当团队已约定；禁止冗余双份）
- **env 真源**：根 `.env.example`（注释说明 copy → `.env` / `.env.local`）；`.gitignore` 忽略 `.env*`，`!.env.example`
- **nginx**：`deploy/nginx*.conf.example` 或 `docs/deploy/` — 勿散落多份无索引 copy
- **secrets**：仅 env / 密钥管理；禁止写进 compose 明文（用 `${VAR}` + example 占位）

### 2 · env 契约

读 `reference/env-contract.md` · scaffold `reference/ops-env-contract.md`：

- 分段注释：`# --- App ---` · `# --- Database ---` · `# --- Ports ---`
- 端口/URL 与 compose · README · OpenAPI 一致
- 新增变量：同步 `.env.example` + README 安装节 +（若有）Growth `learn/dev-conventions.md` §Deploy

### 3 · nginx / 反代（若适用）

读 `reference/nginx.md`：

- upstream 名与 compose service 名一致
- 静态/media 路径与仓库 `deploy/` 或文档索引一致
- TLS · client_max_body_size · WebSocket 头 — 改一处 grep 全仓引用

### 4 · 验收注册（verify）

读 `reference/verify-registration.md` · **`verify.mdc` §新增脚本门禁**：

- **先 grep** 现有 `scripts/verify*.sh` · `scripts/lib/`
- 部署域 L0：compose/env/nginx example **文件存在** + 关键键 grep
- 扩已有脚本或抽 lib；聚合 `verify.sh` **+1 行**；禁止复制整段 orchestrator

母版 hybrid：**不**在根 `scripts/` 新建业务 verify；目标项目按上节执行。

## 与 scaffold

`/scaffold` 创建的 **standard+** 栈已含 `.env.example` — 对齐 `ops-env-contract.md`，不全栈重写时至少改 **exemplar**（`react-vite-ts`）或文档指针。

## 与 learn

项目特化路径（compose 文件名 · nginx 实际路径 · 端口表）→ `.growing/learn/dev-conventions.md` §Deploy — **勿**写进母版 `.cursor/` 正文。

## 参考

| 文件 | 内容 |
|------|------|
| `reference/layout.md` | 目录与真源 |
| `reference/env-contract.md` | .env.example 字段约定 |
| `reference/nginx.md` | 反代模板要点 |
| `reference/verify-registration.md` | verify 注册与复用 |
| `reference/growth-deploy-fields.md` | Growth learn §Deploy 字段 |
