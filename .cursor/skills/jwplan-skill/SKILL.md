---
name: jwplan-skill
description: md2docx 开发规划 skill（入口 /jwplan）：读需求/代码/规格 → 有疑 AskQuestion → 拆 Sprint 写入 plan.md → handoff /jwrun。用户说「规划」「拆任务」「写 plan」「Sprint 规划」或 /jwplan 时使用。禁止顺手写业务代码。
---

# jwplan · 开发规划（skill `jwplan-skill`）

> **入口**：Command **`/jwplan`**（短名）→ 加载本 skill。Command 与 skill 分层，避免同名混淆。

## 目标

把模糊需求变成 **可执行的根目录 `plan.md` Sprint**：任务 ID、优先级、验收、落点、闭合条件、执行顺序。规划完成后交接 **`/jwrun`**（`jwrun-skill`）。

**真源**：根 `plan.md` 管 Sprint 编排；`docs/` 为阅读向技术文档（见 `docs/README.md`）。

## 启动时必读

1. 根目录 `plan.md` 顶部元数据、`## 活跃 Sprint`、`## ROADMAP`
2. 已完成任务见 `archive/plan/*_plan_*.md`，**勿在 plan 重复堆 ✅**
3. 待办与 ROADMAP：根 `plan.md`；文档：`docs/README.md` · `docs/01_架构设计.md` 等
4. 规则：`md2docx-dev-workflow` · `code_quality` · `ci_cd_quality`
5. 代码落点：grep / 读 `src/mddocx/`、`tests/`（**不写实现**）

## 单轮流程（严格顺序）

```
设 PLANNING:true → 理解需求 → 查现状 → 不确定则 AskQuestion → 写 Sprint → handoff 元数据 → 变更记录 → plan-check → 可选 commit → 建议 /jwrun
```

### 0. 规划闸门（第一步必做）

写入 plan 顶部：

```markdown
<!-- PLANNING: true -->
```

多轮规划 session 保持 `true`，防止 `jwrun-skill` 中途切入。handoff 完成后再改 `false`。

### 1. 澄清范围

- 若 ROADMAP 已有大项：在其上拆 Sprint，不重复立项
- 若用户口述新需求：对齐 converter / webui / CLI / 测试分层
- **>5 条 todo 必须先落 plan**，禁止只写在对话里

### 2. 必须用 AskQuestion 的场景

| 场景 | 示例 |
|------|------|
| 范围/优先级不明 | P0 是否含文档项？能否拆到下一 Sprint？ |
| 架构二选一 | 新元素解析策略 A/B？是否 breaking？ |
| 门禁/契约变更 | CLI 参数、输出格式、PyPI 发布是否动？ |
| 外部依赖 | 第三方库升级、CI 变更 |
| Sprint 命名/插队 | 新开 `M-CONV-01` 还是并入活跃 Sprint？ |
| 验收层级不明 | unit / integration 以何为准？ |

**能查代码/文档推断的不要问**；影响闭合条件或 ID 归属的 **必须问**。

问后将决议写入 Sprint 背景或「架构决策」小节。

### 3. 写入 plan.md（Sprint 模板）

```markdown
## 活跃 Sprint · {SPRINT_ID} {主题}

> **WHY** · **参照** · **原则**

**闭合条件**：P0 全部 ✅ · {具体验收} · `pytest -q`

| ID | 任务 | 优先级 | 状态 | 验收 | 落点 |
|----|------|--------|------|------|------|

**执行顺序**：`M-XXX-01` → `M-XXX-02` → ...（完整 ID 或 `01` 短号+SPRINT 前缀）

### 现状（为何做）
### 已具备（不必重复立项）
```

**验收列规范**（提速 `jwrun-skill`）：

- 优先写 **可执行命令**，如 `pytest -q tests/unit/test_cli.py`
- 仅描述时写清关键词（pytest · 测试文件名），`jwrun-skill` 会启发式推断

同步更新：

- `## ROADMAP`：大项标 **活跃** 或移出
- `## 变更记录`：一行 `**{SPRINT_ID} Sprint 规划** · ...`
- 大段已完成 Sprint **归档** `archive/sprint/YYYYMMDD_HHMMSS_功能_模块说明.md`，plan 留链接

### 4. 任务 ID 约定

| 前缀 | 含义 | jwrun 自治 |
|------|------|------------|
| `M-` | 核心转换器 / CLI | ✅ |
| `W-` | WebUI | ✅ |
| `T-` | 测试 | ✅ |
| `D-DOC-` | 文档 | ✅（按需） |
| `D-REV-` | 评审决议 | ❌ 跳过 |

### 5. Handoff 元数据（交接 `jwrun-skill`）

规划确认后 **必须** 写入：

```markdown
<!-- PLANNING: false -->
<!-- SPRINT: M-CONV-01 -->
<!-- PLAN_APPROVED: 2026-06-08 -->
<!-- AUTONOMOUS: false -->
<!-- ACTIVE: M-CONV-01-01 -->
<!-- NEXT: M-CONV-01-01 -->
<!-- VERIFY: pytest -q -->
<!-- VERSION_LINE: 0.4 -->
<!-- MAX_LOOPS: 15 -->
```

- `PLAN_APPROVED`：用户确认或 AskQuestion 决议完毕的 **日期**（`jwrun-skill` 硬闸门）
- `AUTONOMOUS: false` 默认；用户说「开始自治」后由 `jwrun-skill` 改 `true`
- `NEXT` 与「执行顺序」首项一致

handoff 后运行：

```bash
./.cursor/bin/dev_runner.sh plan-check
./.cursor/bin/dev_runner.sh gate-check
```

向用户 summary：Sprint 名、P0 列表、任务数、建议 **`/jwrun`**。

### 6. Git（规划 commit，建议）

```bash
git commit -m "$(cat <<'EOF'
M-CONV-01 Sprint 规划：任务拆分与 handoff。

EOF
)"
```

- 一般**不写** CHANGELOG（除非同步改了规格文档）

### 7. 阻塞回流 · Sprint 后衔接

- `jwrun-skill` 标 `⚠️`：重拆任务或改闭合条件，重新 handoff
- 打版归档后：从 `## ROADMAP` 选下一项，**再次 `/jwplan`**

## 禁止

- 规划时改业务代码
- 跳过 AskQuestion 擅自定架构
- handoff 后仍留 `PLANNING: true` 或无 `PLAN_APPROVED`
- 规划阶段 `AUTONOMOUS: true`

## 命令行辅助

```bash
./.cursor/bin/dev_runner.sh plan-check
./.cursor/bin/dev_runner.sh gate-check
./.cursor/bin/dev_runner.sh next-task
```
