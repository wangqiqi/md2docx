# Manual Contract · 字段说明

**SSOT**：每项目一份；母版 skill 只认字段名，不写具体值。

## 落点（读取顺序）

1. `config/manual.yaml`（可提交 · 适合 CI regen）
2. `.cursorGrowth/learn/user-manual.md`（gitignore · Agent 会话友好）
3. 均无 → AskQuestion 起草 · 模板 `templates/manual-contract.example.yaml`

## 顶层结构

```yaml
manual:      # 文档元数据
capture:     # 环境与截图驱动
roles:       # 角色槽位（非真人名）
storylines:  # 故事线与 shot 列表
verify:      # L1/L2 验收
```

## `manual`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 手册标识（如 `user-guide`） |
| `doc_path` | string | 相对仓库根的 Markdown 路径 |
| `assets_dir` | string | 配图发布目录（doc 内相对引用） |
| `version` | string | 手册版本（与 doc 顶栏同步） |
| `audiences` | string[] | 读者角色槽位 id |

## `capture`

| 字段 | 类型 | 说明 |
|------|------|------|
| `profile` | enum | `web-fullstack` · `web-spa-only` · `electron` · `flutter` · `native-window` |
| `stack_command` | string? | 起依赖环境（API、DB、dev server） |
| `walkthrough_command` | string | 产出 intermediate PNG |
| `sync_command` | string? | intermediate → assets_dir |
| `intermediate_dir` | string | walkthrough 输出目录 |
| `env` | map? | 传给 walkthrough 的环境变量键名（值从 env 读，不写 secret 进仓库） |

## `roles[]`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 槽位 id（如 `admin` · `operator`） |
| `auth` | `env` \| `fixture` | `env` → `MANUAL_AUTH_<ID>_EMAIL` 等；`fixture` → globalSetup 生成 |
| `default_route` | string? | 登录后首页（用于 shot 顺序） |

**禁止**在 contract 写真实人名；演示账号仅 `env` 或本地 fixture（gitignore）。

## `storylines[]`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 故事线 id |
| `title` | string | 展示标题 |
| `audience` | string? | 目标 `roles[].id` |
| `duration_min` | number? | 培训时长估计 |
| `inferred` | bool? | `true` = 从代码推断，须 Reader Test |
| `shots[]` | list | 见下 |

### `shots[]`

| 字段 | 类型 | 说明 |
|------|------|------|
| `file` | string | PNG 文件名（含扩展名） |
| `step` | number? | 步骤序号（分步图） |
| `highlights` | string[] | 选器 / role / 原生 overlay 矩形 id |
| `manual` | bool? | `true` = 禁止自动 regen，须人工补图并登记 |

## `verify`

| 字段 | 类型 | 说明 |
|------|------|------|
| `l1_script` | string? | 机械验收脚本路径 |
| `reader_test` | string? | Reader Test 清单路径或 `reference/reader-test.md` |
| `anchors` | string[]? | L1 grep 关键词（项目填，母版不写） |

## 示例

见 `.cursor/templates/manual-contract.example.yaml`。
