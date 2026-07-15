# delivery · 清单 §1–7（核心）

### 1. 视觉一致性

- [ ] 字体大小、字重、行高与 design system / 邻近页面一致
- [ ] 颜色来自 token/变量，非 scattered 硬编码（grep `#` · `rgb(` · 魔法数 px 字号）
- [ ] 间距、圆角、阴影与组件库或现有页面一致
- [ ] 响应式/暗色（若项目有）未遗漏

#### 反「AI 默认模板」自检（吸收自 anthropics/skills/frontend-design）

新 UI 或大改视觉时，**build 前**对照（不必单独记 skill；**ux** 分流到交付时自动适用）：

- [ ] 是否落入无 brief 时的三套默认之一：暖奶油底+衬线大标题 / 纯黑+acid 强调色 / 报纸式细线零圆角？若 brief 未要求 → **改一轴**
- [ ] 是否有一个 **signature** 元素（其余保持克制）？
- [ ] 字体配对是否项目特有意图，而非「每次同一套 display+bold」？
- [ ] 动效是否服务主题，而非 scattered 装饰？
- [ ] 文案是否用户视角（「保存更改」非「提交」），错误/空态是否给下一步？

**ux** 用户选「交付/抛光」→ 本小节 + §5 一并走查。

### 2. 国际化（i18n）

> 项目路径/库名 → `.cursorGrowth/learn/acceptance.md`（模板见 `templates/cursorGrowth/learn/acceptance.md`）。

**何时跳过（须在走查报告写明）**：纯内部 CLI/库、无用户可见 UI、或团队书面确认「本版不交付多语言」。跳过 ≠ 忽略：单语产品仍检查**无硬编码散落**与术语一致。

- [ ] 用户可见文案均走 i18n API（`t` / `$t` / `useTranslation` 等）— 有 i18n 栈时
- [ ] 无遗漏字面量（grep 中文/英文 UI 字符串 vs key 文件）
- [ ] 新增 key 在各 locale 文件齐全；无空翻译
- [ ] 日期/数字/复数格式符合 locale
- [ ] 错误/toast/空态文案同样走 i18n（与 `error-context.mdc` 用户可见句对齐）
- [ ] **Acceptance 指针**：改 i18n 库或 locale 目录时，同步更新 `learn/acceptance.md`

### 3. 文档 ↔ 实现（双向）

- [ ] 规格/README/用户文档描述的行为，代码已实现
- [ ] 已实现能力在文档中有对应说明（非仅代码自解释）
- [ ] 冲突 → **`Decision needed`**，等你拍板后再改文档或代码

#### 脚本化 vs 人工（doc-coherence）

| 手段 | 用途 |
|------|------|
| **`docs/scripts/verify_doc_*.sh`**（见 `rules/execution/docs.mdc`） | 断链 · 版本锚点 · 防回退 grep — **可写进 plan 验收列** |
| **本 §3 清单** | 语义完整 · 读者可读 · 冲突上报 |

DOC Sprint 的 Done when：**脚本绿** + delivery §3 **无 Blocker**（若用户可见）。

### 4. 后端对接 · API · 数据

- [ ] 接口文档（OpenAPI/README）**便于后端/前端并行对接**：示例请求/响应、错误码表、鉴权说明齐全
- [ ] 字段、类型、枚举、分页风格完整无歧义
- [ ] 实现与文档一致（跑 **api** skill 子集）
- [ ] DB/schema/migration 与文档一致；**最佳实践**：命名一致、合理范式、必要索引、FK 有意图、nullable 有说明、避免无界 JSON  blob
- [ ] Mock/fixture 与生产 schema 一致
- [ ] 冲突 → **`Decision needed`**

### 5. 组件与交互完整度

#### 导航与 IA（结构层 UX）

> 原则：`rules/execution/ia.mdc` R1–R4 · 项目 `docs/design/*-ia*`（若有）。规划阶段应已走 **ia** skill。

- [ ] 主要页面可一句话说出 **主工作流意图**（无 Dashboard 多工作流并列主 CTA）
- [ ] 角色若有差异：**默认着陆** / 侧栏权重与 RBAC 一致（非人人同一首页叙事）
- [ ] 跨页协作经 **分支点**（深链 / `from` / 来源条），不在 drawer 内嵌无关工作流表单
- [ ] 多步交付类具备可辨识的 **实体上下文**（顶栏或面包屑中的当前对象）

#### 组件与状态

- [ ] 无 TODO/FIXME/placeholder 交互留于生产路径
- [ ] **真实交互感**：操作有即时反馈（hover/focus/disabled/loading）；非静态假按钮
- [ ] 加载/空态/错误态有 UI，非白屏或 `console.log`
- [ ] 表单校验、禁用态、提交反馈完整
- [ ] Dialog/Drawer 非 demo 级（标题、确认、取消、遮罩/ESC 行为符合产品预期）

### 6. 扩展性与维护性

- [ ] 新功能落在正确模块层；未破坏现有分层
- [ ] 改动能用最小 diff 描述；无无关 drive-by 重构（对照 **scope** · **review**）
- [ ] 配置/特性开关（若有）便于扩展

### 7. 生产就绪

- [ ] 无 debug 开关、mock 数据、测试账号残留于生产路径
- [ ] 权限/鉴权与 **security** 要点一致
- [ ] 日志不含 PII/密钥；错误信息对用户友好
- [ ] 与 `./scripts/verify.sh` / 项目 verify 结果一致（已绿）
