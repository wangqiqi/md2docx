---
description: 【生命周期】空项目脚手架 / 已有项目 audit（须确认后 apply）
---

加载 skill **scaffold**：

```bash
./.cursor/bin/scaffold.sh detect
./.cursor/bin/scaffold.sh list
```

1. **空仓库** → AskQuestion 选栈 → `--dry-run` 预览 → 确认后 `apply`
2. **已有代码** → `audit`；默认不覆盖，须用户确认
3. 完成后 → **`/learn`** → **`/plan`** → **`/run`**

**禁止**未确认静默覆盖；复杂改造走 **`/plan`** 拆 TASK。
