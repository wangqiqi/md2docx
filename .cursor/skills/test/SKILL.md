---
name: test
description: 测试清单 — 单测、集成、E2E、TDD 红绿重构；衔接 verify。说「写测试」「TDD」「Playwright」时用。
---

# test

验收优先 plan 列命令；无列则用项目 `./scripts/test.sh` 或 stack 默认。测试文件细则 → `rules/execution/testing.mdc`。

## TDD 短环（功能 / bugfix）

1. **红** — 写失败测试（或复现用例），运行确认失败
2. **绿** — 最小实现使测试通过
3. **重构** — 在绿测保护下整理；不扩 scope

与 **run** 一致：红测不 ✅ task · 须实际运行 `task-verify`。

## Factory 与 mock（单测 · 集成）

吸收自 SkillsMP `testing-patterns`（协议 only；栈细则仍看 `rules/execution/testing.mdc`）。

| 手法 | 何时用 | 要点 |
|------|--------|------|
| **Factory** | 实体/DTO 构造重复、字段组合多 | 默认值 + 每测只覆盖差异字段；避免 20 行 arrange |
| **Test double** | 外部 I/O、时钟、随机、网络 | 优先接口边界注入；单测不真连 DB/HTTP（除非集成层） |
| **Mock（函数/模块）** | 断言「被调用方式」或隔离慢依赖 | mock **行为**而非实现细节；一个测试一个主要 mock 面 |
| **Stub** | 只需固定返回值、不关心调用次数 | 比 mock 更简单时用 stub/fixture 数据 |

**纪律**：

- Arrange 用 factory · Act 一行 · Assert 聚焦一个行为
- 不过度 mock 被测对象自身（测实现而非契约时换集成测）
- 异步：await 断言 + 假定时器须 `vi.useFakeTimers` / jest fake timers 等栈等价物
- 与 **debug** 配合：先红测复现，再 mock 缩小面，最后绿测锁回归

## 层级

| 类型 | 何时 |
|------|------|
| 单元 | 纯逻辑、utils、hooks |
| 集成 | API、DB、模块边界 |
| E2E | 关键用户路径（Playwright/Cypress 若项目已有） |

Walkthrough 若用于**说明书配图**（非仅冒烟）→ 与 **user-manual** skill 对齐 Manual Contract；行为断言仍在本 skill。

全量/发版 **测试报告**（汇总 verify · 非写用例）→ **test-report** `/report` · Report Contract。

## 验收脚本分层（verify-layers）

**层定义真源**：`rules/feedback/verify.mdc` §分层验收（L0–L3）。本 skill **不重复**该表。

- 新功能域：**优先** L1 进 `task-verify`；L3 进 Sprint Done when 或 nightly
- 红测停在 L1 即可标 🔧；**勿**为 ✅ 跳过 L1 直接跑 L3
- 项目路径坐标 → Growth `learn/`（如 `dev-conventions.md`），**勿**写进 `.cursor/`；聚合脚本仅编排（见 verify.mdc）

## Playwright / E2E（若栈具备）

- 测行为与可见结果，非 DOM 实现细节
- 本地：`npx playwright test` 或项目 script
- 先起 dev server 或使用 `webServer` 配置

### 本地 Web 应用 E2E（吸收自 anthropics/skills/webapp-testing）

**脚本**：`scripts/with_server.py`（起停 dev server）· `scripts/examples/`（Playwright 示例）  
**许可**：`scripts/LICENSE-anthropics.txt`  
**依赖**：`pip install playwright` · `playwright install chromium`

**黑盒纪律**：先 `python .cursor/skills/test/scripts/with_server.py --help`，**勿**把脚本源码读入上下文。

**决策树**：

```
任务 → 静态 HTML？
  ├─ 是 → 直接读 HTML 找 selector → 写 Playwright（见 examples/static_html_automation.py）
  └─ 否（动态）→ server 已起？
        ├─ 否 → with_server.py 起服 + 你的 automation.py
        └─ 是 → 侦察再行动：goto → networkidle → screenshot/DOM → 再操作
```

**侦察再行动**（动态 SPA）：

1. `page.wait_for_load_state('networkidle')` — **必须先等**
2. screenshot 或 `page.locator(...).all()` 探 selector
3. 用发现的 selector 执行操作

**多服**（前后端分离）：

```bash
python .cursor/skills/test/scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python your_automation.py
```

与 **debug** 配合：UI 挂时抓 console（`examples/console_logging.py`）· 先 networkidle 再断言。

## 纪律

- 红测不 ✅ task
- 新 bug 优先补回归
- 与 **debug** skill 配合：复现 → 绿测 → 提交
