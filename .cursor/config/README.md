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
| `release.mode` | `patch-per-task` | 打版粒度：`patch-per-task`（Sprint 末 ship）· `tag-per-commit`（每 commit + `release-tag`） |
| `role.default` | `professional` | 人格预设 id（见 `config/roles.json`） |
| `role.config` | `.cursor/config/roles.json` | 人格列表；**仅语气，全能** |
| `autonomous.default` | `false` | plan 模板默认是否自治 |
| `autonomous.max_loops_default` | `15` | hooks `loop_limit` 参考 |

### 人格切换（`role.default`）

- 默认 id：`professional`（见 `config/roles.json`）
- **切换**：编辑 `config/workflow.json` → `role.default` 为任意 persona `id`
- **生效**：`run-start` hook 注入 1 行 `hint`；能力不减，只改语气
- **选型**：`/master` → `more` → `style`（12 项分两轮 AskQuestion）

Install profiles（`install-super-cursor.sh --profile`）:

| profile | workflow | hooks |
|---------|----------|-------|
| `full` | enabled | enabled |
| `lite` | enabled | disabled |
| `rules-only` | disabled | disabled |

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

## Templates

- `templates/plan.md` → 复制到 repo root（**`plan.md` 在 .gitignore，不提交**；须含 **`**执行顺序**`** 行）
- `templates/cursorGrowth/` → bootstrap on first prompt

## Local overrides

目标项目可添加 `.cursor/rules/local/`（见 `docs/building-super-cursor.md`），不纳入母版仓库。
