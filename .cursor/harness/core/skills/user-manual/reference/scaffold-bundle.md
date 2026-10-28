# user-manual · scaffold bundle

**用这个**：新项目用 **scaffold** 附加 `user-manual` bundle 生成 Manual Contract 与脚本骨架。**不是那个**：存量项目手写 — 复制 `templates/manual-contract.example.yaml` 或 **`/manual`** 从 IA/E2E 提取。

## 命令

```bash
./.cursor/bin/scaffold.sh apply-bundle user-manual --dry-run
./.cursor/bin/scaffold.sh apply-bundle user-manual --stack react-vite-ts
```

| 层 | 内容 | 何时复制 |
|----|------|----------|
| **shared** | `config/manual.yaml` · `docs/user-guide.md` · sync/verify 脚本 | 所有栈 |
| **web** | Playwright manual walkthrough · `playwright.manual.config.ts` | `react-vite-ts` · `vue-vite-ts` · `nextjs-ts` 或检测到前端栈 |

## apply 后

1. 编辑 `config/manual.yaml`（角色 · 故事线 · shot 列表）
2. Web 栈：`npm i -D @playwright/test` · 加 `test:e2e:manual` script
3. 实现 UI 后：`MANUAL_WALKTHROUGH_ENABLED=1` regen
4. 详 SOP → 本 skill 其余 `reference/` · `design/user-manual/README.md`（bundle 内）

Manifest：`templates/scaffold/manifest.json` → `bundles[]` · `user-manual`。
