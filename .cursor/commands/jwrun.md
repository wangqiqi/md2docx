---
description: 启动 md2docx 自治开发执行（jwrun）
---

加载 skill **jwrun-skill**（入口 command `/jwrun`），读取根目录 `plan.md`：

1. **`./.cursor/bin/dev_runner.sh gate-check`** — 未过则停止（`PLANNING` / `PLAN_APPROVED`）
2. 锁定 `<!-- ACTIVE -->`，标 🔧
3. 实现（最小 diff）
4. **`./.cursor/bin/dev_runner.sh task-verify`** — 任务级验收（非每任务全量 pytest）
5. 更新 plan + CHANGELOG **[Unreleased]**；用 **`next-task`** 推进 ACTIVE/NEXT/LAST_DONE
6. **git commit**（`{ID} {摘要}`）
7. **patch 打版**（每任务必须）：`CHANGELOG.md` 升版 + `pyproject.toml` / `__init__.py` 同步 → `git commit` + `git tag v0.4.xx`（读 plan `VERSION_LINE`）→ plan `RELEASED`
8. Sprint 全部 ✅：**全量** `verify` → **刷新 plan 审计快照（§7B）** → **归档** `archive/sprint/YYYYMMDD_HHMMSS_*` → ROADMAP 标已完成
9. Sprint 结束后若有 ROADMAP 余项 → 建议 **`/jwplan`**
10. `AUTONOMOUS: true` 时 stop hook 链下一项

**禁止**跳过 gate-check / task-verify 就标 ✅。**不**自动 `git push`。
