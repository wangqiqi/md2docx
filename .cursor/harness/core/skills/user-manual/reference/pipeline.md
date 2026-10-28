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
| 图 | 实机截图 → PNG 文件名；示意图 → 图号 + doc 内 Mermaid 锚点 |
| 期望 | 可观察结果（非实现细节） |

## 3. 示意图（Diagram · Mermaid）

**适用**：数据流、角色分工、状态机——**无**对应可拍 UI，或拍屏反而更乱。

| 契约 | 规则 |
|------|------|
| **载体** | 正文 ` ```mermaid ` 代码块 + 图号标题（如「图 8 · …」） |
| **不进** | `storylines[].shots` · walkthrough · `assets_dir`（默认） |
| **索引** | 配图索引表标明「Mermaid 示意图 · §x.x」 |
| **预览** | GitHub / 文档站为准；多段 Mermaid 在部分 IDE 预览会叠画——单节阅读或链 `docs` 图示说明 |
| **禁止** | 无 CJK 字体的 CLI 导出 PNG 当交付物（方框乱码） |

须导出静态图（PDF/印刷）时：**单独**建字体完备的 `mmdc` 流水线，或人工设计稿；**不**混入 capture regen。

## 4. 截图资产（Capture）

| 契约 | 规则 |
|------|------|
| 禁止 | 骨架屏、无数据空列表（除非故事线专拍空态）、`fullPage` 长尾空白 |
| 推荐 | 内容裁切、步骤目标红框、稳定选器（`data-testid` / role） |
| 命名 | Contract `storylines[].shots[].file` 为 SSOT |
| 中间产物 | Contract `capture.intermediate_dir` |
| 发布副本 | Contract `manual.assets_dir` |

## 5. 同步与嵌入（Sync + Doc）

1. walkthrough 产出 PNG → intermediate
2. `sync_command`（或等价脚本）复制到 `assets_dir`
3. 更新 `manual.doc_path` 内 `![...](assets/...)` 引用
4. 更新图索引表（若有）

## 6. 双层验收（Verify）

| 层 | 内容 | 谁做 |
|----|------|------|
| **L1 机械** | capture PNG 存在、md 引用路径存在、Mermaid 锚点 grep、版本头 | `verify` 脚本 / CI |
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
