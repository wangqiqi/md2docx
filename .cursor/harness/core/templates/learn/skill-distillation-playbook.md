# Skill 蒸馏 playbook（母版 → 产品 bundled Skill）

> 模板：把 `.cursor/skills/` 中的通用 SOP **蒸馏**进宿主产品的 AI Skill 目录。**不是**逐字复制母版全文。

## 何时蒸馏

| 信号 | 动作 |
|------|------|
| 宿主产品内嵌 AI · 需角色化 SOP | 按 tier 分批蒸馏 |
| `.cursor/` 规则已稳定 · 团队仍口头重复 | 优先安全 / 协作三公理 tier |
| 单 Skill 体积过大 · manifest 膨胀 | 瘦核心路由 + 动态 meta 列表 |

## 分批（示例 tier · 按产品裁剪）

| Tier | 典型内容 | 验收（占位符） |
|------|----------|----------------|
| **T0** | constitution / 协作三公理 inject | `verify_bundled_constitution.sh` |
| **T1** | prompt-security | `verify_bundled_prompt_safety.sh` |
| **T2** | security · api · review · debug | `verify_bundled_engineering_review.sh` |
| **T3** | git · test · perf · delivery | `verify_bundled_practice.sh` |
| **T4** | refactor · study · oss-first | `verify_bundled_tooling.sh` |
| **T5+** | ux · manual · report · 扩展域 | `verify_bundled_<domain>.sh` |

## 每个 Skill 最小集

1. `SKILL.md` 或 `reference.md` — **蒸馏**正文（删仓库路径 · 删母版 install 路径）
2. **角色可见性** — 产品自己的 `roles` / ACL frontmatter（勿硬编码母版人格名）
3. **manifest 顺序** — 核心路由 → 宪法/安全 → meta 路由提示 → bundled 列表
4. **verify slice** — 每 Skill 至少一条可执行锚点（短答路径 · 工具预算 · 禁止越权 corpus）

## 禁止

- 把 `.growing/` 或本机绝对路径写进 bundled 正文
- 无 verify slice 就标 tier 闭合
- 只读角色看见写操作 Skill（除非产品刻意开放）

## 闭环

蒸馏完成 → 更新产品路由索引交叉引用 → **telemetry** 观察误路由占比 → 达阈值再 **SPIKE** 前置 classifier（勿无度量直接加分类器）
