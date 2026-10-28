# 跨仓库 UI 参考（项目特化 · 示例）

> **用途**：新后台要对齐已有产品的密度/壳层，但 **不** 引入子模块、不拷贝整包组件库。  
> **路径**：只写工作区外只读路径或内部文档锚点 — **勿**写入母版 `.cursor/`。

## 约束

- 目标栈若禁止新 UI 库（例：仅 React + CSS），只移植 **布局类名语义 · token 角色 · 信息架构**，不搬 antd/MUI 依赖。
- 参考仓的 API path **不得**作为用户可见副标题。

## 记录表

| 目标屏 | 参考来源（只读） | 搬到本项目 |
|--------|------------------|------------|
| `/admin/items` | `…/PageShell.tsx` 标题层级 | 自有 `PageShell`：`title` · `subtitle` · `extra` |
| 列表区 | `…/toolbar + panel` 分区 | `admin-toolbar` / `admin-panel` |
| 术语 | 参考仓中文业务名 | 统一 glossary → `learn/` 或 `docs/` |

## 验收

- delivery §1 视觉 · §5 导航与 IA
- 无新增未声明的第三方 UI 依赖（`package.json` grep）
