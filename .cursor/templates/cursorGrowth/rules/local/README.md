# Local rules（项目特化）

**Canonical 路径**：`.cursorGrowth/rules/local/`（随 `.cursorGrowth/` gitignore）。

安装后 `.cursor/rules/local` 通常为**符号链接**指向本目录，以便 Cursor 按 glob 加载 `.mdc`。

- 公司命名、内部路径、团队 globs 等 **项目特化** rules 放这里
- **delivery** 通用清单在 **delivery** skill；路径约定优先 `/learn` → `learn/acceptance.md`
- **勿**把 rules 写进 `.cursor/rules/` 其他目录（母版只读）

示例：

```
.cursorGrowth/rules/local/
  naming.mdc
  internal-api.mdc
```

社区 rules 索引 → `.cursor/docs/rules-catalog.md`（安装后路径）。
