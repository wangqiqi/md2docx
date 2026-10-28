# run · doc-sync

> 由 `run/SKILL.md` 移出（C5 去重）：主流程留在 SKILL，细节按需加载。

## 对外文档同步（必做）

**禁止**功能已交付、CHANGELOG 已写、README 仍滞后留给人手补。见 **plan** skill「对外门面 · README」。

| 本次 diff 含 | 同轮必做（commit 前） |
|--------------|----------------------|
| `.cursor/skills/` 新增/改名/职责变更 | README 开箱即用 · 指令表 · skills 计数/名单 |
| `.cursor/agents/` | README agents 行 |
| `master/` routes · 新 `/` 指令 · plan/run 工作流 | README mermaid · 机制表 · plan-run 链 |
| 安装路径 · config 公开键 · verify 链 | README 安装/验证节 |
| CHANGELOG `[Unreleased]` 有 Added/Changed（用户可见） | README 摘要与之对齐 |

母版仓库验收：

```bash
bash .cursor/bin/cursor-coherence.sh   # README ↔ 磁盘 skills/agents 一致
```

- **单 TASK**：触发上表任一行 → 该 TASK 的 commit **须含** README 变更（与代码同 commit）
- **Sprint 收尾**：对照 CHANGELOG `[Unreleased]` 审 README；coherence 绿再 commit
- 纯内部/archive-only 无触发 → 可跳过，回复中一句说明

## 文档与 Office 触发表（无感路由）

用户自然语言命中下表时，**自动**选用右侧能力（**勿**要求用户说 skill 名）：

| 用户意图 | Agent 动作 |
|----------|------------|
| 写 PRD/RFC/设计 doc | **plan** §协作文档 · AskQuestion 结构化 vs 自由 |
| E2E / Playwright / 起 dev server | **test** §E2E · `with_server.py` |
| PDF 表单/验收 | **delivery** §PDF 工具 |
| 编辑 docx/pptx/xlsx 深度 | AskQuestion：**装 upstream** anthropics skill / 用 MCP / 跳过 |
| 新 UI 交付走查 | **delivery** §1 反模板自检 |
| 使用说明书 / 配图 regen | **user-manual** `/manual` |
| 测试报告 / verify 汇总 | **test-report** `/report` |
| MCP 建服 | **mcp** §Eval |
| 新功能 0→1 / 写 spec / SDD | **plan** §SDD · Greenfield 模式 |
| 实现后仍有差距 | **run** §converge |

Ambiguous 时 AskQuestion ≤4 项，禁止开放式「你想用哪个 skill」。

### Converge（SDD · 吸收自 github/spec-kit）

**触发**：Greenfield/Brownfield feature 一批 TASK ✅ 后 · 或用户说「对照 spec 看还差什么」。

| 步 | 动作 |
|----|------|
| 1 | 读 `{specs_dir}/<id>/spec.md` + 当前实现（grep/Read） |
| 2 | 列 **未覆盖** FR/用户故事/验收场景 |
| 3 | 差距 → 新 `TASK-*` 写入 plan · 或 **下一 Sprint 候选** |
| 4 | 无差距 → 可选 **review** §SDD analyze 终检 |

勿 silent merge：Blocker 级差距须用户确认再标 feature 完成。
