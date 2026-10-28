# 技术栈 · 整包安装与按需启用

Super Cursor **不按语言拆安装包**：`install-super-cursor.sh` 始终 **整包复制** 母版 `.cursor/`。项目差异通过 **`.growing/project-profile.json`** 控制 **运行时启用哪些面**（更快、少占 token），而不是 install 时删减文件。

## 术语

| 概念 | 说明 |
|------|------|
| **整包安装** | 全量 `rules/` · `skills/` · `bin/` 等同版进入目标仓 |
| **按需启用** | 会话 hook、Agent 引导、verify 策略只 **启动** 与本仓 `stacks.primary` 相关的面 |
| **不是** | 为 Java 单独发瘦版 `.cursor`、install 时删除 `rules/tech/cpp.mdc` |

## 绿地 vs 棕地

```mermaid
flowchart LR
  subgraph install [整包安装]
    A[install-super-cursor.sh --replace]
  end
  subgraph green [绿地]
    B[scaffold detect]
    C[scaffold apply id]
    D[adapt --write 对齐 primary]
  end
  subgraph brown [棕地]
    E[scaffold detect]
    F[scaffold adapt --write]
    G[/learn 写 dev-conventions]
  end
  A --> B
  B -->|empty| C
  B -->|established| F
  C --> D
  F --> G
```

| 场景 | 动作 |
|------|------|
| **空仓** | `scaffold apply <id>` → 建议 `scaffold adapt --write` 写入 profile |
| **已有代码** | **禁止**盲目全量 `apply` → `scaffold audit` · **`scaffold adapt`** · `/learn` |
| **升级 `.cursor` 后** | 保留 `.growing` → **`scaffold adapt`** 刷新探测 → 核对 `learn/dev-conventions.md` |

## 四层：安装 vs 启用

| 层 | 整包在盘 | 按需启用 |
|----|----------|----------|
| **Workflow / hooks** | ✅ | `--profile full \| lite \| rules-only`（非按语言） |
| **Skills** | ✅ | `--skills-bundle full \| core`；任务触发，不删文件 |
| **`rules/tech/*.mdc`** | ✅ 13 个文件 | Cursor **glob**（编辑匹配扩展名才注入）+ profile **primary** 供 Agent 优先 |
| **`scripts/verify.sh` / layers** | 脚手架或自建 | `project-profile.json` → **`verify.enabled_tiers`** · **`verify.enabled_slices`** |

### Skills 与 profile

Skills 不按栈裁剪。profile 的作用是：让 **run-start** 与 **learn** 标明主栈，避免 Agent 在无必要时引用他栈命令。

## `project-profile.json`（Growth SSOT）

| 字段 | 含义 |
|------|------|
| `stacks.detected[]` | `scaffold.sh` 文件信号探测结果 |
| `stacks.primary[]` | **启用**的主栈（可多栈，如 `java` + `vue`） |
| `verify.enabled_tiers[]` | 允许跑的验收层（默认 `l0` · `l1` · `l2-core`） |
| `verify.enabled_slices[]` | 可选 slice id 白名单；**空** = 仅按 tier 策略（见下节） |
| `tech_rules.mode` | 现仅 `globs-only`（盘内保留全量 tech rules） |

模板与 JSON Schema：

- `.cursor/templates/growing/project-profile.example.json`
- `.cursor/templates/growing/project-profile.schema.json`

CLI：

```bash
.cursor/bin/scaffold.sh adapt              # 预览（默认 dry-run）
.cursor/bin/scaffold.sh adapt --write      # 写入 .growing/project-profile.json
.cursor/bin/scaffold.sh adapt --write --primary=java,vue
```

`run-start` 在存在 profile 时注入一行 **Project profile: primary=…**（省 token，不展开全栈手册）。

## Verify · 按需启用

| 机制 | 行为 |
|------|------|
| **`verify.enabled_tiers`** | `run-manifest-tier.sh` 启动前检查；请求 tier 高于 profile 允许上限 → **FAIL**（提示扩 tier 或 `VERIFY_IGNORE_PROFILE=1`） |
| **`manifest.tsv` 第 4 列 `stacks`** | `*` / 空 = 通用；否则与 `stacks.primary[]` 求交，无交 → **SKIP** 该行（日志 `[verify] SKIP profile stacks=…`） |
| **无 profile** | 不过滤（棕地未 `adapt` 不惩罚） |
| **`VERIFY_IGNORE_PROFILE=1`** | 跳过 tier / stacks 过滤 |
| **`enabled_slices[]`** | 契约保留；slice 级白名单跟后续 Sprint（当前以 manifest `stacks` 列为主） |

消费方：`scaffold apply-bundle verify-layers` 后，栈专属 `command` 行保持注释，**按需取消注释**并填写 `stacks` 列。详 bundle 内 `README-verify-layers.md`。

母版自检仍用 `bash .cursor/template-verify.sh`（与业务 verify 分层无关）。

## 控制面 · profile 与 token（诚实矩阵）

**用这个**：判断「adapt / profile 能帮到哪」；**不是那个**：以为 install 会瘦包、或 profile 会自动卸载 Cursor 里的 rules/skills 文件。

| 控制面 | profile / adapt 已管什么 | 仍靠 Cursor / 习惯 | 对 LLM token 的典型影响 |
|--------|--------------------------|--------------------|-------------------------|
| **Verify 执行** | `enabled_tiers` · manifest `stacks` 列过滤 | 业务 `scripts/verify.sh` 内容 | 间接（少跑无关 slice → 少贴日志） |
| **Hooks** | `run-start` 一行 profile（primary · tiers · slices 计数） | `lite` profile 关 hooks | 小（固定注入） |
| **`learn/dev-conventions`** | `adapt --write` 同步 `SC_PROFILE_SYNC` 段 + DAILY/LIBRARY 建议 | 人工段仍由 `/learn` 维护 | 中（新会话少重复讲栈） |
| **`rules/tech/*.mdc`** | SSOT 声明 `tech_rules.mode=globs-only`；同步段列出 DAILY/LIBRARY **建议** | **glob** 按编辑文件注入；离栈 rule 不会自动卸盘 | 中（glob 已省无关栈；习惯上勿 `@` 离栈 rule） |
| **Skills** | 同步段提示 LIBRARY skill；`disable-model-invocation` 生命周期类不自动加载 | 28 skills 仍在盘；意图命中仍可读 skill | 中（少误载 perf/mcp 等） |
| **AlwaysApply rules** | 无（母版固定 4 条） | `core` · `workflow` · `cursor-standalone` · `persona` | 固定税 · 勿压缩 |
| **安装包体积** | **无** — 始终整包 `.cursor/` | `--skills-bundle core` 仅少 5 个 skill 文件 | 略 |

Token 总成本与「少拉扯」→ [effective-collaboration.md](effective-collaboration.md)（含 `project-profile` 交叉引用）。

## 脚手架 manifest（绿地模板）

`scaffold.sh list` · `.cursor/templates/scaffold/manifest.json` 现含 8 栈：`react-vite-ts` · `vue-vite-ts` · `nextjs-ts` · `go-api` · `rust-axum` · `python-fastapi` · `cpp-cmake` · `java-gradle`。

| 栈 | `rules/tech` | scaffold |
|----|--------------|----------|
| Go · Vue · Python · C++ · Node | ✅ | ✅ 对应 id |
| Java | ✅ `java.mdc` | ✅ `java-gradle`（Gradle KTS · JUnit 5；无 Spring） |
| Android | ❌ | ❌ → `.growing/rules/local` |

## 交叉引用

- 消费方升级 → [consumer-refresh.md](consumer-refresh.md)
- 脚手架 skill → `scaffold` · [scaffold.md](scaffold.md)
- Growth 目录 → `templates/growing/README.md`
