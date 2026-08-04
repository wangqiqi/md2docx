# user-manual · 五段流水线

与具体技术栈无关；变的仅是第 3 段 **Capture Driver**（见 `capture-profiles.md`）。

## 1. 故事线（Storylines）

- 按**角色任务**组织，不按功能目录堆砌
- 每条线：**前提检查 → 分步操作表 → 图号 → 做完应看到什么**
- 模板 → `storyline-template.md`

## 2. 步骤表（Steps）

| 列 | 内容 |
|----|------|
| 前提 | 环境、权限、数据就绪条件 |
| 操作 | 编号步骤，一步一意图 |
| 图 | 与 PNG 文件名 / 图索引 1:1 |
| 期望 | 可观察结果（非实现细节） |

## 3. 截图资产（Capture）

| 契约 | 规则 |
|------|------|
| 禁止 | 骨架屏、无数据空列表（除非故事线专拍空态）、`fullPage` 长尾空白 |
| 推荐 | 内容裁切、步骤目标红框、稳定选器（`data-testid` / role） |
| 命名 | Contract `storylines[].shots[].file` 为 SSOT |
| 中间产物 | Contract `capture.intermediate_dir` |
| 发布副本 | Contract `manual.assets_dir` |

## 4. 同步与嵌入（Sync + Doc）

1. walkthrough 产出 PNG → intermediate
2. `sync_command`（或等价脚本）复制到 `assets_dir`
3. 更新 `manual.doc_path` 内 `![...](assets/...)` 引用
4. 更新图索引表（若有）

## 5. 双层验收（Verify）

| 层 | 内容 | 谁做 |
|----|------|------|
| **L1 机械** | PNG 存在、md 引用路径存在、版本头、锚点 grep | `verify` 脚本 / CI |
| **L2 语义** | Reader Test N 问 | 人 / **review** agent（只读） |

L1 绿 **不** 等于 L2 过。发版档建议两层都做。

## 流水线与测试顺序

```text
unit / integration 绿
  → E2E / walkthrough 绿（行为已锁）
  → [可选] 探索性手测
  → manual capture regen
  → 更新 doc + L1 verify
  → [可选] Reader Test
  → release
```

档位详见 `regen-gates.md`。
