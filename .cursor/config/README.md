# Configuration

Project behavior here — not in rules/skills. Learned knowledge → `.cursorGrowth/` via `/learn`.

## workflow.json

| Key | Default | Purpose |
|-----|---------|---------|
| `profile` | `full` | 安装 profile 标记（`full` · `lite` · `rules-only`） |
| `plan_file` | `plan.md` | Plan path（**gitignore**，本地工作副本） |
| `archive_dir` | `archive` | Sprint 归档目录 |
| `verify_default` | `./scripts/verify.sh` | 全量验收（plan 内 `VERIFY` 元数据可覆盖） |
| `workflow.enabled` | `true` | plan/run SOP |
| `workflow.hooks_enabled` | `true` | run-start / run-stop |
| `growth.enabled` | `true` | growth-init hook |
| `growth.learn_sources` | CHANGELOG, archive, plan | **learn** skill sources |
| `task_id.prefixes_autonomous` | `["TASK-"]` | 常规实现任务前缀 |
| `task_id.prefixes_skip` | `REV-`, `SPIKE-`, `DOC-` | `next-task` 自动选 ⬜ 时跳过（不 bypass gate-check） |
| `task_verify_heuristics.enabled` | `false` | 设为 `true` 时，描述性验收列回退 `./scripts/test.sh` |
| `task_verify_heuristics.fallback_test_script` | `./scripts/test.sh` | 开发任务默认验收 |
| `task_verify_heuristics.fallback_verify_script` | `./scripts/verify.sh` | 含 verify 关键词时回退 |
| `task_verify_heuristics.frontend_test_dir` | `.` | 单仓 scaffold 默认根目录 |
| `task_verify_heuristics.backend_test_dir` | `.` | 单仓 scaffold 默认根目录 |
| `version_line_meta` | `VERSION_LINE` | plan HTML 注释 · 发版版本线 |
| `version_tag_glob_env` | `VERSION_TAG_GLOB` | 环境变量名 · 覆盖 tag 匹配 glob |
| `version_default_env` | `RELEASE_VERSION_DEFAULT` | 环境变量名 · 无 tag 时起始版本 |
| `release.mode` | `patch-per-task` | 打版粒度：`patch-per-task`（Sprint 末 ship）· `tag-per-commit`（每 commit + `release-tag`） |
| `role.default` | `dashu` | 人格预设 id（见 `config/roles.json`；默认油腻大叔语气） |
| `role.config` | `.cursor/config/roles.json` | 人格列表；**仅语气，全能** |
| `autonomous.default` | `true` | plan 模板默认是否自治（**一次 `/run` Sprint 连跑**） |
| `autonomous.max_loops_default` | `15` | hooks `loop_limit` 参考 |
| `autonomous.interrupt_on` | 见 `workflow.json` | 仅这些类型停跑问人（decision · blocker · …） |

### 人格切换（`role.default`）

- 默认 id：`dashu`（见 `config/roles.json`）
- **字段**：`role_name` · `nicknames[]` · `given_name`（**用户点名**，Agent 禁止开场自报）· `voice_cues` · `emotion_cues`（成功/卡住/决策/长跑）· `personality` · `tone` · `attitude` · `intensity` · `speech_examples`（≥4）· `skills`（全员 `full`）
- **辨识度**：靠 `voice_cues` + `emotion_cues` + `tone` + 例句；**不靠** Agent 喊 `given_name`
- **呼叫**：会话内「呼叫 X」→ `resolve-role.sh` → 写 `.cursorGrowth/session/persona.json`；多命中须消歧
- **Growth 覆盖**：可选 `.cursorGrowth/session/aliases.json`（`称呼 → persona_id`）优先于母版 nicknames
- **会话态优先**：`run-start` 读 Growth `session/persona.json` 的 `persona_id`，覆盖 `role.default` 注入 hint
- **持久切换**：编辑 `config/workflow.json` → `role.default` 为 persona `id`（可选）
- **生效**：`run-start` 注入 `id`/`tone`/`voice_cues`/`emotion_cues`/`speech_examples`；能力不减，只改语气
- **选型**：`/master` → `more` → `style`（12 项分两轮 AskQuestion）

Install profiles（`install-super-cursor.sh --profile`）:

| profile | workflow | hooks | 工具技能 week/disk/maintain |
|---------|----------|-------|------------------------------|
| `full` | enabled | enabled | 默认提供（slash + skill；非 plan/run 主路径） |
| `lite` | enabled | disabled | 磁盘上可有；文档不强调为日常必选 |
| `rules-only` | disabled | disabled | 通常不依赖这些 slash |

跨平台：`bash .cursor/bin/platform-check.sh` · 详见 `docs/platforms.md`。

预设文件：`config/profiles/*.json`

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
| `archive_dir` | `.cursorGrowth/archive` |

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

- `templates/plan.md` → 复制到 repo root（**`plan.md` 在 .gitignore，不提交**；须含 **`**执行顺序**`** 行）
- `templates/cursorGrowth/` → bootstrap on first prompt

## Local overrides

目标项目可添加 `.cursor/rules/local/`（见 `docs/building-super-cursor.md`），不纳入母版仓库。
