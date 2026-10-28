# Scaffold · ops env 契约

与 **ops-deploy** skill `reference/env-contract.md` 对齐。各栈 `.env.example` 须满足：

| 项 | 要求 |
|----|------|
| 首行 | 说明 copy 目标（`.env` / `.env.local`）· 勿 commit secrets |
| 分段 | `# --- App ---` 等 |
| 公开前缀 | 前端栈用 `VITE_*` 或 `NEXT_PUBLIC_*`（跟栈） |
| 端口 | 与模板 README ·（若有）compose 一致 |

**Exemplar**：`templates/scaffold/react-vite-ts/.env.example`

新增 scaffold 栈时复制 exemplar 结构，勿每栈自创注释风格。

详 **ops-deploy** skill · **deploy-ops** rule。
