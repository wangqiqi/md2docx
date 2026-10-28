# 部署域 verify 注册

真源：**`rules/feedback/verify.mdc` §新增 verify 脚本门禁**。

## 新增前 checklist

1. `grep -r 'compose\|\.env\|nginx' scripts/verify*.sh scripts/lib/`
2. 能否并入 `verify.sh` L0（文件存在 · 关键字符串）？
3. 能否抽 `scripts/lib/_env.sh` 或 `_compose.sh` 供多域复用？
4. 必须新脚本 → 仅域差分；`verify.sh` / `verify_all.sh` **+1 行**

## 部署域典型 L0/L1

| 检查 | 层 |
|------|-----|
| `.env.example` 存在 · 无空 KEY= | L0 |
| `docker-compose.yml` 存在 · service 名与 docs 一致 | L0 |
| `deploy/nginx*.example` 存在 · 含 upstream | L0 |
| `docker compose config` 解析通过（本地有 compose 时） | L1 |
| HTTP smoke `/health`（需 `--full` / L3） | L3 |

## 母版 hybrid

Super Cursor 母版仓无根 `scripts/verify.sh` — 本 skill 的 checklist 用于**目标项目**；母版 Sprint 验收用 `verify-super-cursor.sh` + `cursor-coherence.sh`。
