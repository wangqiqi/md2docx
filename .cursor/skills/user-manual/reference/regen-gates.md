# Regen 门禁 · 与手测档位

## 硬门禁（发版档）

```text
项目 verify / task-verify 全绿
  → 才执行 capture regen
  → sync assets
  → 更新 doc
  → L1 verify 绿
  → [可选] Reader Test
  → release
```

**禁止**在 verify 红时声称「配图已更新」。

## 档位

| 档位 | 何时 | regen | L1 | L2 Reader |
|------|------|-------|-----|-----------|
| **PR 日常** | 功能 PR | 可选跳过 | 查链接/文件存在（若已有图） | 否 |
| **Sprint 收尾** | 功能 Sprint Done | 建议 | 绿 | 建议 |
| **发版** | `/release` §打版前 | **必须** | 绿 | **必须**（或用户明确跳过并记录） |

## 手测前 vs 手测后

| 时机 | 优点 | 缺点 |
|------|------|------|
| **自动化测试绿后、手测前** | 快；CI 可自动 | 手测发现 UI bug 可能废图 |
| **手测后** | 图与叙述最准 | 滞后；需专用 regen job |

**默认（发版档）**：手测后 regen 终版图。  
**默认（Sprint 内）**：测试绿后可 regen 草稿，发版前再跑一次。

## Contract 命令执行顺序

```bash
# 1. 门禁（项目自定）
<verify_command>

# 2. 起栈（若 profile 需要）
<capture.stack_command>

# 3. 走查截图
<capture.walkthrough_command>

# 4. 同步
<capture.sync_command>

# 5. L1
<verify.l1_script>
```

命令真源在 Manual Contract；skill 不硬编码路径。

## 与 release / delivery

| 入口 | 关系 |
|------|------|
| **release** | 发版档触发 manual regen + Reader Test（可选 Done when） |
| **delivery** | 检查 doc↔实现；**不**执行 regen |
| **run** | TASK 验收绿后再 DOC/manual 任务 |

## 失败处理

| 情况 | 动作 |
|------|------|
| walkthrough flaky | 修 wait/选器；≤2 轮自修后 `⚠️` → **plan** |
| 数据无法 seed | contract `shots[].manual: true` · 故事线文字降级 |
| native-window CI 不可用 | 发版机在本地/专用机 regen；CI 只 L1 查文件 |
