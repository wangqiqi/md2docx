---
name: maintain
description: 开发环境维护（关键词 · Linux）：诊断与安全清理，委托 disk 快照对比。说「清理环境」「磁盘清理」「系统维护」时用。
disable-model-invocation: true
---

# maintain · 开发环境维护

**工具技能**（无 slash · 非 plan/run 主路径）。**用这个**：本机诊断/安全清理（Linux）。**不是那个**：业务 refactor；先看占用 → **disk** skill。

诊断与本机安全清理（**Linux**）。快照与对比委托 **disk** skill。

## 何时进入

- 用户说「清理环境」「系统维护」「磁盘满了」「dev maintenance」
- 清理前/后配合 **disk** skill 观察变动
- `/master` 或关键词命中

## 流程

### 1. 诊断（默认）

```bash
.cursor/skills/maintain/scripts/dev-maintain.sh --diagnose
```

### 2. 预览清理

```bash
.cursor/skills/maintain/scripts/dev-maintain.sh --clean --dry-run
```

### 3. 执行清理

```bash
.cursor/skills/maintain/scripts/dev-maintain.sh --clean
# 高风险项（Downloads 旧包、Docker、HF 缓存等）：
.cursor/skills/maintain/scripts/dev-maintain.sh --interactive --clean
```

### 4. 快照对比（推荐包裹清理）

```bash
.cursor/skills/maintain/scripts/dev-maintain.sh --snapshot
.cursor/skills/maintain/scripts/dev-maintain.sh --clean
.cursor/skills/maintain/scripts/dev-maintain.sh --snapshot
.cursor/skills/maintain/scripts/dev-maintain.sh --diff
```

或直接用 **disk** skill / `collect-disk.py`。

## 配置

| 文件 | 用途 |
|------|------|
| `skills/maintain/config/default-protected.json` | 默认受保护目录与缓存列表 |
| `.growing/maintain-config.json` | 本机覆盖（模板 `templates/growing/maintain-config.example.json`） |

`tmp_dev_globs`（默认含 `/tmp/rdm-*`、`cursor-sandbox-cache`、母版 smoke 前缀 `sc-runner-smoke.*` 等）在 `--clean` 时自动清扫开发测试残留；**项目测试栈**若在 `/tmp` 留前缀（embedded DB · 临时 workdir），应：

1. 测例 teardown **stop/删除**临时目录（勿依赖扫尾脚本兜底）；
2. 在 `.growing/maintain-config.json` 的 `build_artifact_tmp_globs` 登记 glob，或通过 `MAINTAIN_BUILTIN_PROTECTED`（`|` 分隔）追加白名单；
3. **勿**把项目专有前缀写进母版 `default-protected.json`（保持 install 通用）。

Playwright 浏览器缓存（`~/.cache/ms-playwright*`）默认在 `protected_dirs`，清理时保留。薄封装可通过环境变量 `MAINTAIN_BUILTIN_PROTECTED`（`|` 分隔路径）追加白名单。

**禁止**在配置中写入个人信息；仅路径与标签。

## 与 disk 的分工

| 工具 | 职责 |
|------|------|
| **maintain** | 诊断 + 可选删除 |
| **disk** | 只读快照 + diff |

## 兼容入口

仓库根 `ubuntu-ai-maintenance.sh`（若存在）为薄封装，委托本脚本。
