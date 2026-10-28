# ZCode `.zcode/` 布局（Super Cursor · `includes: core`）

ZCode 无官方 harness 目录规范；本布局为 Super Cursor **自定约定**，与 `install-adaptor-zcode.sh` 一致。与 Cursor 安装（`.cursor/`）**并存、互不引用、互不影响**；升级母版后对每个消费项目分别重装。

## 目标路径

| 项 | 值 |
|----|-----|
| 安装根 | 目标项目 **`.zcode/`**（ZCode workspace 发现根，`skills/` · `agents/` 在此被自动扫描） |
| Growth | **`.growing/`**（与 Cursor 安装共用，不复制进 `.zcode/`） |
| hooks | **`.zcode/hooks/`**（脚本源自 `adaptors/cursor/hooks`，pack 探测按目录特征，无 Cursor 专有依赖） |
| 指令 | 目标项目根 **`AGENTS.md`**（ZCode workspace 指令文件；已存在则不覆盖，只提示） |

## 目录树（安装后）

```text
.zcode/
├── README.md              # 自 adaptors/zcode/README.md（安装时写入）
├── AGENTS.md              # core 索引（agent↔skill↔rules 地图）
├── config.json            # ZCode workspace 配置：hooks 键（SessionStart/UserPromptSubmit/Stop）
├── skills/                # 28 个 skill（SKILL.md）
├── agents/                # ship · review · spike（frontmatter: name+description，ZCode 原生兼容）
├── rules/                 # .mdc 规则（不含 rules/local；消费方用 .growing/rules/local）
├── bin/                   # runner.sh 等（skills 的运行时入口）
├── lib/ · config/ · templates/ · docs/
└── hooks/                 # run-start.sh · growth-init.sh · run-stop.sh + lib/ + state/
```

## 路径改写（本 adaptor 的关键步骤）

安装时对 `.zcode/` 内全部文本文件（`.md` `.mdc` `.sh` `.json` `.py` `.txt` `.yaml`）执行：

```bash
sed -i 's|\.cursor/|.zcode/|g'
```

- core 的 39 个 skill/agent 文件与 bin/lib 均以 `./.cursor/bin/runner.sh` 等仓库相对路径引用运行时资源；改写后安装副本自洽，**不需要 `.cursor/` 存在**。
- 母版侧 installer/verify 脚本（`bin/install-*` · `bin/verify-*` 等）随树拷贝但仅作留存，在安装副本内本就不运行。
- `sc_cursor_pack_from_dir` 按目录特征（`config/workflow.json` + `rules/`）探测 pack 根，不依赖目录名，`.zcode/` 可被自动识别。

## hooks 映射

| Cursor 事件 | ZCode 事件 | 脚本 |
|-------------|-----------|------|
| `sessionStart` | `SessionStart` | `hooks/run-start.sh`（注入 plan 上下文） |
| `beforeSubmitPrompt` | `UserPromptSubmit` | `hooks/growth-init.sh`（`.growing` 引导） |
| `stop` | `Stop` | `hooks/run-stop.sh`（自治链式推进，`loop_limit` 由 ZCode 侧配置） |

安装器把 `adaptors/zcode/hooks.json`（ZCode 格式）合并进 `.zcode/config.json`；`hooks.enabled` 必须为 `true`（ZCode 配置文件 hooks 默认停用）。

**输出协议翻译**（安装器对 `hooks/lib/json-utils.sh` 追加同签名覆盖）：Cursor 键 `additional_context` → ZCode `additionalContext`（SessionStart 上下文注入）；`followup_message` → `{"decision":"block","reason":…}`（Stop 请求续跑，ZCode 上限 3 次，对应 Cursor `loop_limit`）。

## 与 Cursor 并存的纪律

- `.cursor/` 与 `.zcode/` **互为独立副本**：修通用问题优先改母版 `.cursor/harness/core`，再分别重装两边；**不要**让一边引用另一边。
- `.growing/` 为两工具共用产出区（git 忽略）；`.gitignore` 对 `.zcode/hooks/state/` 与 `.zcode/rules/local` 的忽略口径与 `.cursor/` 一致。
