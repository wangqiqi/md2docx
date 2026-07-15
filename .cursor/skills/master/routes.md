# master · 路由表

AskQuestion 选项与关键词 → 下游 skill / agent / rules。  
无 AskQuestion 工具时：同表**正文编号选项**（见 **master**「AskQuestion 约定」）。  
与 `.cursor/README.md` **场景速查** 对齐；详表在本文件，README 为摘要链。

## 主路由（第 1 轮 · ≤7 项）

| 选项 id | 意图 | 入口 | 关键词（中英） |
|---------|------|------|----------------|
| `scaffold` | 新建 / 空项目 | **scaffold** `/scaffold` | 脚手架、初始化、空仓库、new project、bootstrap |
| `plan` | 规划 / Sprint / 调研 / 文档 | **plan** `/plan` | 规划、需求、Sprint、SPIKE、DOC、归档 |
| `run` | 继续开发 | **run** `/run` | 继续、做任务、ACTIVE、next task |
| `learn` | 了解本仓 | **learn** `/learn` | 本仓约定（**不是** study 学技术） |
| `fix` | bug / 验收 / 闸门 | bugfix · **run**/**plan** | bug、hotfix、verify 失败、gate-check、卡住 |
| `ship` | 发版 | **release** · **ship** | 打版、发版、CHANGELOG、tag、release |
| `more` | 审查 / 文档 / 依赖 / 配置 | 见下表 | commit、PR、security、api、submodule、config |

## `more` 子路由（第 2 轮 · ≤7 项）

| 子 id | 意图 | 入口 | rules / 命令 |
|-------|------|------|----------------|
| `git` | Git / PR / Review / 收尾 | **git** · **release** · **review** · `babysit` · `split-to-prs` | `commit.mdc` · collaboration |
| `pr` | PR 描述 / Review / babysit | **git** · **review** · `babysit` | collaboration |
| `security` | 安全审查 | **security** | — |
| `api` | API 设计 | **api** | `rules/execution/api.mdc` |
| `delivery` | 交付验收 / 上线前 | **delivery** | **用这个**上线走查；**不是** `/ia` 规划 |
| `ux` | UX / 体验不好 / 界面乱（未明 IA/交付） | **ux** | **用这个**分流；明导航→**ia** · 明上线→**delivery** |
| `ia` | 信息架构 / 导航迷路 / 角色首页 | **ia** | **用这个**结构层；**不是** delivery 视觉抛光 |
| `docs` | 文档同步 | **plan** `DOC-*` 或直述 | `rules/execution/docs.mdc` |
| `deps` | 依赖 / 选型 / vendor / submodule / **外网 Agent Skill** | 直述 + 规范 | `oss-first.mdc` · `submodule.mdc` · **security** §外部 Agent Skill · §DAILY/LIBRARY |
| `config` | verify / 本地 rules / 母版自测 | 见 [扩展场景](#扩展场景) | `config/workflow.json` |
| `style` | 人格 / 沟通语气 | `config/roles.json` | 见 [人格预设](#人格预设-style) |

## 外网 skill · DAILY / LIBRARY（`deps`）

**用这个**：安装 Super Cursor 或外网 skill 后，按**本仓证据**裁剪默认加载面，避免全量噪音。**不是那个**：发现 skill 商店 → 上表 `deps` + **security** 审计；学本仓约定 → **learn**。

吸收自 SkillsMP `agent-sort`（协议 only，不装 ECC）。

| 桶 | 含义 |
|----|------|
| **DAILY** | 每会话强相关 — 与本仓语言/框架/workflow 明确匹配，值得默认启用 |
| **LIBRARY** | 保留可达、**不**默认全载 — 离栈、偶用、或上下文开销大于收益 |

**证据来源**（分类前必读仓库）：扩展名 · lockfile · `package.json` / `pyproject.toml` / `go.mod` · 框架配置 · CI · `scripts/test.sh` · `.cursorGrowth/learn/module-map.md`。

**分类规则**：

- 晋升 **DAILY**：栈在用 + 每任务都可能用到（如活跃栈的 `rules/tech/*`、**plan**/**run**/**learn**）
- 降级 **LIBRARY**：离栈 tech rules、未用的 **perf**/**mcp**、一次性 **study** 主题、外网 skill 仅偶发场景

**输出**（给用户或写入 `learn/dev-conventions.md` 一句）：

```text
DAILY   — 路径 + 证据
LIBRARY — 路径 + 何时手动选用
```

安装外网 skill 到 `~/.cursor/skills/` 前仍走 **security** §外部 Agent Skill；**禁止**引入第二套安装 CLI 作为母版必选路径。

### anthropics/skills · LIBRARY 速查

**不默认加载**；用户意图命中或 `deps` 路由时引用。详表 → **`docs/library-index.md`** · `routes.md` §LIBRARY。

| 远端 skill | 何时建议（用户自然语言） | 母版已吸收 |
|------------|--------------------------|------------|
| mcp-builder | 建 MCP server | ✅ **mcp** |
| webapp-testing | E2E · Playwright · 起服测试 | ✅ **test** scripts |
| frontend-design | 新 UI 像模板 · 要独特视觉 | ✅ **delivery** §1 |
| doc-coauthoring | 写 PRD/RFC/提案 | ✅ **plan** · **run** |
| pdf | PDF 表单/验收 | ✅ **delivery** scripts/pdf |
| docx · pptx · xlsx | 深度 Office 编辑 | ❌ 建议 `npx skills add` / upstream · office/ 过重 |
| algorithmic-art | 生成艺术 · p5 | LIBRARY only |
| brand-guidelines | 企业 VI · 品牌色 | LIBRARY only |
| internal-comms | 内部周报 · FAQ · 3P | LIBRARY only |
| theme-factory | 幻灯片/文档主题包 | LIBRARY only |
| slack-gif-creator | Slack 动图 | LIBRARY only |
| canvas-design | 海报 · 平面资产 | LIBRARY only |
| skill-creator | 写/优化 skill 方法论 | ✅ **learn** |
| claude-api · web-artifacts-builder | Claude 专用 | Out of scope |

**Office 深度编辑** — AskQuestion（≤3 项）：`装 upstream anthropics skill` · `用 MCP/飞书等` · `本轮不做`

### github/spec-kit · LIBRARY

**不默认加载** `specify-cli`；SDD 协议已并入 **plan · run · review**。详表 → **`docs/library-index.md`** · `reference/sdd/source-map.md`。

| spec-kit 能力 | 母版已吸收 | 何时用 LIBRARY |
|---------------|------------|----------------|
| specify · clarify · plan · tasks | ✅ **plan** §SDD + `reference/sdd/` 模板 | — |
| analyze | ✅ **review** §SDD analyze | — |
| implement | ✅ **run** | — |
| converge | ✅ **run** §converge | — |
| constitution | ✅ `principles-template.md` | — |
| `specify-cli` · `specify init` | ❌ | 要完整 upstream 工作流 · `uv tool install specify-cli` |
| extensions · presets · bundles | ❌ | 社区扩展 · `specify extension search` |

**路径**：默认 `docs/specs/`（`workflow.json` `sdd.specs_dir`）；与 spec-kit 原生 `specs/` 可配置兼容。

### SpaceZephyr/pm-skills · LIBRARY

**不默认加载**整包；产品协议已蒸馏进 **plan · review · delivery**。详表 → **`docs/library-index.md`**。

| 远端 skill | 母版已吸收 | 何时用 LIBRARY（装 `~/.cursor/skills/`） |
|------------|------------|------------------------------------------|
| pm-prd-writer | ✅ **plan** `doc-prd-enrich.md` | — |
| pm-review-board | ✅ **review** §文档预审 | — |
| pm-tracking-spec-writer | ✅ **delivery** §埋点 | — |
| pm-master 链路 | ✅ 下表预置链路 | 要完整 20 skill 编排 |
| pm-prioritization-engine | ✅ **plan** `prioritization.md` | — |
| pm-roadmap-planner | ❌ backlog | 甘特专精（与 Sprint 重叠） |
| pm-experiment-designer · pm-analytics · pm-survey-designer | ❌ | 实验/分析/问卷专精 |
| pm-advisory-suite（产品判断顾问团） | ❌ 不蒸馏 | 「该不该做」· 价值判断 · 访谈求真 |
| pm-image2proto · pm-url2proto · pm-image2pencil | ❌ | 截图/网址原型（CLI 设计 → **pencil-design**） |

**母版命名纪律**：正文用功能/视角名（风险与可行性预审 · 发现与假设树 · 价值与替换成本 等），**禁止**专家人名作节标题。

**预置产品链路**（每步产出是下一步输入；可让用户砍步）：

```text
[想法] →（可选）装 upstream 产品判断 skill
      → plan §协作文档 + doc-prd-enrich（PRD + 待确认项）
      → review §文档预审
      → plan 修订 → delivery §埋点
```

用户只要一步 → 只 handoff 对应 skill，不强推链路。

## 人格预设 (`style`)

> **仅改语气/性格，全员 `skills: full`（同等全能）**；默认 `dashu`。12 项分两轮 AskQuestion（每轮 ≤7）。

每人字段：`id` · `role_name` · `nicknames[]` · `given_name` · `voice_cues` · `personality` · `tone` · `attitude` · `intensity` · `speech_examples` · `skills`（全员 `full`）。

| 字段 | 用途 | Agent 禁止 |
|------|------|------------|
| `given_name` | **用户点名**匹配（如「呼叫老周」） | 回复开场自报此人设名 |
| `voice_cues` | 落地语气：称呼用户、句长、语气词 | 忽略 cues 只用名字装人设 |
| `speech_examples` | 句式锚点（≥3 条） | 照抄 given_name 开场 |

全局 `speech_rules.forbid_self_name_opener` → 见 **super-cursor-persona.mdc**。

### 呼叫（会话内）

用户说「呼叫 / 切换」+ 下列任一即可匹配（大小写不敏感）：

| 字段 | 例（萝莉） |
|------|------------|
| `id` | `loli` |
| `role_name` | 萝莉 |
| `nicknames` | 小妮 |
| `given_name` | 妮妮 |

**Agent 必做顺序**：

1. `bash .cursor/bin/resolve-role.sh .cursor/config/roles.json '<称呼>' [项目根]`
2. **唯一命中** → 写 `.cursorGrowth/session/persona.json`（`persona_id` · `resolved_via` · `updated_at` ISO8601）→ **本会话改用该人格语气**（`skills` 仍 full）
3. **exit 2 多命中** → AskQuestion / 正文编号消歧，**禁止**静默猜人
4. **exit 1 未命中** → 说明无此人，列出 `/master` → `style` 或常用称呼

**解析优先级**：

1. `.cursorGrowth/session/aliases.json` → `aliases`（项目覆盖，gitignore）
2. 母版 `roles.json`：`id` / `role_name` / `nicknames` / `given_name`

- 持久默认仍用 `workflow.json` → `role.default`（可选；会话态优先由 `run-start` 注入）
- 模板：`templates/cursorGrowth/session/persona.json` · `aliases.json`（勿 commit Growth）

**轮 1 · 日常/硬核**：`professional` · `zhiyin` · `tough_guy` · `strict` · `old_master` · `dashu` · `pretty_boy`

**轮 2 · 个性**：`loli` · `maid` · `tsundere` · `seductive` · `queen`

## 扩展 skill 路由

| 关键词 | 入口 |
|--------|------|
| 调试、隔离、根因 | **debug** |
| 测试、E2E、Playwright | **test** |
| MCP、工具服务器 | **mcp** |
| 重构 | **refactor** |
| UX、体验、不好用、界面乱 | **ux** |
| 信息架构、导航、迷路、Dashboard、角色入口、工作流分支 | **ia** |
| 性能、慢、瓶颈 | **perf** |
| 代码回顾、REV | **review** · **review** agent |
| 学新技术、study | **study**（≠ `/learn`） |
| 调研只读、SPIKE | **spike** agent · **plan** `SPIKE-*` |
| 周报、本周总结、weekly report | **week** · `/week` |
| 磁盘快照、空间变动、disk snapshot | **disk** · `/disk` |
| 环境维护、清理缓存、系统维护 | **maintain** · `/maintain` |
| 做设计、mockup、landing page 视觉、.pen、生成海报/App 屏 | **pencil-design** · `/pencil-design` |
| 分支收尾、merge、开 PR、打 tag | **release** · **git** |
| PR 评论、CI 循环 | `babysit`（`more` → `git`） |
| 拆 PR、大 diff | `split-to-prs`（`more` → `git`） |

## 扩展场景

README 场景速查中无独立主菜单、经 `more` → `config` 或关键词命中：

| 我想… | 路由 |
|-------|------|
| 配置或排查 verify | `config/workflow.json` · `./.cursor/bin/runner.sh verify` · `rules/feedback/verify.mdc` |
| 加项目私有 rules | `.cursor/rules/local/`（目标项目自建，不 commit 进母版） |
| 验证 Super Cursor 母版完整性 | `bash .cursor/verify-super-cursor.sh` 或 `bash .cursor/bin/template-verify.sh` |
| 自治 Sprint 连跑 | **plan** handoff `AUTONOMOUS:true`（默认）→ **`/run` 一次** → 同会话连跑 TASK；决策清单见 `autonomy-chain.md` |
| 仅要规范不要闸门 | `workflow.json` → `workflow.enabled: false`（`rules-only` profile） |
| 技术栈开发细则 | **run**/**plan** 执行时自动加载 `rules/tech/*` glob |

## 关键词索引

自由描述时 grep 本表：

| 关键词 | 路由 |
|--------|------|
| help、从哪开始、不知道、怎么用 | **master**（已在 master 内则继续子问） |
| 脚手架、空仓库、初始化 | **scaffold** |
| 规划、Sprint、拆任务、TASK | **plan** |
| 调研、POC、可行性、SPIKE | **plan** · `SPIKE-*` |
| 只写文档、README、DOC | **plan** · `DOC-*` · `docs.mdc` |
| 归档、ROADMAP、Sprint 做完 | **plan** · `archive/` |
| 继续、实现、ACTIVE | **run** |
| 了解项目、learn、模块地图 | **learn**（≠ study） |
| bug、hotfix、线上、报错 | **fix** → bugfix |
| 验收失败、verify 红、task-verify | **fix** → verify.mdc · **run**/**plan** |
| gate-check、PLAN_APPROVED、被挡 | **fix** → **plan** |
| 发版、CHANGELOG、tag | **ship** → release / ship |
| commit、push、分支 | **more** → **git** |
| PR、Review、合并请求 | **more** → **git** · **review** · **release** · `babysit` |
| 分支收尾、merge、发版 | **release** · **git** |
| 拆 PR、split | `split-to-prs` · **more** → **git** |
| 密钥、PII、鉴权、安全 | **more** → **security** |
| REST、OpenAPI、接口 | **more** → **api** |
| 交付验收、上线前、生产就绪、i18n、视觉一致性 | **more** → **delivery** · `/delivery` |
| 周报、本周总结、CHANGELOG 汇总 | **week** · `/week` |
| 磁盘快照、空间占用、哪个目录变大 | **disk** · `/disk` |
| 环境维护、清理磁盘、dev maintenance | **maintain** · `/maintain` |
| 做设计、mockup、视觉稿、.pen、海报、banner、App 屏 | **pencil-design** · `/pencil-design` |
| submodule、vendor、依赖升级、开源选型、许可证、MIT、GPL | **more** → `deps`（`oss-first.mdc` · `submodule.mdc`） |
| 外网 skill、安装 skill、发现 skill、有没有能做 X 的 skill | **more** → `deps` → **security** §外部 Agent Skill；个人目录安装须用户确认 |
| DAILY、LIBRARY、裁剪 skill、精简规则、skill 太多、全量安装 | **more** → `deps` §DAILY/LIBRARY；结论可写入 **learn** |
| workflow.json、hooks、profile | **more** → config |
| 本地 rules、local | **more** → `.cursor/rules/local/` |

## 上下文捷径

| 检测信号 | 优先建议 |
|----------|----------|
| `scaffold.sh detect` → empty | **scaffold** |
| 无 `plan.md` 且要做功能 | **scaffold** 或 **plan**（AskQuestion） |
| `gate-check` OK 且有 ACTIVE | **run** |
| `gate-check` BLOCK | **plan** 或 **fix** → 闸门 |
| `PLANNING:true` | **plan**（继续规划） |
| `task-verify` / `verify` 失败 | **fix** → **run**；仍失败 **plan** `⚠️` |
| 用户贴 CHANGELOG / 说升版本 | **ship** |
| 母版仓库 / 改 `.cursor/` 验收 | `template-verify.sh`（须用户明确授权才改母版） |

## 推荐路径（给用户看，一行）

```
空仓库:  master → scaffold → learn → plan → run → verify
迭代:    master → plan → run（循环）
卡住:    master → fix → run 或 plan
迷路:    master → （≤7 项选对）→ 对应 slash
```

## 文档

- [quickstart.md](../../docs/quickstart.md) — 5 分钟闭环
- [effective-collaboration.md](../../docs/effective-collaboration.md) — 效果型效率 · 少拉扯才是真省
- [walkthrough.md](../../docs/walkthrough.md) — 端到端示例
- [training/skills.md](../../docs/training/skills.md) — 全 skill 表
- [scaffold.md](../../docs/scaffold.md) · [plan-run.md](../../docs/plan-run.md)
- [README 场景速查](../../README.md) — 摘要表 + 链回本文件
