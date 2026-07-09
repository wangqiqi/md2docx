# 跨平台支持

Super Cursor 脚本目标环境：**Linux** · **macOS** · **Windows + Git Bash**。

## 一键自检

```bash
bash .cursor/bin/platform-check.sh
```

安装完成后 install 脚本也会提示运行上述命令。

## 运行环境

| 组件 | Linux | macOS | Windows (Git Bash) |
|------|-------|-------|---------------------|
| bash | ✅ | ✅（系统自带 3.2+） | ✅（Git for Windows） |
| git | ✅ | ✅ | ✅ |
| rsync | ✅ | ✅ | ⚠️ 常需额外安装；无则自动 `cp -a` |
| jq | 推荐 | 推荐（`brew install jq`） | ⚠️ 可选；无则用 **python** |
| python | 回退 | ✅ 通常已有 | ⚠️ 可能是 `python` 而非 `python3` |

共享工具：`.cursor/lib/platform.sh`（ISO 时间戳、目录复制、JSON 读写、Node 栈检测）。

## Cursor Hooks

Hooks 由 Cursor 调用 `.cursor/hooks/*.sh`。在 Windows 上请：

1. 安装 **Git for Windows**（含 Git Bash）
2. 在 Cursor 终端默认 shell 选 **Git Bash**，或确保 `bash` 在 PATH 中
3. 若 hooks 未触发，可改用 `--profile lite`（关闭 hooks，rules/plan/run 仍可用）

## 无 jq 时

| 功能 | 回退 |
|------|------|
| install profile 合并 | python 深合并 |
| hooks config 读取 | python（`config-load.sh`） |
| runner.sh 读 workflow.json | python（`platform.sh`） |
| scaffold CLI / detect | python 或 jq 二选一 |

## 纯 PowerShell / CMD

当前 `.sh` 脚本**不**面向原生 PowerShell。可选：

- 使用 **WSL** 或 **Git Bash**
- 或 `--profile rules-only`（仅 rules/skills，不依赖 runner/hooks）

## WSL

在 Windows 上 **WSL2** 与原生 Linux 行为最接近，推荐用于母版自测与 `runner.sh`：

| 项 | 说明 |
|----|------|
| 路径 | 仓库放在 Linux 文件系统（`~/...`），避免 `/mnt/c/...` 上跑 hooks 变慢 |
| Shell | WSL 内默认 bash；`bash .cursor/bin/platform-check.sh` |
| Git | WSL 与 Windows 各一套 git 时，统一在一侧 commit，避免 CRLF/权限混乱 |
| Cursor | 用 Remote-WSL 打开 WSL 路径，或终端选 WSL 发行版 |
| jq/python | 与 Linux 列一致；`platform.sh` 回退逻辑相同 |

跨 WSL ↔ Windows 复制 `.cursor/` 时用 install 脚本或 `cp -a`，勿混用 PowerShell 手改 shell 脚本行尾。

## 自测

```bash
bash .cursor/bin/platform-check.sh
bash .cursor/verify-super-cursor.sh
bash .cursor/bin/template-verify.sh
```
