# Scaffold

空项目脚手架与已有项目审计，入口 **`/scaffold`**（**scaffold** skill）。

## CLI

```bash
./.cursor/bin/scaffold.sh list
./.cursor/bin/scaffold.sh detect
./.cursor/bin/scaffold.sh info react-vite-ts
./.cursor/bin/scaffold.sh apply react-vite-ts --dry-run
./.cursor/bin/scaffold.sh apply go-api
./.cursor/bin/scaffold.sh audit
```

## 模板位置

```
.cursor/templates/scaffold/
  manifest.json
  react-vite-ts/
  vue-vite-ts/
  nextjs-ts/
  go-api/
  rust-axum/
  python-fastapi/
  java-gradle/
  cpp-cmake/
```

每个模板为 **standard+** 层级：独立测试目录/框架 · `scripts/test.sh`（开发闭环）· `scripts/verify.sh`（全量验收，可设 `verify_default`）· CI · `.env.example`。

## skill vs 模板 vs rules

| 组件 | 是什么 |
|------|--------|
| **scaffold** skill | `/scaffold` 交互流程（AskQuestion、dry-run、apply） |
| **templates/scaffold/** | 各栈项目骨架（文件树，不是 skill） |
| **rules/tech/** | 创建后的编码 SOP（编辑 `*.go` 时自动加载等） |

## 交互原则

1. **先问再做** — AskQuestion 确认栈与范围
2. **先预览** — `--dry-run` 展示 CREATE/SKIP
3. **已有项目** — `audit` 优先，避免盲目覆盖
4. **与 plan/run 兼容** — 可 standalone，也可作为 `TASK-001` 验收命令
5. **`.cursorignore`** — apply 时从 `_shared.cursorignore` 写入仓库根；覆盖 Node/Python/Go/Rust/Java/C++ 依赖与构建产物（`.gitignore` alone 不够）

## 与 Super Cursor 边界

- 脚手架文件写入**仓库根**（业务代码），不是 `.cursor/`
- 项目特化约定 → `/learn` → `.growing/learn/`
- 新栈母版贡献须用户明确要求（`.cursor/` 不可变原则）

## 共享层 `_shared/`

`apply` 先铺 `templates/scaffold/_shared/**`，再由栈内文件覆盖（`_shared.cursorignore` 仍单独合并）：

| 文件 | 作用 |
|------|------|
| `scripts/README.md` | **项目脚本矩阵 SSOT**（分层 + 何时跑） |
| `scripts/lib/_common.sh` | 公因子：`sc_root` · `sc_step` · `sc_ok/sc_fail` · `sc_require_cmd` · `sc_summary` |
| `scripts/lib/_frontend.sh` | 前端栈公因子：`sc_frontend_verify`（lint → type-check → test → build） |
| `scripts/verify/{domain,tier}/` · `ops/` · `dev/` | 分层骨架（`.gitkeep` 占位） |
| `onekey_start.sh`（`_shared` 根） | 铺到**仓库根**；与 `templates/project-onekey/` 同源 · `scaffold-integrity.sh` cmp |

各栈 `manifest.json` → `test_framework` 声明首选测试栈（`testing.mdc` §框架选型），`scaffold-integrity.sh` 校验脚本真的调用了它。

规则：**根目录只留入口**，新实现落子目录，共享断言进 `lib/_*.sh`；由 `verify-scripts-layout.sh` 断言（含重复块检测）。
