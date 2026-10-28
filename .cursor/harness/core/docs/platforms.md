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

## 技能平台作用域

上表描述的是**母版脚本层**（install · runner · hooks · verify）。**技能**另有自己的作用域，二者不可互相推断：

| 技能 | 作用域 | 依据 |
|------|--------|------|
| **maintain** | **仅 Linux（Ubuntu / Debian）** | 依赖 `apt` / `dpkg` / `journalctl` / systemd；脚本内 `require_linux` 在非 Linux 直接 `exit 3`，不静默降级 |
| **disk** | 跨平台 | 纯 python 采集 HOME 与可配置路径（`config/default-paths.json`），无平台专属命令 |
| **ops-deploy** | 跟随目标栈 | 只生成 / 校验 compose · env · nginx 约定，自身不依赖宿主平台 |
| 其余技能 | 跨平台 | 仅读写文件 + 调用 `.cursor/bin/*`（母版脚本层已三平台自检） |

约束：**技能若含 `require_linux`，必须在本表登记**。由 `bash .cursor/bin/verify-portability.sh` 断言（文档声明 ⇔ 代码实际），避免"README 说三平台、技能却只跑 Linux"这类漂移。

## Shell 命名与 verify 并行

| 规则 | 说明 |
|------|------|
| **勿用 Bash 内置数组名** | 如 `BASH_CMDS` · `FUNCNAME` · `GROUPS` · `PIPESTATUS` — 赋值/`+=` 会与内置冲突（曾导致 `[verify] manifest:` 为空）。用项目前缀，例：`MANIFEST_BASH_CMDS`。 |
| **门禁** | `bash .cursor/bin/verify-portability.sh` 对母版 `*.sh` **FAIL** 命中上述名字。 |
| **manifest 并行** | `run-manifest-tier.sh` 用 `xargs -0 -n 1` 传整条 command；勿 `xargs -I{} bash -c … {}`（除非行内 `portability-allow: xargs-I`）。 |
| **勿用 `mapfile`** | bash 4+ 才有；macOS 系统 bash 3.2 会直接语法错误。用 `while IFS= read -r` + 临时文件或 here-string。 |
| **`cursor-coherence` 勿用 process substitution** | Windows Git Bash 上 `done < <(cmd)` 不可靠；用 `mktemp` 重定向。`verify-portability` 对该脚本 **FAIL** `< <(`。 |
| **packaged rules 列表** | 母版门禁统一 `sc_find_packaged_rules_mdc`（`lib/platform.sh`），**排除** `rules/local`（项目私有 · 示例可 `alwaysApply`）。 |

verify-layers 细节 → bundle 内 `README-verify-layers.md`。

## Cursor Cloud · MCP

可选 **`.cursor/mcp.json`** · **`.cursor/environment.json`** 模板与复制说明 → **`cursor-cloud.md`**。密钥走 Dashboard / `${env:…}`，勿写入母版模板。

## Cursor Hooks

配置：`.cursor/hooks.json`（`version: 1`）· 脚本路径相对**项目根** → `.cursor/hooks/*.sh`（勿写 `./hooks/`）。

### 母版已接线（本地 IDE）

| 事件 | 脚本 | 作用 |
|------|------|------|
| `beforeSubmitPrompt` | `growth-init.sh` | Growth 引导 |
| `sessionStart` | `run-start.sh` | plan 元数据 · Persona 注入 |
| `stop` | `run-stop.sh` | 自治 Sprint followup（`AUTONOMOUS`） |

`full` profile 默认启用；`lite` / `rules-only` 可关 hooks，闸门与 Sprint 仍可用（见 `config/profiles/`）。

### Cloud Agents parity

| 项 | 本地 IDE | Cloud Agents |
|----|----------|--------------|
| 仓库 `.cursor/hooks.json` | ✅ command hooks | ✅ **仅 command**（同上路径） |
| `~/.cursor/hooks.json` | ✅ 用户级 | ❌ VM 无本机 home |
| Prompt hooks | 视版本 | ❌ 不用 prompt 型 |
| 探索期只读环境 | — | hooks **尚未**运行；可写环境后才执行 |
| 企业 | — | 可叠加团队/企业托管 hooks |

Cloud 不读 `.growing/plan.md`；验收命令写进 `environment.json` 的 `install` 或 PR 说明。详 **cursor-cloud.md** · 官方 **hooks**（Cloud agent support 矩阵）。

### Tab hooks（IDE · 默认未启用）

与 Agent hooks **分开策略**：`beforeTabFileRead` · `afterTabFileEdit` 管 Tab 补全读/写文件，**不**走 `run-start` / `run-stop` 链路。

| 决策 | 母版 |
|------|------|
| 默认 | **不**写入 `hooks.json`（避免 Tab 与 Sprint 闸门耦合） |
| 敏感仓 | 可自行加 Tab hook（审计/脱敏）；脚本须快、幂等、无密钥出网 |
| 参考键名 | `beforeTabFileRead` · `afterTabFileEdit`（官方 Hooks 文档） |

### Windows 本地

1. 安装 **Git for Windows**（含 Git Bash）
2. Cursor 终端默认 **Git Bash**，或确保 `bash` 在 PATH
3. hooks 未触发 → `--profile lite`（关闭 hooks，rules/plan/run 仍可用）

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
bash .cursor/verify-super-cursor.sh    # 混合仓自动 hybrid，纯母版空仓为 mother
bash .cursor/bin/cursor-coherence.sh   # 安装后项目优先
bash .cursor/template-verify.sh    # 纯母版全量（混合仓亦可用）
bash .cursor/bin/consumer-smoke.sh     # 目标项目端到端（仅母版仓）
SC_FORCE_PYTHON=1 bash .cursor/template-verify.sh   # 强制 python JSON 回退（无 jq 路径）
# Windows（Git for Windows）：先确认行尾 —— 应为 LF，否则脚本不可执行
git config core.autocrlf   # 建议 false；或依赖仓库根 .gitattributes（已强制 eol=lf）
```

`verify-portability.sh` 静态守护上面的跨平台承诺（GNU-only 构造 · 非 POSIX 正则 · 硬编码 `python3` · shebang · 裸 `ln -s` · `relative_to()` 未归一 · **行尾策略**）。

### 平台专属坑（都已修复并有护栏）

| 平台 | 坑 | 症状 | 护栏 |
|------|----|------|------|
| **macOS**（系统 bash 3.2） | `set -u` 下展开**空数组** `"${arr[@]}"` | `arr[@]: unbound variable` → 脚本中止（bash 4.4+ 才把它当空展开） | 一律写 `${arr[@]+"${arr[@]}"}`；`verify-portability` 拦截由 `"$@"` 填充的数组未守卫展开 |
| **Windows** | Python 文本模式把 `\n` 写成 `\r\n` | `sc_manifest_ids` 的输出被 `read` 读成 `react-vite-ts\r` → `[[ -d ]]`／字符串比较失败（CI 报 `missing dir`） | python 助手 `sys.stdout.reconfigure(newline="\n")`；消费点 `${var%$'\r'}` 兜底剥离 |
| **Windows** | Python stdout 默认 cp1252 | python 块打印中文即 `UnicodeEncodeError` 崩溃 | `platform.sh` 导出 `PYTHONIOENCODING=utf-8` + `PYTHONUTF8=1`；用 python 的脚本必须 source 平台库或自行导出（静态断言） |
| **Windows** | `core.autocrlf=true` 把 `*.sh` 检出为 CRLF | `#!/usr/bin/env bash\r` → 脚本**秒退无报错** | 仓库根 `.gitattributes` 强制 `eol=lf`；门禁断言其存在且含 `eol=lf` |
| **Windows** | `str(path.relative_to(root))` 返回 `rules\x.mdc` | 与 POSIX 字面量比较**全不中** → 大批误报 | 一律 `.as_posix()`；门禁静态拦截未归一的写法 |
| **Windows / Git Bash** | 无符号链接权限时裸 `ln -s` | `set -e` 下**直接中止安装/自检** | 安装脚本降级为目录副本（含 README）；门禁要求 `ln -s` 带 `2>/dev/null`/`||`/`if` |
| **Windows / Git Bash** | bash **process substitution** `< <(` | `plan-check` / scaffold 在 CI 偶发失败 | `runner.sh` · `scaffold.sh` · `scaffold-integrity.sh` 用 **mktemp 重定向**；`verify-portability` 静态拦截 |

**CI 矩阵**（`.github/workflows/verify.yml`）：ubuntu（+jq，含文档构建）· macos（BSD 工具链 / bash 3.2）· windows（Git Bash，**非阻塞观察中**）。无 jq 的分支用 `SC_FORCE_PYTHON=1` 覆盖——因为 macOS runner 自带 jq，"runner 上恰好没有 jq"不可靠。

混合仓（业务树 + `.cursor/`）：`verify-super-cursor` 对纯母版 layout 项 **SKIP**，不 FAIL。强制空仓标准：`SC_VERIFY_LAYOUT=mother`。
