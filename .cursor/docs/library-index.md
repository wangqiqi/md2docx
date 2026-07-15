# 外网协议吸收 · 母版内索引

**SSOT**：本文件 + 各 skill `reference/` 落点。**不是** GitHub 仓库链接的操作手册。

许可与出处仅作记录；实现、流程、模板均在 `.cursor/` 内。

## anthropics/skills（协议已吸收）

| 远端 skill | 母版落点 | 用户自然语言 |
|------------|----------|--------------|
| mcp-builder | **mcp** · `reference/evaluation.md` | 建 MCP · Eval |
| webapp-testing | **test** · **debug** · `scripts/with_server.py` | E2E · Playwright |
| frontend-design | **delivery** §1 · **ux** 分流 | UI 像 AI 模板 |
| doc-coauthoring | **plan** · **run** 三阶段 · Reader Testing | PRD · RFC · 提案 |
| pdf（轻量 scripts） | **delivery** `scripts/pdf/` | PDF 表单验收 |
| skill-creator | **learn** 写作纪律 | 写 skill 方法论 |
| docx · pptx · xlsx | **未纳入**整包 | 建议用户自行安装 upstream 或 MCP |
| 创意/企业类 | **master** `routes.md` §LIBRARY | 按需 |

运行时可选矩阵副本 → `.cursorGrowth/learn/`（`/learn` 吸收，非母版必读）。

## github/spec-kit（SDD · MIT）

| 能力 | 母版落点 |
|------|----------|
| specify · clarify · plan · tasks | **plan** §SDD · `reference/sdd/` · `templates/sdd/` |
| analyze | **review** §SDD analyze |
| implement · converge | **run** |
| principles（≠三公理） | `principles-template.md` · `workflow.json` `sdd` |
| specify-cli · extensions | **未纳入**；用户自选 CLI |

详映射 → `skills/plan/reference/sdd/source-map.md`。

## SkillsMP / 社区（协议已吸收）

| 参考名 | 母版落点 |
|--------|----------|
| code-review | **review** Standards/Spec 双轴 |
| autoreview | **run** closeout review |
| testing-patterns | **test** factory/mock |
| agent-introspection-debugging | **debug** 内省 |
| agent-sort | **master** / **scaffold** DAILY/LIBRARY |

版本记录：发版时写入仓库根发版日志（**release** skill；母版 skill 正文不链该文件）。

## LessUp/awesome-cursorrules-zh（通用蒸馏 · MIT 镜像）

上游：[LessUp/awesome-cursorrules-zh](https://github.com/LessUp/awesome-cursorrules-zh)（PatrickJS 中文镜像）。**不**整包拷贝 132 条 `.cursorrules`；栈专用 → [rules-catalog](rules-catalog.md) · `.cursor/rules/local/`。

| zh 来源（general/tools） | 母版落点 |
|--------------------------|----------|
| gherkin-testing | **testing** `testing.mdc` § BDD/Gherkin |
| pair-interviews · github-quality | **collaboration** `collaboration.mdc` § 评审清单 |
| ticket-template | **bugfix** `bugfix.mdc` § Issue 报告 |
| code-style · code-guidelines | **scope** `scope.mdc` § 命名与可读性 |
| git-conventions | **git** skill § Conventional Commits |

审计摘要 → `.cursorGrowth/archive/`（项目本地，勿链具体文件名）。

## SpaceZephyr/pm-skills（协议已吸收 · MIT）

上游：[SpaceZephyr/pm-skills](https://github.com/SpaceZephyr/pm-skills)（MIT）· 维护：SpaceZephyr /「空格的键盘」。**不**整包拷贝 `pm-*` 进母版；顾问团整包 → 用户自选安装 upstream。

| 远端 skill | 母版落点 | 用户自然语言 |
|------------|----------|--------------|
| pm-prd-writer | **plan** §协作文档 · `reference/doc-prd-enrich.md` | 写 PRD · 需求体检 · 补漏 · 待确认项 |
| pm-review-board | **review** §文档预审 · `reference/doc-review-checklist.md` | 过评审 · 模拟评审会 · PRD 预审 |
| pm-tracking-spec-writer | **delivery** `reference/checklist-optional.md` §埋点 | 埋点 · 事件表 · 指标口径 |
| pm-master（链路） | **master** `routes.md` §LIBRARY 产品工作流 | 产品全流程 · 从头到尾走一遍 |
| pm-prioritization-engine | **plan** `reference/prioritization.md` | RICE/ICE/Kano · backlog 排序 |
| pm-roadmap-planner | **未纳入** | 甘特路线图（与 plan Sprint 重叠） |
| pm-experiment-designer | **未纳入** | A/B 实验方案 |
| pm-advisory-suite（7 个） | **未纳入**整包 · LIBRARY 策展 | 该不该做 · 价值判断 · 访谈求真 |
| pm-image2proto · pm-url2proto · pm-image2pencil | **未纳入** | 截图/网址原型（栈绑定重；CLI 设计走 **pencil-design**） |

### 泛化命名纪律（母版正文）

吸收 pm-skills 顾问团/方法论时：

| 做 | 不做 |
|----|------|
| 功能/视角名：风险与可行性预审 · 发现与假设树 · 价值与替换成本 · 访谈求真 · 故事地图与 MVP 切片 · 成果 vs 功能堆叠 | **具体专家/作者人名**作母版节标题或路由名 |
| README / 本索引致谢 **仓库** SpaceZephyr/pm-skills | 把方法论代表人物写成 pm-skills **作者** |
| 用户装 upstream 整包时保留对方 `pm-advisor-*` 目录名 | 在 `.cursor/skills/` 新建平行 `pm-*` skill |

## @pencil.dev/cli（Pencil CLI · MIT）

上游：`@pencil.dev/cli` npm 包根目录 `SKILL.md`（母版收录 **0.2.8**）。

| 能力 | 母版落点 | 用户自然语言 |
|------|----------|--------------|
| CLI 生成/迭代 `.pen` + 导出图 | **pencil-design** · `/pencil-design` | 做设计 · mockup · landing page 视觉 · 海报 · App 屏 |
| 编辑器内 `.pen` 节点操作 | **未纳入**（Cursor Pencil MCP 插件） | 改这个组件 · 调布局 · 设计稿里改色 |

升级 CLI 后同步 skill：`curl -fsSL "https://unpkg.com/@pencil.dev/cli@latest/SKILL.md" -o .cursor/skills/pencil-design/SKILL.md`

## 安装外网 skill 前

**security** §外部 Agent Skill · **master** → `deps` · 用户确认后装 `~/.cursor/skills/`。
