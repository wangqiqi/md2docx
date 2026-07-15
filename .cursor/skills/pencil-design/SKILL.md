---
name: pencil-design
description: >-
  Pencil CLI 视觉设计（/pencil-design）：用自然语言生成 .pen 设计与 PNG 导出。
  说「做设计」「生成 mockup」「landing page 视觉」「.pen」时也触发。
---

# pencil-design · Pencil CLI 视觉设计

**工具技能**（非 plan/run 主路径）。**用这个**：自然语言 → `.pen` + 导出图。**不是那个**：信息架构/导航 → **ia**；上线验收 → **delivery**；编辑器内改 `.pen` → Pencil MCP（若已装）。

用 **Pencil CLI**（`@pencil.dev/cli`）从描述生成专业视觉设计，输出 `.pen`（结构化 JSON）并可导出 PNG 等。

## 与 Pencil MCP 分工

| 能力 | 入口 |
|------|------|
| **本 skill** | CLI 头less 生成/迭代设计、`pencil --prompt ...` |
| **Pencil MCP**（Cursor 插件） | 已打开的 `.pen` 文件内编辑、节点操作、截图校验 |

## Setup

设计前先确认 Pencil CLI 可用。

### Check installation

```bash
which pencil || npx pencil version
```

未安装时：

```bash
npm install -g @pencil.dev/cli
```

全局安装因权限失败时，改为项目本地：

```bash
npm install @pencil.dev/cli
```

之后用 `npx pencil`（或 `./node_modules/.bin/pencil`）代替 `pencil`。`pencil --help` 可查子命令。

### Authentication

#### Pencil user

CLI 需要已登录的 Pencil 用户。先执行 `pencil status` 查看本机状态。

未登录可选：

- `pencil signup --email you@example.com --username johndoe --name "John Doe"` 注册
- `pencil login --email you@example.com [--code abc123]` 登录
- 或设置环境变量 `PENCIL_CLI_KEY`

#### Claude Code agent

CLI 内置 AI 设计 agent 依赖 Claude Code 鉴权（环境变量或订阅）。若均不可用，向用户说明选项并协助配置。

### Staying up to date

本 skill 与 npm 包 `@pencil.dev/cli` 同步；母版当前收录 **0.2.8**（`docs/library-index.md`）。

**检查版本**

- Registry 最新：`npm view @pencil.dev/cli version`
- 本机：`pencil version`，或 `npm list -g @pencil.dev/cli` / `npm list @pencil.dev/cli`

**升级 CLI 后**（agents 不会自动更新已拷贝的 skill 文件）：

```bash
npm install -g @pencil.dev/cli
curl -fsSL "https://unpkg.com/@pencil.dev/cli@latest/SKILL.md" -o .cursor/skills/pencil-design/SKILL.md
```

也可用 `node_modules/@pencil.dev/cli/SKILL.md`（全局/本地安装路径相同）。

**何时检查**：会话内首次设计前比对一次；用户升级 CLI 或行为与文档不符时再查。不必每条命令都查。

## Creating a Design

核心命令：

```bash
pencil --out <output.pen> --prompt "<design description>" --export <output.png> --export-scale 2
```

常用 flags：

- `--out, -o` — `.pen` 输出路径（必填）
- `--prompt, -p` — 设计描述（必填）
- `--prompt-file, -f` — 附加参考图/文本（可重复）；不是从文件读 prompt 正文
- `--export, -e` — 导出图片
- `--export-scale` — 分辨率倍数（建议 2）
- `--export-type` — `png`（默认）· `jpeg` · `webp` · `pdf`
- `--in, -i` — 基于已有 `.pen` 迭代
- `--model, -m` — Claude 模型（默认 Opus）

### Passing the Prompt

**原样传递**用户请求，不要自行扩写配色/版式/字体。CLI 内有独立设计 agent；你多加细节会与其判断冲突、效果变差。

用户说「给咖啡店做个 landing page」，prompt 就应是这句话，不要自己编 hero、色板、字体段落。

### Timing Expectations

生成非即时 — CLI 会规划布局、创建元素并视觉校验。预期：

- **简单**（卡片、单组件）：1–2 分钟
- **中等**（App 屏、落地页区块）：2–3 分钟
- **复杂**（完整落地页、详细仪表盘）：3–5+ 分钟

提前告知用户需等待数分钟。执行命令时 timeout 至少 **600000ms（10 分钟）**。

### Showing the Result

命令完成后读取导出图片展示给用户：

```bash
pencil --out design.pen --prompt "..." --export design.png --export-scale 2
```

用 Read 工具打开 PNG（多模态可渲染）。**务必**把图给用户看 — 这是交付重点。

## Iterating on a Design

要改已有设计，用 `--in` 载入原 `.pen`：

```bash
pencil --in design.pen --out design-v2.pen --prompt "Make the header larger and change the accent color to green" --export design-v2.png --export-scale 2
```

agent 会在原稿上修改，而非从零开始。

迭代命名建议：

- `design.pen` → `design-v2.pen` → `design-v3.pen`
- 或单文件覆盖：`--in design.pen --out design.pen`

## Working Directory

设计文件放在用户当前工作目录或 `designs/` 等子目录。**不要**用临时目录 — 用户后续还要找文件迭代。
