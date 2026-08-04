# 从项目提取与学习 · 优先级

目标：用仓库已有材料**半自动**填 Manual Contract，减少从零编写。

## 提取优先级（高 → 低）

| 序 | 来源 | 提取内容 | 置信度 |
|----|------|----------|--------|
| 1 | 已有 **walkthrough / manual** E2E spec | 页面顺序、wait、选器、角色、PNG 基名 | 高 |
| 2 | **IA / 需求 / 交互** 文档 | 角色、导航、工作流分支、空态说明 | 高 |
| 3 | **OpenAPI / 路由文档** | 用户动作与 API 对应、期望结果 | 中 |
| 4 | **路由表 / 导航组件 / 权限配置** | 页面清单、角色入口 | 中 |
| 5 | **i18n / 可见文案** | 按钮、菜单标签（步骤叙述用） | 中 |
| 6 | **Agent 推断** | 故事线草稿 | 低 · 须标 `inferred: true` |

**冲突**：walkthrough spec 与 IA 不一致 → **`Decision needed`**（文档说法 · 实现 · 建议），不擅自改 spec 或代码。

## 按来源的操作

### Walkthrough spec

```bash
# 示例：找现有走查（项目自定路径）
rg -l 'walkthrough|manual-walkthrough' --glob '*.{ts,js,py,feature}'
```

提取：`test.describe` 顺序 · `loginAs` 角色 · `shot(` 或截图 helper · `data-testid` / `getByRole`。

### IA / 需求文档

grep：角色表 · 侧栏 · 默认首页 · 「空态」「错误」章节。

### 代码（无文档时）

| 层级 | grep 目标 | 产出 |
|------|-----------|------|
| L0 | `routes` · `app/` · `Router` | 页面清单 |
| L1 | `sidebar` · `nav` · `menu` | 导航树草稿 |
| L2 | `role` · `permission` · `RBAC` | 角色槽位 |

产出写入 contract 时 **一律标 `inferred: true`**，直到 Reader Test 通过。

## 最小项目输入（不可省略）

即使全自动提取，项目方仍须确认一次：

1. 故事线大纲（谁完成什么任务）
2. 数据就绪定义（何谓「列表有数据」）
3. 稳定 UI 锚点（否则 capture flaky）
4. 测试身份来源（`env` 或 fixture，非 skill 正文）

缺 (1)(2) → 可生成**空模板手册**；缺 (3) → 可写手册但**不宜**自动化配图。

## 与 plan / delivery 衔接

| 场景 | 动作 |
|------|------|
| 大改版、图 >5 | **plan** Sprint · `DOC-*` |
| 提取 vs 实现冲突 | **delivery** 式 `Decision needed` |
| 推断草稿完成 | 提议 Reader Test（`reader-test.md`） |
