# Capture Profiles

Contract `capture.profile` 选择驱动；母版只写接入模式，不写项目命令。

## 总表

| profile | 驱动 | Playwright？ | 典型场景 |
|---------|------|-------------|----------|
| `web-fullstack` | Playwright + live/mock API 栈 | ✅ 首选 | B/S · SPA + 后端 |
| `web-spa-only` | Playwright + dev server / mock | ✅ | 无后端或静态演示 |
| `electron` | Playwright `_electron` 或 CDP | ✅ | Electron 壳 |
| `flutter` | `integration_test` + `takeScreenshot` | ❌ | Flutter desktop/mobile |
| `native-window` | 系统窗口截图 + 可选坐标红框 | ❌ | MFC · Qt · 自绘 GUI |

**分流**：可访问树/DOM → Playwright 系；仅窗口像素 → `native-window`。

---

## web-fullstack

| 项 | 要点 |
|----|------|
| 环境 | `stack_command` 起 API + migrate/seed + 前端 dev server |
| 数据 | globalSetup 写 fixture JSON；禁止骨架屏配图 |
| 等待 | 每 shot 前 wait 业务就绪（非固定 sleep） |
| 红框 | 页面注入 overlay · `boundingBox` 批量坐标 |
| 裁切 | 按 shell（顶栏/侧栏/主区）+ highlight 并集，禁 `fullPage` |
| CI | `webServer` 或 ops 脚本；headless 可行 |

Walkthrough **目标**是 PNG 资产，可与 **test** E2E 共用 spec，但须独立 `testMatch` 或 project 以免与冒烟混淆。

---

## web-spa-only

同 `web-fullstack`，但：

- 可无 `stack_command`；用 mock Service Worker / fixture JSON
- 数据真实性不足时：故事线降级为文字 + 旧图，contract 标 `manual: true`

---

## electron

| 项 | 要点 |
|----|------|
| 启动 | Playwright `electron.launch({ args })` 或打包 binary + CDP 端口 |
| 红框/裁切 | 复用 Web 层 helper（若 UI 为 Web） |
| 原生菜单/对话框 | 降级 `native-window` 或 `shots[].manual: true` |

详操作随项目 Electron 版本；母版不绑具体 API 名。

---

## flutter

| 项 | 要点 |
|----|------|
| 工具 | `integration_test` · 非 Playwright |
| 截图 | `binding.takeScreenshot()` 或 golden 工具 |
| 红框 | `CustomPaint` / `RepaintBoundary` 或后处理叠框 |
| 移动端 | Patrol 等（项目自选） |

**Flutter Web** → 改用 `web-spa-only`。

---

## native-window（系统 screenshot 兜底）

用于 MFC、Win32、Qt、自绘 Canvas 等**无稳定可访问树**的 GUI。

### 可行性

| 优点 | 缺点 |
|------|------|
| 与 UI 框架无关 | 无元素级红框（需坐标表或后处理） |
| 实现快 | 焦点/时序/DPI/多屏 fragile |
| 可拍任意窗口 | CI 需显示栈（xvfb 等） |

### 平台中立 CLI 模式（示例形态 · 非绑定）

| 平台 | 模式 |
|------|------|
| macOS | `screencapture -x -o <out.png>`（窗口需前台） |
| Linux X11 | 聚焦窗口后 `scrot -u <out.png>` 或 `import -window root` |
| Linux Wayland | `grim` / 合成器工具（项目实测选用） |
| Windows | Win32 `PrintWindow` / PowerShell 脚本（项目封装） |

### 推荐最小自动化

1. 脚本启动应用 + 导入 fixture（CLI/API 若有）
2. 按**固定快捷键或窗口标题**导航到目标屏（脆弱 · 文档注明）
3. 系统截图当前窗口
4. 可选：`overlay_rects`（contract 或 learn 登记像素矩形）→ ImageMagick 画框
5. 复制到 `assets_dir` · L1 verify 查文件存在

### 红框降级

| 方式 | 适用 |
|------|------|
| Contract `shots[].highlights` 存归一化矩形 | 分辨率固定时 |
| `shots[].manual: true` | 人工补图 + 红框 |
| 后处理脚本 | 维护成本中等 |

### CI 注意

- 无头环境须虚拟显示（如 xvfb-run）
- 勿假设默认 DPI；发版档在固定分辨率机 regen
- flaky 高于 Playwright → 发版档人工抽检一张

---

## 与 test skill 分工

- **test**：断言行为对错
- **user-manual**：同一 walkthrough 可驱动两边；manual 侧允许更长 wait、更大 PNG、serial 模式
