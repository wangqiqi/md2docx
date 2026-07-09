# 迁移对照表（旧 cursor-ai-rules → Super Cursor）

> 旧版只读参考：`~/workspace/tools/.cursor` · 本表供 enrich 与审计用。

## Skills（37 → 精简）

| 旧 skill / 能力 | Super Cursor | 备注 |
|-----------------|--------------|------|
| debug / troubleshoot | **debug** | SPRINT-01 |
| test / e2e | **test** | 含 Playwright/E2E |
| mcp | **mcp** | SPRINT-01 |
| refactor | **refactor** | SPRINT-01 |
| perf | **perf** | SPRINT-01 |
| review / code-review | **review** + **review** agent | SPRINT-02 · 只读 |
| study / learn-tech | **study** | ≠ **learn**（项目认知） |
| security | **security** + `security-sdlc.mdc` | audit/依赖 |
| git / commit | **git** | 已有 |
| api | **api** | 已有 |
| plan / run / learn / scaffold / master / release | 同名 | 核心 |
| finish / delivery | **release** · **delivery** | Sprint 出口 · 7 维交付验收 |
| spike / POC | **spike** agent + `SPIKE-*` | 只读调研 |
| command-center 等编排 | **master** routes | 无伪 class 引擎 |

## Rules（tech / execution）

| 旧 | 新 | Sprint |
|----|-----|--------|
| eslint 细则 | `rules/tech/eslint.mdc` | 02 |
| 纯 JS | `rules/tech/javascript.mdc` | 02 |
| java / python 加深 | `java.mdc` · `python.mdc` | 02 |
| next SSR/CWV | `nextjs.mdc` | 02 |
| 宪法三公理 | `constitution.mdc` | 01 |
| 演进 | `evolution.mdc` | 01 |
| C 与 C++ 拆分 | `c.mdc` · `cpp.mdc` | 01 |
| vibe / cli-python | `vibe.mdc` · `cli-python.mdc` | 01 |

## Agents

| 旧 | 新 | 约束 |
|----|-----|------|
| ship / release | **ship** | 发版 |
| review | **review** | readonly |
| spike | **spike** | readonly |

## 人格（roles）

- 旧 `config/roles/*.json` → 单文件 `config/roles.json`（12 archetype）
- 仅 `attitude/tone/hint`；无 greetings 台词库；全员全能

## 刻意不迁移

- 400 行伪 class 规则引擎 · 多 adjective 人格 · 母版内项目路径
- Web 控制台 · plugins 全量 · 36 hooks · `cursor-master.sh` · command-center agent
- greetings 台词库 · pptx/pdf/docx 等文档生成 skills
- 旧版 37 skills 中未列入上表的项 → 全局 Cursor skills 或项目 `/learn`

## 完整性边界

**Super Cursor 母版「完整」的定义**（自洽检查 `cursor-coherence.sh` 覆盖）：

| 范围 | 标准 |
|------|------|
| 结构 | 22 skills · 3 agents · 42 rules · commands · config/hooks/bin 齐全 |
| 注册 | 每个 `rules/**/*.mdc` 在 `verify-super-cursor.sh` 有 check |
| 交叉引用 | AGENTS ↔ 磁盘 · routes ↔ skills/agents · roles=12 |
| 旧版 parity | **不要求** 1:1 全量迁移；上表「刻意不迁移」为产品边界 |

审计旧版时：对照本表 **已迁移** 列即可；未列项视为 intentional skip，非缺口。
