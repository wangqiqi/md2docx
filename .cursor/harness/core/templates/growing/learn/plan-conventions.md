# Plan & archive conventions（项目特化）

> 由 **`/learn`** 维护 · 供 **plan** · **run** · `runner.sh plan-check` 参考。  
> **勿**写入 `.cursor/rules` 或 skills 正文 — 团队差异只放本文件。

## 域表（archive · scripts · docs 共用）

**一处登记、三处消费**：归档域 · 脚本域（`scripts/verify/domain/`）· 文档主题都以此表为准，避免各写一份。

| 域 | archive/ | scripts/ | docs/ |
|----|----------|----------|-------|
| `sprint` | Sprint 闭合摘要 | — | 验收与发布 |
| `spike` | SPIKE 结论 · ADR | `dev/` | 架构决策 |
| `release` | 发版笔记 | `ops/` | 部署运维 |
| `doc` | 文档/SOP 收敛 | `docs/` | 开发规范 |
| `ops` | 运维 · 数据 · 迁移 | `ops/` | 部署运维 |
| （扩展） | 团队在此追加 | — | — |

母版推荐域全表 → **plan** `reference/growth-layout.md`。

## Archive 命名

| 项 | 本项目 |
|----|--------|
| 目录 | `.growing/archive/{domain}/` — **至少一级域目录** |
| 格式 | `YYYYMMDD_HHMMSS_<topic>_<module>.md` |
| 门禁 | `runner.sh archive-check`（根目录 flat 文件 > `growth.archive_flat_max` 即 FAIL） |
| 说明 | `<topic>` / `<module>` 用英文或拼音缩写，避免空格 |

## docs/ 编号与上限

规则正文 → `.cursor/rules/execution/project-docs.mdc` · 配置 → `config/docs-layout.json`（本项目的 `profile` 与启用号位在此登记）。

**规则**：对外持久文档一律 `NN_中文功能.md`；**带序号文档硬上限 10 个**（超限必须合并同类或下沉 Growth）。

| 号 | 阶段（固定） | 生成方式 |
|----|--------------|----------|
| `01`–`06` | 需求 · 架构 · 数据/契约 · 接口/算法 · 详细设计 · 工程规范 | 人 / Agent（名称见 `docs-layout.json` → `profiles.<profile>`） |
| **`07`** | 使用（默认文件名 **`07_用户手册.md`**，`web-fullstack`） | **自动生成** — `/manual`（`config/manual.yaml` → `doc_path`） |
| **`08`** | 测试（**`08_测试报告.md`**） | **自动生成** — `/report`（`config/test-report.yaml` → `doc_path`） |
| `09`–`10` | 发布 · 调优 | 人 / Agent（名称按 profile） |
| `ROADMAP.md` | 长期计划（**例外：不加序号**） | 人 / Agent 维护 |

号位语义与 profile 名称表 → `config/docs-layout.json` · `templates/project-docs/README.md`（与母版 `project-docs.mdc` 一致）。

**序号纪律**：号**不重用**（删除后留空号）· 新增**追加**· 两自动生成文档的号由 `config/manual.yaml` / `config/test-report.yaml` 的 `doc_path` 固定，**不得手写**。

**自动生成标记**（写文件头，供校验与 regenerate）：

```markdown
<!-- generated: manual · regenerate: /manual -->
```

**docs vs Growth 边界**：

| 进 `docs/`（入 git · 对外 · 持久） | 进 `.growing/learn/`（gitignore · 本地认知） |
|-------------------------------------|--------------------------------------------------|
| 使用者需要的说明、契约、报告 | 本仓约定、模块地图、发版节奏、踩坑记录 |
| 与版本一起演进 | 换人/换机可重建，不进发布物 |

## 任务保留纪律（与母版 plan skill 一致）

细则 SSOT → `.cursor/skills/plan/reference/task-retention.md`（安装后路径）。

| 文件 | 规则 |
|------|------|
| **`.growing/plan.md`** | **禁止**删除或「精简」掉 `⬜`/`🔧`/`⚠️` TASK；禁止未归档就清空 Active Sprint；仅当 **全部 TASK ✅** 且团队确认收尾后，才删除 Active 正文 |
| **`docs/ROADMAP.md`** | **进行中 / 计划中** 未交付行 **不得随意删除**；已完成项迁到「已完成」或 `archive/`，可定期清理 **已完成** 旧行 |

Agent 改上述文件前：diff 不得减少未完成任务行数（除非改为 ✅ 或用户确认废弃）。

## Plan 可选段落（若有）

团队在 plan 中使用的**额外**基线段落（差距表、审查笔记等）在此登记；Sprint 收尾须与 `.growing/archive/` 对齐：

| 段落类型（团队自定） | 收尾动作 |
|----------------------|----------|
| （待填） | 改 **交付态**，或链 `.growing/archive/...` 作历史快照 |

## Sprint 区块标题

`runner.sh plan-check` 在 Sprint 闭合时会 WARN 仍为「进行中」标题的区块：

| 状态 | 标题示例（任选一种语言，团队统一即可） |
|------|----------------------------------------|
| 进行中 | `Active sprint` · `活跃 Sprint` |
| 已闭合 | `Completed sprint` · `已完成 Sprint` |

## Growth 与 git（团队可选）

安装模板默认 **`.growing/` gitignore**（plan · archive · learn · session）。若团队要把协作资产纳入仓库：

| 策略 | 适用 | 动作 |
|------|------|------|
| **默认** | 个人机本地 plan/认知 | 保持 gitignore；换机靠 `/learn` 重建 |
| **纳入 git** | 多人共享 learn · plan · local rules | 从 `.gitignore` 移除对应路径（或 `!/.growing/learn/**` 等）；**仍勿**提交 `session/` · 密钥 |
| **仅 rules** | 只共享门禁 | 只跟踪 `.growing/rules/local/` |

纳入 git 后：`plan.md` 冲突用 Git 合并；敏感草稿仍放 `archive/` 或私人分支。母版说明 → `.cursor/docs/consumer-refresh.md`。

## 与母版分工

| 层 | 内容 |
|----|------|
| `.cursor/` | 通用机制：`SPRINT_STATUS` · Done when · TASK ✅ · reconciliation 清单 |
| 本文件 | 域表 · 归档命名 · docs 编号与上限 · 可选段落类型 · 标题用语 · Growth/git 策略 |

