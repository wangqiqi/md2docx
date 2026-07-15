# `.cursor` 独立 · 引用审计矩阵

纪律 SSOT → `rules/communication/cursor-standalone.mdc`

## 三层边界

| 层 | 路径 | 角色 |
|----|------|------|
| **母版 SOP** | `.cursor/` | 独立、可演进；**正文不依赖**外网 URL / 根目录叙事 |
| **运行时产出** | `.cursorGrowth/` | plan · learn · archive · session（gitignore） |
| **仓库发版** | 根目录 `CHANGELOG` · `README` | **release** 执行时更新；**.cursor 正文不链** |

## 引用分类

| 类型 | 处理 | 示例 |
|------|------|------|
| **must** Growth 坐标 | 保留；统一 `workflow.json` 键 | `plan_file` · `archive_dir` · `growth.learn_dir` |
| **must** skill 路由 | 保留 | `master/routes.md` · `plan/reference/*` |
| **must** config 键 | 保留 | `release.json` → `changelog_file`（不写「根 CHANGELOG」讲故事） |
| **trim** 根目录 | 改指 config / release skill | training · plan 模板「去看 CHANGELOG」 |
| **trim** 外网 upstream | 内化 `docs/library-index.md` | anthropics · spec-kit MIT 出处 |
| **trim** Growth 文件名 | 只写目录类路径 | 禁止 `archive/SPRINT-xxx.md` |
| **forbid** 外网当操作 SSOT | grep 门禁 | skill 正文 `github.com/anthropics` 链接 |

## Growth 允许指针（精简句式）

```
运行时目录见 config/workflow.json → growth.* / plan_file / archive_dir
产出：learn/ · archive/ · session/（勿链具体文件名）
```

## 可改范围（用户确认）

| 仓库 | Agent 改 `.cursor/` |
|------|---------------------|
| **母版仓库** | ✅ 默认（母版演进 Sprint） |
| **目标项目**（install 后） | ❌ 除非用户明确授权 |

## 文风一致

| 项 | SSOT |
|----|------|
| 行为 + 语气 | `super-cursor-persona.mdc` |
| 引用纪律 | `cursor-standalone.mdc` |
| 外网吸收索引 | `docs/library-index.md` |
| 术语 | 用 **principles**（≠ constitution 三公理）· **ACTIVE** · **Sprint** |
