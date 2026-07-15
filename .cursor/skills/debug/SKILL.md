---
name: debug
description: 系统调试循环（/debug）— 复现→假设→隔离→验证→记录；禁止无复现盲改。说「修 bug」「测挂了」「不知道为啥挂」时用。
---

# debug

**用这个**：测挂 / 异常行为 / 要找根因再改。**不是那个**：已知实现任务继续做 → **`/run`**；范围不清要重排 → **`/plan`**；上线走查 → **`/delivery`**。

衔接 `rules/execution/bugfix.mdc`。结论须含 **file:line** 与可复现步骤。

## 铁律

**无根因调查，不提修复。** 禁止无复现、无假设的盲改；symptomatic patch 视为失败。

## 系统循环（按序）

| 步 | 动作 | 完成标准 |
|----|------|----------|
| **1 复现** | 固定步骤 / 最小用例；读完整报错与栈 | 能稳定触发，或明确「不可复现→先采证」 |
| **2 假设** | 1～3 条可证伪原因（含「近期变更 / 环境」） | 写下假设，勿边猜边改 |
| **3 隔离** | 见下节；缩小到单层/单文件 | 证据指向失败边界 |
| **4 验证** | 最小 diff + `task-verify` / 项目 test | 绿且回归不过度 |
| **5 记录** | 用户可见 → CHANGELOG `### Fixed`；流程缺口 → `/learn` | 可审计 |

跨组件（API↔DB、CI↔脚本）时：先在边界打诊断日志，**定位断裂层**再深入，勿多处同时猜改。

## 隔离法

1. 最小复现或补失败测试
2. 注释/禁用可疑块（备份或 stash 思路）
3. 跑 `task-verify` / 项目 test 对比前后
4. 二分缩小范围

## 模式聚类

- 同类报错一批修（同根因别打补丁）
- 区分环境 vs 代码（config、版本、路径）

## Agent 内省调试（Agent 失败 / 越修越乱）

**用这个**：Agent 会话内工具失败、结论自相矛盾、多轮「修了又坏」。**不是那个**：纯应用代码 bug → 上节系统循环；范围重排 → **`/plan`**。

吸收自 SkillsMP `agent-introspection-debugging`（协议 only）。

| 症状 | 常见根因 | 先做什么 |
|------|----------|----------|
| 工具反复报错 | 工具误用、参数/schema 错、无权限 | 读**完整**工具输出；对照 `GetMcpTools` schema；单步重试 |
| 答案与仓库事实不符 | **上下文污染**（旧假设、截断 diff、错文件） | 重新 `Read`/`Grep` 采证；勿沿用未验证结论 |
| 绿测后又挂 / 补丁叠补丁 | **隐式修复环**（symptomatic + 未记录假设） | 停止扩 diff；回到 **1 复现**；列出已改文件与仍失败断言 |
| 同命令第 3 次仍失败 | 环境/路径/沙箱与假设不符 | 打印 `cwd`、实际命令、exit code；对照 `bugfix` Escalation |

**内省循环**（嵌在系统循环内，不跳过复现）：

1. **捕获** — 失败工具调用、用户纠正原话、相关 `file:line`
2. **诊断** — 1～3 条可证伪假设（含「我是否读错文件/漏看 stderr」）
3. **受限恢复** — 最小回滚或单点验证；**禁止**同时改多模块「碰运气」
4. **内省报告**（给用户 3～5 行）— 根因 · 证据 · 已验证修复 · 若仍不确定标 `Decision needed`

流程缺口或重复 Agent 失误 → 提议 **`/learn`** §ERRORS；勿自动改 `.cursor/` 母版。

## Escalation（与 run）

- **`/run` 失败自修 ≤2 轮** → 仍失败：plan 标 `⚠️` → **`/plan`**
- 线上 hotfix：小 diff + CHANGELOG `### Fixed`；仍须先复现/采证
- 同症状 ≥2 已发布 patch → **禁止**第三个 symptomatic hotfix；走 `bugfix` §Follow-up / `SPIKE-*`

## 网络与抓取（任务中 · 非仅 debug）

**用这个**：选工具、处理失败。**不是那个**：UI 走查清单 → **delivery** §10；可回归 E2E → **test**。

| 场景 | 优先 | 失败时 |
|------|------|--------|
| 有明确 URL · 静态页 | `WebFetch` | 说明原因（403/CAPTCHA/空白）；不静默假装成功 |
| 无 URL · 需搜索 | `WebSearch` | 说明无结果或需用户补充关键词 |
| JS 渲染 / 登录 / 交互 | **delivery** §10 或已装浏览器自动化 CLI | 须用户授权登录与敏感操作 |

动态页勿仅用 `WebFetch` 猜内容；网络类结论写进 debug 记录或提议 **learn** §ERRORS。

## 浏览器 E2E 调试（吸收自 anthropics/skills/webapp-testing）

**用这个**：本地 dev server + Playwright 脚本复现 UI 问题。**路由**：写测/起服 → **test** §E2E；上线走查 → **delivery** §10。

| 症状 | 先查 |
|------|------|
| 元素找不到 | 是否 **networkidle 前** 就查 DOM？→ 先 `wait_for_load_state('networkidle')` |
| 间歇失败 | server 未就绪 → **test** `with_server.py` |
| JS 报错 | **test** `examples/console_logging.py` 抓 console |
| selector 不稳 | 侦察：screenshot + `locator().all()`，再改 selector |

脚本路径：`.cursor/skills/test/scripts/` · 先 `--help` 黑盒调用。
