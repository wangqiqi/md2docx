# Configuration

Project behavior here — not in rules/skills. Learned knowledge → `.growing/` via `/learn`.

## 本目录文件

| 文件 | 作用 | 由谁校验 |
|------|------|----------|
| `workflow.json` | plan/run 闸门 · 任务 ID · 自治 · SDD · task-verify ·人格默认 | `bin/verify-config.sh`（schema） |
| `release.json` | CHANGELOG 文件 · tag 格式/前缀 · bump 策略 · 版本来源 | `bin/verify-config.sh` |
| `roles.json` | 12 人格预设（**仅语气**，全员 `skills: full`） | `bin/verify-config.sh` |
| `profiles/{full,lite,rules-only}.json` | 安装 profile 的覆盖层（安装时深合并进 `workflow.json`） | `bin/verify-config.sh` |
| **`schema.json`** | 允许的键与类型声明 —— **改 config 先改这里** | `bin/verify-config.sh` |
| **`denylist.txt`** | 母版独立禁用词表（作者标识 · 机器路径 · 公司代号 · 凭据） | `verify-super-cursor.sh` |
| **`docs-layout.json`** | 项目文档体系：`profile` · `slots`（号位=瀑布阶段）· `max_numbered` · 必选号位 | `bin/verify-config.sh` + `bin/verify-docs-layout.sh` |
| **`skill-bundles.json`** | install 时 `--skills-bundle full\|core` 的 skills 子集 SSOT | `bin/verify-config.sh` · `bin/verify-skill-bundles-ssot.sh` · `bin/verify-install-skills-bundle.sh` |

**为什么有 schema**：写错一个键（如把 `release.mode` 写成 `workflow.release.mode`）不会报错，只会**静默回退默认值**，行为与预期不符却毫无信号。`verify-config.sh` 让未知键/类型错误直接 FAIL。

**为什么有 denylist**：「无关用户 · 无关项目 · 无关系统」必须可被门禁守护。新增团队/公司标识 → 追加一行（勿写进 rules/skills 正文）；`verify-super-cursor.sh` 逐行 ERE 扫描 `.cursor/` 全树，删掉该文件即 FAIL。

## workflow.json

| Key | Default | Purpose |
|-----|---------|---------|
| `profile` | `full` | 安装 profile 标记（`full` · `lite` · `rules-only`） |
| `plan_file` | `.growing/plan.md` | Plan path（**gitignore**，本地工作副本；根 `plan.md` 为 legacy，install 会迁入 Growth） |
| `archive_dir` | `.growing/archive` | Sprint 归档目录（域子目录见 growth-layout） |
| `verify_default` | `./scripts/verify.sh` | 全量验收（plan 内 `VERIFY` 元数据可覆盖） |
| `workflow.enabled` | `true` | plan/run SOP |
| `workflow.hooks_enabled` | `true` | run-start / run-stop |
| `growth.enabled` | `true` | growth-init hook |
| `growth.onekey_bootstrap` | `true` | 项目根无 `onekey_start.sh` 时从 `templates/project-onekey/` 复制（不覆盖） |
| `growth.learn_sources` | CHANGELOG, archive, plan | **learn** skill sources |
| `task_id.prefixes_autonomous` | `["TASK-"]` | 常规实现任务前缀 |
| `task_id.prefixes_skip` | `REV-`, `SPIKE-`, `DOC-` | `next-task` 自动选 ⬜ 时跳过（不 bypass gate-check） |
| `task_verify_heuristics.enabled` | `true`（`full`）· `false`（`lite`/`rules-only`） | 描述性验收列回退 `fallback_test_script`（存在才跑） |
| `task_verify_heuristics.fallback_test_script` | `./scripts/test.sh` | 开发任务默认验收 |
| `task_verify_heuristics.fallback_verify_script` | `./scripts/verify.sh` | 含 verify 关键词时回退 |
| `temp_cleanup.enabled` | `true` | 是否启用项目 `/tmp` 契约清理 |
| `temp_cleanup.config` | `.growing/temp-cleanup.json` | 规则文件（Growth · 每项目自填 glob） |
| `temp_cleanup.after_*` | `true` | `test` / `verify` / `task-verify` 成功后跑 ephemeral 规则 |
| `temp_cleanup.sweep_after_verify` | `true` | Sprint `runner.sh verify` 成功后跑 `persistent` 的 `sweep` |
| `temp_cleanup.dry_run` | `false` | 只打印不删 |
| `task_verify_heuristics.frontend_test_dir` | `.` | 单仓 scaffold 默认根目录 |
| `task_verify_heuristics.backend_test_dir` | `.` | 单仓 scaffold 默认根目录 |
| `version_line_meta` | `VERSION_LINE` | plan HTML 注释 · 发版版本线 |
| `version_tag_glob_env` | `VERSION_TAG_GLOB` | 环境变量名 · 覆盖 tag 匹配 glob |
| `version_default_env` | `RELEASE_VERSION_DEFAULT` | 环境变量名 · 无 tag 时起始版本 |
| `release.mode` | `patch-per-task` | 打版粒度：`patch-per-task`（Sprint 末 ship）· `tag-per-commit`（每 commit + `release-tag`） |
| `role.default` | `professional` | 人格预设 id（见 `config/roles.json`；默认中性「专业搭档」，无强风格） |
| `role.config` | `.cursor/config/roles.json` | 人格列表；**仅语气，全能** |
| `autonomous.default` | `true` | plan 模板默认是否自治（**一次 `/run` Sprint 连跑**） |
| `autonomous.max_loops_default` | `15` | hooks `loop_limit` 参考 |
| `autonomous.interrupt_on` | 见 `workflow.json` | 仅这些类型停跑问人（decision · blocker · …） |

### `task-verify` 语义（fail-closed）

`./.cursor/bin/runner.sh task-verify` 按序判定；**描述性验收不再静默通过**：

| 验收列形态 | 行为 |
|------------|------|
| 可执行命令（`./scripts/…` · `npm …` · `pytest …` · `bash …`） | 执行，按其退出码 |
| `manual: <步骤与证据要求>` | **唯一豁免** — 返回 0，须在 plan/CHANGELOG 留证据 |
| 描述性文字 **且** `fallback_test_script` 存在（heuristics 开） | 跑兜底脚本 |
| 描述性文字（其余） | **FAIL + 退出 1**，并提示改成命令或 `manual:` |

验收列写法 → `.cursor/templates/plan.md`。

### 人格切换（`role.default`）

- 默认 id：`professional`（见 `config/roles.json`）
- **字段**：`role_name` · `nicknames[]` · `given_name`（**用户点名**，Agent 禁止开场自报）· `voice_cues` · `emotion_cues`（成功/卡住/决策/长跑）· `personality` · `tone` · `attitude` · `intensity` · `speech_examples`（≥4）· `skills`（全员 `full`）
- **辨识度**：靠 `voice_cues` + `emotion_cues` + `tone` + 例句；**不靠** Agent 喊 `given_name`
- **呼叫**：会话内「呼叫 X」→ `resolve-role.sh` → 写 `.growing/session/persona.json`；多命中须消歧
- **Growth 覆盖**：可选 `.growing/session/aliases.json`（`称呼 → persona_id`）优先于母版 nicknames
- **会话态优先**：`run-start` 读 Growth `session/persona.json` 的 `persona_id`，覆盖 `role.default` 注入 hint
- **持久切换**：编辑 `config/workflow.json` → `role.default` 为 persona `id`（可选）
- **生效**：`run-start` 注入 `id`/`tone`/`voice_cues`/`emotion_cues`/`speech_examples`；能力不减，只改语气
- **选型**：`/master` → `more` → `style`（12 项分两轮 AskQuestion）

Install profiles（`install-super-cursor.sh --profile`）:

| profile | workflow | hooks | 工具技能 week/disk/maintain/code-stats-viz |
|---------|----------|-------|------------------------------|
| `full` | enabled | enabled | 默认提供（slash + skill；非 plan/run 主路径） |
| `lite` | enabled | disabled | 磁盘上可有；文档不强调为日常必选 |
| `rules-only` | disabled | disabled | 通常不依赖这些 slash |

跨平台：`bash .cursor/bin/platform-check.sh` · 详见 `docs/platforms.md`。

预设文件：`config/profiles/*.json`

## skill-bundles.json

**与 `profiles/*` 独立**：profile 只改 `workflow.json` 合并层（hooks · 闸门 · task-verify 启发式）；**skills-bundle** 只在 install 时决定拷贝哪些 `skills/<id>/` 目录。

| 键 | 含义 |
|----|------|
| `default` | 未传 `--skills-bundle` 时使用（**`full`**） |
| `bundles.full` | 母版全量 skills（当前与磁盘 skill 目录数一致） |
| `bundles.core.exclude_skills` | core 安装时**不拷贝**的 skill id 列表 |
| `tools_skills` | 五工具 skill 名单；**必须与** `bundles.core.exclude_skills` **集合相同**（顺序无关） |

| bundle | skills 数（当前母版） | 说明 |
|--------|----------------------|------|
| `full` | 28 | 默认；与历史 install 行为一致 |
| `core` | 23 | 去掉 `week` · `disk` · `maintain` · `ops-deploy` · `code-stats-viz` |

验收：`bash .cursor/bin/verify-skill-bundles-ssot.sh`（JSON ↔ 磁盘）· `bash .cursor/bin/verify-install-skills-bundle.sh`（临时目录 install 冒烟）。**不是** `.cursor-plugin/`（5 lifecycle）轨。

### IDE adaptor 安装（`install-map.example.json`）

| adaptor | 安装根 | 入口 | 验收 |
|---------|--------|------|------|
| `cursor`（默认） | `.cursor/` | `install-super-cursor.sh` | `install-smoke.sh` · `consumer-smoke.sh` |
| `dsh` | `.dsh/` | `install-adaptor-dsh.sh` 或 `install-super-cursor.sh --adaptor dsh` | `verify-install-dsh.sh` |
| `kiro` | `.kiro/` | `install-adaptor-rules-export.sh --adaptor kiro` 或 `--adaptor kiro` | `verify-install-rules-export.sh` |
| `trae` | `.trae/` | `install-adaptor-rules-export.sh --adaptor trae` 或 `--adaptor trae` | 同上（kiro + trae） |
| `opencode` | `.opencode/` | `install-adaptor-opencode.sh` 或 `--adaptor opencode` | `verify-install-opencode.sh` |

布局 → `adaptors/*/docs/layout.md` · `core_rules_export` SSOT → `docs/reference/core-rules-export.md` · 映射 → `install-map.example.json`。

## release.json

| Key | Default |
|-----|---------|
| `changelog_file` | `CHANGELOG.md` |
| `tag_format` | `semver` |
| `tag_prefix` | `v` |
| `annotated_tags` | `true` |
| `tag_per_commit` | `false` | 配合 `release.mode: tag-per-commit` |
| `bump.default` | `patch` | `release-tag` 默认 bump |
| `bump.auto_minor` / `auto_major` | `false` | minor/major 须 `RELEASE_ALLOW_*` |
| `version_source` | plan meta + git tag | `VERSION_LINE` · `VERSION_DEFAULT` · `RELEASE_BUMP` |
| `archive_dir` | `.growing/archive` |

### 发版环境变量（公开）

| 变量 | 用途 |
|------|------|
| `VERSION_TAG_GLOB` | tag 匹配 glob（优先于 plan `VERSION_LINE`；键名见 `workflow.json` `version_tag_glob_env`） |
| `RELEASE_VERSION_DEFAULT` | 无 git tag 时的起始 semver |
| `RELEASE_BUMP` | `patch` · `minor` · `major` |
| `RELEASE_ALLOW_MINOR` / `RELEASE_ALLOW_MAJOR` | 非 patch bump 时须设 |
| `RELEASE_TAG_MSG` | annotated tag message |

### 内部命名（`SC_` · Super Cursor）

| 类别 | 前缀 | 示例 |
|------|------|------|
| Hooks 运行时环境变量 | `SC_` | `SC_PROJECT_ROOT` · `SC_HOOKS_ENABLED` |
| Shell 库函数（`platform.sh` · `runner.sh`） | `sc_` | `sc_python` · `sc_copy_tree` · `sc_config` |

公开文档与用户脚本**仅**使用上表发版环境变量；勿使用人名或旧 `JW_`/`jw_` 前缀。

## Templates

- `templates/plan.md` → 复制到 `.growing/plan.md`（**`.growing/` 在 .gitignore，不提交**；须含 **`**执行顺序**`** 行）
- `templates/growing/` → bootstrap on first prompt

## Local overrides

目标项目可添加 `.cursor/rules/local/`（见 `docs/building-super-cursor.md`），不纳入母版仓库。
