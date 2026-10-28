# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.73] - 2026-10-28

### Fixed

- **质量**：修复 `quality` 任务 mypy（`cover` · `footnote_manager` 类型注解）

## [0.5.72] - 2026-10-28

### Changed

- **质量**：black 26 格式化（image · footnote_manager · preview_docx · batch · 相关测试）
- **dev**：`black>=26.10.0`，与 CI `quality` 任务一致

## [0.5.71] - 2026-10-28

### Changed

- **CI**：矩阵改为 Python 3.10–3.12（GitHub Runner 已不提供 3.8/3.9）；`requires-python >=3.10`
- **GitHub Actions**：checkout/setup-python/setup-node v7、codecov v7、deploy-pages v5（合并 Dependabot 提议）
- **质量**：修复 flake8（cover · batch · test_template_convert）

## [0.5.70] - 2026-10-28

### Added

- Mermaid **journey** 与 **erDiagram**（ER 图）经 mermaid.ink 渲染嵌入 DOCX（SPRINT-MERMAID-01 / P-MERMAID-01）
- `tests/samples/advanced/flowcharts.md` 用户旅程与 ER 样例 · 单测/集成测

## [0.5.69] - 2026-10-28

### Added

- WebUI **版式预览** · `POST /preview/docx`（Markdown → DOCX → mammoth HTML）（SPRINT-PREVIEW-01 / P-PREVIEW-01）
- `preview_docx.py` · `scripts/verify_webui_docx_preview.sh` · 依赖 **mammoth**

## [0.5.68] - 2026-10-28

### Added

- WebUI 可选 **Word 模板** 上传（`template` 字段）· 单文件与批量转换（SPRINT-STYLE-03 / P-STYLE-01 片 3）
- `scripts/verify_webui_template.sh` · `webui/template_upload.py`

## [0.5.67] - 2026-10-28

### Added

- **YAML front matter**（`title` · `author` · `date` · `cover`）文首 `---` 块剥离后转换
- **`cover: true`** 封面页（Title/Subtitle + 分页符）；与 **`--template`** 兼容（SPRINT-STYLE-02 / P-STYLE-01 片 2）
- `tests/samples/style/cover_front_matter.md` · `scripts/verify_cover_convert.sh`

### Changed

- `cover: true` 与 **chunked** 分块互斥（fail-closed，同 `template_path`）

## [0.5.66] - 2026-10-28

### Added

- **参考式链接** `[text][id]` + `[id]: url` → Word 超链接（CommonMark · 与脚注共存）
- `tests/samples/quality/pandoc_quality.md` · `test_reference_links.py`（SPRINT-QUAL-03 / P-QUAL-01 片 3）

### Fixed

- 段落内链接前的空格被误删（`TextConverter` · 影响 inline 与参考式链接）

## [0.5.65] - 2026-10-28

### Added

- **`--template`** / `template_path` — 以 `.docx` · `.dotx` 为基底转换，保留页眉页脚与样式（SPRINT-STYLE-01）
- `tests/samples/templates/minimal_company.docx` · `scripts/verify_template_convert.sh`

### Changed

- `template_path` 与自动 **chunked** 分块互斥（fail-closed）

## [0.5.64] - 2026-10-28

### Added

- Markdown **脚注**（`[^id]` / `[^id]:`）→ DOCX `word/footnotes.xml`（`FootnoteManager` · `footnote_plugin`）
- 段落 **`[TOC]`** → Word TOC 域（`converter/toc.py`）
- quality 样例 `footnotes_quality.md` · `toc_quality.md` 与回归测试（SPRINT-QUAL-02 / P-QUAL-01 片 2）

## [0.5.63] - 2026-10-28

### Added

- `tests/samples/quality/` 与 `test_quality_regression.py` — 深嵌套列表、表格空单元格/对齐/单元格内联（P-QUAL-01 片 1）

### Fixed

- 表格单元格内联：`<br>` 换行、`` `code` ``、粗斜体与删除线样式（`TableConverter`）

## [0.5.62] - 2026-10-28

### Added

- `scripts/check_npm_audit.sh` — VitePress 文档站 npm 依赖审计（critical 硬失败 · 官方 registry）
- CI job **`docs-security`**；Pages 工作流在构建前 **`npm audit`**

### Changed

- `package-lock.json`：`npm audit fix`（source-map-js）
- `SECURITY.md` · 开发/CI 文档 · README 对齐 npm 与 pip 双门禁

## [0.5.61] - 2026-10-28

### Changed

- CI `quality`：`METRICS_SOFT=0`，ConvertMetrics 耗时回归与结构同为硬失败（SPRINT-METRICS-02 / P-PERF-02）
- `verify_release_candidate.sh` 默认 `METRICS_SOFT=0`；`docs/guide/development.md` · `ci-cd.md` · README 对齐

## [0.5.60] - 2026-10-28

### Added

- `.github/dependabot.yml`：weekly 更新 pip · GitHub Actions · npm（VitePress）
- `scripts/check_pip_audit.sh`：干净 venv 复现 CI 的 `pip-audit` 门禁
- 根目录 `SECURITY.md`：漏洞报告渠道与支持版本

### Changed

- CI `quality` job：`pip install -U pip setuptools wheel` 后运行 `pip-audit`（SPRINT-SEC-01）
- `[dev]` 可选依赖增加 `pip-audit`；`docs/guide/ci-cd.md` · `development.md` · README 对齐

## [0.5.59] - 2026-10-28

### Fixed

- 图片 LRU 缓存维护 `_image_cache_bytes`，淘汰时不再每次 `sum()` 全表（TASK-007）

### Changed

- `BaseConverter` 共享 `RenderCache`，Math/Mermaid 共用同一 LRU（TASK-008）
- CLI · MCP · `batch_convert` 与 WebUI 对齐 `converter_pool` 线程内复用（TASK-009）
- WebUI 预览共用 `get_converter().md`；预览请求支持 AbortController 取消过期 fetch（TASK-011 · TASK-012）
- `TokenProcessor` 在 `BaseConverter` 上复用实例（TASK-017）
- 批量转换可选并行：`batch_convert --jobs N` · `build_batch_zip(..., jobs=N)` 默认 1（TASK-016）
- README 收束无实现的「实时项目分析」表述；Super Cursor 协作说明（TASK-013）
- `docs/guide/development.md` §7：已实现缓存/复用清单 · metrics 门禁 · 大文件读入说明（TASK-010 · DOC-018）

## [0.5.58] - 2026-10-28

### Changed

- 自 **cursor-ai** 母版同步 Super Cursor **v5.0.7** 布局（`harness/core` + adaptors · `install-super-cursor.sh --replace`）
- 本地 Growth 目录由 `.cursorGrowth/` 迁移为 **`.growing/`**（plan · archive · learn；仍 gitignore）；`workflow.json` · README · docs 指针对齐
- 新增 `.cursorignore` · `.gitattributes` · 根目录 `onekey_start.sh`（Growth onekey 引导）

## [0.5.57] - 2026-09-29

### Fixed

- CI `mypy (standalone modules)`：`tomli` 是 `python_version<'3.11'` 的条件依赖，在 3.11 上缺失导致门禁失败；`mypy.ini` 放行 `tomli` 与可选 extra `mcp`
- `mypy.ini` 的 `python_version = 3.9` 已不被新版 mypy 支持（降级为警告），改为 3.10；3.8/3.9 兼容由 CI 测试矩阵保证

## [0.5.56] - 2026-09-29

### Added

- VitePress 中文文档站（`docs/` + `npm run docs:dev` / `docs:build`），部署至 GitHub Pages：<https://wangqiqi.github.io/md2docx/>
- `scripts/verify_docs_site.sh` 文档站构建验收脚本
- `.github/workflows/pages.yml`：`main` push 自动构建并发布 Pages
- `RenderCache`：Mermaid / LaTeX 渲染结果 LRU 缓存（同一文档重复图表只请求一次）
- `security.fetch_remote_bytes()`：受限远程下载器，逐跳校验 URL 并关闭自动重定向
- WebUI 线程局部转换器复用（`webui/converter_pool.py`），省去每请求重建解析器与 13 个转换器
- `ElementConverter.reset_state()`：转换器跨文档状态重置钩子

### Changed

- 原 `docs/01–07_*.md` 迁入 `docs/guide/`；根 README 与 CONTRIBUTING 指向在线文档站
- WebUI 单文件与批量转换改为内存 `BytesIO` 直出，去掉临时文件中转与 `call_on_close` 清理
- `BaseConverter._reset_state()` 统一调用各转换器的 `reset_state()`（列表编号、表格样式等不再跨文档残留）
- README 测试基线与 CI Python 版本对齐实际构建
- CI 矩阵恢复为 3.8–3.12，并按 Python 版本条件安装 `[mcp]` extra（`mcp` 要求 Python ≥3.10）
- mypy 门禁从 converter + 2 个模块扩展到 11 个模块（`cli` / `mcp` / `webui` / `config` 补齐注解）
- WebUI 内容限额改按 UTF-8 字节数统计，与转换器 `MAX_MARKDOWN_BYTES` 口径一致
- CI actions 升级：`checkout@v5` / `setup-python@v5` / `cache@v4` / `codecov-action@v4`
- `logging.basicConfig()` 从 import 期移到 `main()`，避免 import 本包时产生全局日志副作用

### Fixed

- 分块转换（>512KB）会把代码围栏内以 `# ` 开头的行误判为一级标题，撕裂围栏导致渲染错乱
- SSRF：远程图片 / Mermaid / 公式下载未校验重定向目标，可被 302 绕过直达内网或云元数据地址
- 图片缓存只有条目数上限（64 × 10MB = 最坏 640MB），现按 LRU + 64MB 总字节上限淘汰
- 限流字典的客户端 key 永不回收，现超过跟踪上限后清理窗口已过期的条目
- 图片加载失败静默返回空段落，现写入可见的「图片加载失败」提示
- 渲染结果校验过弱：任意 ≥100 字节二进制都算图片，现改为按魔数白名单（PNG/JPEG/GIF/TIFF/BMP/WEBP）判定
- `requirements.txt` 指向的 `requirements-dev.txt` 缺失（断链）；`requirements-prod.txt` 漏 `mdit-py-plugins`（数学公式 ImportError）
- README 架构文档链接指向已迁移的 `docs/01_架构设计.md`
- `.gitignore` 未忽略本地编排目录 `.dsh/`
- `mypy` 门禁在 `python_version = 3.9` 下因 `tomllib` 缺失而误报，`mypy.ini` 放行该 import
- 打包用例真实访问 PyPI 且未配重试，一次读超时就会让发布门禁假红；现加 `PIP_DEFAULT_TIMEOUT` / `PIP_RETRIES`
- `scripts/verify_release_candidate.sh` 的运行时版本检查未把 `src` 加入 `sys.path`，升版后会命中环境里的旧安装而假红

## [0.5.55] - 2026-09-08

### Fixed

- CI：Black 格式化 `src/mddocx/mcp/server.py`（`ImportError` 消息隐式字符串拼接）

## [0.5.54] - 2026-09-08

### Fixed

- CI：`test_samples_output_verify` 对 Mermaid/LaTeX 外网 mock，避免 mermaid.ink 抖动；flowcharts 验收改为统计 Mermaid 图注（DOCX 会合并相同 PNG）

## [0.5.53] - 2026-09-08

### Added

- 可选 MCP 服务：`pip install mddocx[mcp]`（Python ≥3.10）· 命令 `mddocx-mcp` · 工具 `convert_md_to_docx` / `convert_md_file_to_docx`

## [0.5.52] - 2026-07-10

### Fixed
- CI：修复 3 项 pytest 失败——本地图片测试仅用本地片段（避免在线图触发 `requests.get`）；`output/` 可选验收在无预生成 docx 时 skip；`HtmlToDocx` 单测在无 `[html]` 可选依赖时 skip
- `test_batch.py`：补 `from __future__ import annotations`，修复 Python 3.8 CI 收集阶段 `dict[str, bytes]` 报错

## [0.5.51] - 2026-07-10

### Fixed
- CI：对齐脚本与单测改用 `tomli` 回退，修复 Python 3.8–3.10 无 `tomllib`；忽略 `GITHUB_REF_NAME=master` 误当 tag
- 发布工具链：`scripts/pyproject_util.py` 统一读取 `pyproject.toml`（Python 3.8+）

## [0.5.50] - 2026-07-10

### Added
- `scripts/verify_release_alignment.sh`：CI / publish 门面一致性门禁（version · README · CHANGELOG · license · tag）

### Changed
- `publish.yml` / `ci.yml`：发版前自动跑对齐门禁

## [0.5.49] - 2026-07-10

### Added
- `scripts/verify_release_candidate.sh`：发布候选一键预检（测试/质量/构建/隔离安装/PyPI 碰撞提示）（E-RELREADY-01）
- ConvertMetrics **性能基线**：`tests/baselines/convert_metrics.json` + `scripts/collect_convert_metrics.py`（E-METRICS-01）
- `scripts/check_convert_metrics.sh`：结构字段硬失败；耗时相对阈值（默认 soft，防 CI 抖动）
- CI `quality`：调用 ConvertMetrics 门禁
- html / mermaid 元素转换器单测补强，行覆盖 **≥99%**（E-COV-01）
- WebUI 批量转换：多文件上传、阶段进度与 ZIP 下载；失败项写入 `batch_errors.json` 并在结果面板展示结构化错误（P-WEBUI-01）

### Changed
- `docs/02_开发指南.md`：补充基线更新步骤与失败解读
- WebUI 单文件错误提示拆分为可读的 `[E_*]` 错误码与说明
- README：工程候选对齐；测试基线 **321**
- 版本单一真源：`pyproject.toml` 为权威版本；运行时从源码树或 distribution metadata 读取；MIT `license = {text = "MIT"}`
- wheel 不再打包 `mddocx/webui/tests`；新增 `tests/unit/test_packaging.py` 门禁
- `docs/06_发布流程.md`：补充 `verify_release_candidate.sh` 预检步骤
- CI 质量门禁：修复 flake8 / black 回归（E-RELREADY-01）

### Fixed
- `pyproject.toml`：`license = {text = "MIT"}` 兼容 Python 3.8 CI 旧版 setuptools 的 `pip install -e`（避免 SPDX 字符串在 setuptools<77 下失败）
- packaging 测试：断言 license table 格式，并在 `setuptools<70` 下验证 `pip install -e`

## [0.5.48] - 2026-07-10

### Added
- `scripts/verify_pypi_version.sh`：核对 PyPI 上 `mddocx` 是否已发布指定版本（E-PUB-01）
- `publish.yml`：Trusted Publisher 成功后自动核对 PyPI 版本（含有限重试）

### Changed
- `docs/06_发布流程.md`：补充发布后 PyPI 核对步骤与失败含义
- README：版本徽章与测试基线对齐 **v0.5.47** / **278**；「规划中」指向本地 `.cursorGrowth/ROADMAP.md`（D-FACADE-01）
- `docs/README.md`：补充活路线图指针（`.cursorGrowth/ROADMAP.md`，不入库）
- 删除根目录 `审查.md`（审查 ROI 已全部闭合；全文迁入 `.cursorGrowth/archive/`）
- 根目录 `archive/` 合并迁入 `.cursorGrowth/archive/`（含历史 `sprint/`；本地 gitignore）

## [0.5.47] - 2026-07-09

### Added
- `ConvertMetrics` / `BaseConverter.last_metrics`：转换耗时、输入字节、是否分块的程序可读出口（ARCH-R03）
- CLI `--debug` 打印 metrics 快照；docs/02 · docs/04 字段约定

## [0.5.46] - 2026-07-09

### Changed
- `mypy.ini`：启用 `disallow_untyped_defs`；移除 elements 放宽项（M-MYPY-02）
- `converter/elements` 与 `token_processor.process` 补齐类型注解

## [0.5.45] - 2026-07-09

### Changed
- `审查.md`：C/M/m/S 标注已闭合并链 `archive/sprint/`；开放项对齐 ROI 候选 **M-MYPY-02** · **ARCH-R03**（DOC-REV-01）

## [0.5.44] - 2026-07-09

### Changed
- 文档指针：Sprint 真源由根 `plan.md` 改为 `.cursorGrowth/plan.md`（README · docs · 审查）

## [0.5.43] - 2026-07-09

### Fixed
- 对齐 `black`/`isort` 行宽为 120（`pyproject.toml` `[tool.black]`），消除互相覆盖导致的 CI quality 失败
- 全库 `src`/`tests` 按 black + isort 重新格式化

## [0.5.42] - 2026-06-09

### Changed
- `plan.md` 退出 git 跟踪（`.gitignore` 保留，本地 jwplan/jwrun 真源）
- README / docs 说明 `plan.md` 为本地开发编排，不入库

### Fixed
- 样例验收脚本 `black`/`isort` 格式化，修复 CI quality job 风险

## [0.5.41] - 2026-06-09

### Added
- 样例 DOCX 程序化验收：`sample_output_checks.py` · `test_samples_output_verify.py`（16 passed）
- `scripts/verify_samples_output.py`：fresh / output / 对比三种验收模式

### Fixed
- `tests/samples/basic/1.png` 替换为 Pillow/docx 可嵌入的合法 PNG（修复实装导出无图）

## [0.5.40] - 2026-06-09

### Added
- T-TEST-03-05：`docs/03_测试指南.md` · `samples/output/README` 同步 259 passed 与样例结构

## [0.5.39] - 2026-06-09

### Added
- T-TEST-03-03：`flowcharts.md` 增补 `flowchart LR` 关键字样例

## [0.5.38] - 2026-06-09

### Added
- T-TEST-03-02：`test_convert_image_sample_embeds_local_png` 验证 `image.md` 本地图嵌入
- T-TEST-03-04：`math.md` `\label`/`\ref` 样例级断言（式号 (5)）
- T-TEST-03-06：`tests/samples/large/chunked.md` + `test_convert_chunked_sample`

## [0.5.37] - 2026-06-09

### Added
- T-TEST-03-01：`tests/samples/basic/1.png` 最小合法 PNG，补全 image.md / tables.md 本地图引用

## [0.5.36] - 2026-06-09

### Added
- M-MERMAID-03：支持 **stateDiagram** / **classDiagram** / **pie** 经 mermaid.ink 渲染
- M-MERMAID-03：状态图 / 类图 / 饼图中文说明标签

### Changed
- M-MERMAID-03：README / 架构 / 样例说明同步；FEAT-03 闭合

## [0.5.35] - 2026-06-09

### Added
- M-MATH-02：块级公式自动编号 `(1)(2)…`；`equation_labels` registry
- M-MATH-02：`$$…\label{eq:id}…$$` 注册标签；正文 `\ref{eq:id}` → `(N)` / `(?)`

### Changed
- M-MATH-02：CodeCogs 请求前剥离 `\label`；README / 审查 / 架构文档同步

## [0.5.34] - 2026-06-09

### Added
- M-MERMAID-02：Mermaid **sequenceDiagram** 时序图与 **gantt** 甘特图经 mermaid.ink 渲染嵌入
- M-MERMAID-02：图表类型中文说明（流程图 / 时序图 / 甘特图）

### Changed
- M-MERMAID-02：README / 架构文档同步；pie 等类型仍回退源码

## [0.5.33] - 2026-06-09

### Added
- M-PERF-01：`MAX_MARKDOWN_BYTES`（16MB）与 `CHUNKED_THRESHOLD`（512KB）体积常量
- M-PERF-01：`BaseConverter.convert_file(Path)` 流式计大小后读取
- M-PERF-01：按一级标题 `# ` 分块 parse + `TokenProcessor`（`chunked` 参数 / 自动触发）

### Changed
- M-PERF-01：CLI 改用 `convert_file`；超限映射 `E_CONTENT_TOO_LARGE`
- M-PERF-01：`02_开发指南` 补充大文件与分块策略说明

## [0.5.32] - 2026-06-09

### Changed
- T-TEST-02-01：更新 `03_测试指南.md` 覆盖率基线（218 passed · 85% 目标）
- T-TEST-02-02：实现图片集成测（本地/远程/错误处理，替换占位符）
- T-TEST-02-03：`html.py` 单元测补强（87% 覆盖率）
- T-TEST-02-04：CLI/errors 测补强，整体覆盖率 **85%**
- T-TEST-02-05：README / 审查.md 测试数字与 REV-P2-05 同步

## [0.5.31] - 2026-06-09

### Changed
- M-DOC-05：docs 扁平化为 `01_架构设计`–`07_版本工作流`；删除 `docs/plan.md`（根 `plan.md` 为真源）
- M-DOC-05：新增 `docs/README.md` 阅读索引；全仓链接扫尾（README · `.cursor/` · webui · 审查.md）
- M-DOC-05：移除 `docs/implementation/` 子目录

## [0.5.30] - 2026-06-09

### Changed
- M-MINOR-01-01：WebUI 预览启用 dollarmath，与 BaseConverter 插件对齐
- M-MINOR-01-02：ConvertError 保留异常类型名与 `__cause__` 链
- M-MINOR-01-03：移除 WebUI 测试冗余 `sys.path`；核验 MIN-02/03/04 已闭合

### Added
- 预览 dollarmath 集成测 · ConvertError 类型保留单测

## [0.5.29] - 2026-06-09

### Changed
- M-MYPY-01：converter 包 strict mypy（`DocxDocument` 类型、`doc` 属性、elements 全量修复）
- M-MYPY-01：移除 `mypy.ini` 中 `converter.*` 的 `ignore_errors`；CI 纳入 `mypy src/mddocx/converter`

## [0.5.28] - 2026-06-09

### Changed
- M-DOC-04-02：webui README 默认 HOST 127.0.0.1、CSRF/限流说明、pyproject 安装方式
- M-DOC-04-03：`docs/development.md` 移除 requirements.txt，修正模块路径
- M-DOC-04-04：README 版本 badge v0.5.26、199 测试、路线图更新
- M-DOC-04-05：`docs/architecture.md` 补充 token_processor/errors/rate_limit · v0.5.x 阶段
- M-DOC-04-06：`docs/plan.md` 与根 plan ROADMAP 同步

## [0.5.27] - 2026-06-09

### Changed
- jwplan 全量台账：根 `plan.md` 写入审查/M-ARCH 残余/Minor/测试/文档 22 项待办
- jwrun §7B：Sprint 闭合须刷新 plan 审计快照（skill/command/docs 同步）
- `docs/plan.md` / `docs/architecture.md`：收窄产品范围，移除双向转换与插件远期项
- M-DOC-04-01：[`审查.md`](审查.md) 行动计划 P0/P1/P2 checkbox 与 plan 台账同步

### Removed
- `scripts/test_roundtrip_demo.py`：与单向 MD→DOCX 定位不一致的闭环演示脚本

### Chore
- `.gitignore` 忽略本地编排 `plan.md`（已跟踪文件仍保留版本历史）
- 立项 **M-DOC-04**（文档与审查清单同步 Sprint）

## [0.5.26] - 2026-06-09

### Changed
- M-ARCH-01-08：TokenProcessor 轻量提取（base.py 220 行）

## [0.5.25] - 2026-06-09

### Changed
- M-ARCH-01-07：mypy.ini + CI 新模块类型检查

## [0.5.24] - 2026-06-09

### Added
- M-ARCH-01-06：Dockerfile 与 docs/api.md 部署说明

## [0.5.23] - 2026-06-09

### Changed
- M-ARCH-01-05：CONTRIBUTING 强调 pre-commit 必装

## [0.5.22] - 2026-06-09

### Added
- M-ARCH-01-04：WebUI per-IP 请求限流（30 req/min）

## [0.5.21] - 2026-06-09

### Added
- M-ARCH-01-03：转换结构化日志（duration_ms / input_bytes）

## [0.5.20] - 2026-06-09

### Changed
- M-ARCH-01-02：任务列表 Word checkbox 内容控件，失败回退 Unicode


## [0.5.19] - 2026-06-09

### Added
- M-ARCH-01-01：统一错误码模块，CLI/WebUI `[CODE]` 一致消息

## [0.5.18] - 2026-06-08

### Changed
- M-HTML-01-04：文档更新 html-for-docx 可选依赖说明（testing.md / README）

## [0.5.17] - 2026-06-08

### Added
- M-HTML-01-03：`HTML_FOR_DOCX_AVAILABLE` 测试与 `html.md` 集成测

## [0.5.16] - 2026-06-08

### Changed
- M-HTML-01-02：`HtmlConverter` 改用 `HtmlToDocx.add_html_to_document()`，移除临时文件路径

## [0.5.15] - 2026-06-08

### Changed
- M-HTML-01-01：`mddocx[html]` 可选依赖由停更 `html2docx` 换为 `html-for-docx>=1.1.0`

## [0.5.14] - 2026-06-08

### Added
- M-MATH-01-04：集成测试与 README

## [0.5.13] - 2026-06-08

### Added
- M-MATH-01-03：CodeCogs 白名单与失败回退

## [0.5.12] - 2026-06-08

### Added
- M-MATH-01-02：CodeCogs PNG 渲染嵌入

## [0.5.11] - 2026-06-08

### Added
- M-MATH-01-01：dollarmath 与 MathConverter 骨架

## [0.5.10] - 2026-06-08

### Added
- T-TEST-01-07：同步 testing 文档与 samples/output 基线（176 passed）

## [0.5.9] - 2026-06-08

### Added
- T-TEST-01-06：BaseConverter token 路由边界单测

## [0.5.8] - 2026-06-08

### Added
- T-TEST-01-05：html2docx 可选依赖与 skip 策略文档化

## [0.5.7] - 2026-06-08

### Added
- T-TEST-01-04：CLI `--lang en` 帮助端到端断言

## [0.5.6] - 2026-06-08

### Added
- T-TEST-01-03：WebUI 连续转换 DOCX 内容独立性断言

## [0.5.5] - 2026-06-08

### Added
- T-TEST-01-02：集成测试增强标题与结构断言

## [0.5.4] - 2026-06-08

### Added
- T-TEST-01-01：advanced 样例与 test.md 纳入集成测试

## [0.5.3] - 2026-06-08

### Added
- M-MERMAID-01-04：Mermaid 集成测试与 README 使用说明

## [0.5.2] - 2026-06-08

### Added
- M-MERMAID-01-03：mermaid.ink URL 白名单、渲染失败回退源码块

## [0.5.1] - 2026-06-08

### Added
- M-MERMAID-01-02：mermaid.ink 渲染 graph/flowchart PNG 并嵌入 DOCX

## [0.5.0] - 2026-06-08

### Added
- M-MERMAID-01-01：`MermaidConverter` 骨架与 `fence` 按 `info=mermaid` 路由

## [0.4.10] - 2026-06-08

### Fixed
- M-CONV-01-02：`ConvertError` 使用 `from e` 保留原始异常链（审查 m1）

## [0.4.9] - 2026-06-08

### Fixed
- M-CONV-01-01：引用块支持链接、删除线、行内代码（审查 m2）

## [0.4.8] - 2026-06-08

### Changed
- M-DOC-03-04：`docs/api.md` Docker 部署标注为规划中，移除占位命令

## [0.4.7] - 2026-06-08

### Changed
- M-DOC-03-03：修正 README 发布节、批量脚本名与 pytest 全量路径

## [0.4.6] - 2026-06-08

### Changed
- M-DOC-03-02：更新 `docs/testing.md` 导入路径与 WebUI/CI 测试说明

## [0.4.5] - 2026-06-08

### Changed
- M-DOC-03-01：更新 `docs/architecture.md` 项目结构（mddocx 包 · webui · security.py）

## [0.4.4] - 2026-06-08

### Added
- jwplan/jwrun 开发闭环：`.cursor/` skills · commands · hooks · `dev_runner.sh`
- 根目录 `plan.md` 作为 Sprint 编排真源；`archive/` 本地归档区（不入库）
- 代码审查报告 `审查.md`

### Fixed
- 🔧 **转换器状态复用**：`BaseConverter.convert()` 每次调用前重置文档与内部状态，修复 WebUI 多次转换内容累积问题
- 📦 **依赖补全**：添加 `requests`、`bleach`、`flask-wtf` 至项目依赖
- 🛡️ **图片安全**：本地图片路径校验防路径遍历；远程图片 SSRF 防护与大小限制
- 🐛 **CLI 修复**：删除重复的 `parse_args()` 调用
- 🔒 **WebUI 安全**：预览 HTML 消毒（bleach）、CSRF 防护、CSP 安全头
- ⚙️ **配置优化**：开发环境默认监听 `127.0.0.1`；`start_webui.py` 读取配置

### Changed
- 🧪 **测试增强**：WebUI 测试纳入 CI；新增安全与状态复用测试
- 📝 **文档修正**：更新 README、`docs/api.md` 安全说明与项目结构

## [0.4.3] - 2026-06-08

### Fixed
- 版本号与 README 徽章同步

## [0.4.2] - 2025-12-26

### Added
- 🎨 **CLI帮助信息增强**：添加详细的项目描述、功能列表、使用示例和项目链接
- 🌍 **多语言支持**：CLI支持中文和英文帮助信息 (`--lang zh/en`)
- 📋 **版本信息显示**：CLI支持 `--version`/`-v`/`-V` 参数显示版本信息
- 🔗 **项目链接集成**：在帮助信息中集成GitHub主页、文档和问题反馈链接

### Changed
- 📦 **包名重命名**：由于PyPI名称冲突，从 `md2docx` 更改为 `mddocx`
- 🛠️ **命令名更新**：CLI命令从 `md2docx` 更改为 `mddocx`，WebUI从 `md2docx-webui` 更改为 `mddocx-webui`
- 💡 **帮助示例修正**：更新帮助信息中的命令示例为正确的包名

### Fixed
- 🧹 **代码清理**：移除未使用的导入，提升代码质量
- 🔧 **Entry Points修复**：修正CLI entry points路径，确保命令正常工作
- 📄 **依赖文件整理**：统一requirements文件结构和内容

## [0.4.0] - 2025-12-26

### Added
- 🚀 **自动化发布系统**：集成GitHub Actions和PyPI Trusted Publisher，实现自动发布
- 🏗️ **CI/CD工作流**：添加完整的持续集成和持续部署流程
- 🔧 **代码质量工具**：集成pre-commit hooks，提升代码质量
- 📦 **包管理优化**：改进MANIFEST.in和requirements文件结构
- 🧪 **测试体系完善**：新增边界条件、错误处理和大文件测试
- 📚 **项目文档体系**：添加API文档、开发指南和项目规划文档
- 🎨 **WebUI界面重构**：全新的现代化Web界面设计
- ⚡ **性能优化**：实时预览、防抖优化和响应式设计
- 🛡️ **安全增强**：文件验证、HTTP安全头和错误处理

### Changed
- 🔄 **项目结构重组**：优化包结构，提高可维护性
- 📋 **依赖管理优化**：分离生产和开发依赖
- 🎯 **界面交互优化**：改进用户体验和响应速度

### Fixed
- 🐛 **兼容性修复**：解决各种环境下的兼容性问题

## [0.3.0] - 2025-12-26

### Added
- 🎨 **一次性阅读体验**：WebUI页面无需滚动即可完整查看
- ⚡ **防抖优化**：实时预览响应延迟优化到800ms，提升性能
- 🛡️ **安全加固**：完善文件验证、错误处理和HTTP安全头
- 📱 **响应式设计优化**：改进移动端和平板适配
- 🔧 **配置管理系统**：新增外部化配置支持，支持环境切换
- 🧪 **WebUI测试套件**：添加7个WebUI功能测试用例
- 📚 **WebUI文档**：完善WebUI使用说明和开发指南

### Changed
- 🎯 **界面布局优化**：调整编辑器和预览面板高度，压缩不必要的间距
- 🔄 **代码重构**：清理重复代码，优化JavaScript架构
- 📁 **文件组织**：将WebUI相关文件统一到webui目录
- ⚙️ **配置外部化**：将硬编码配置移至配置文件
- 🚀 **启动方式优化**：提供多种便捷的启动方式

### Performance
- ⚡ **预览性能提升**：防抖处理减少服务器请求频率
- 🔄 **异步处理**：添加请求超时和取消机制
- 📏 **内容限制**：优化内存使用，限制预览和转换内容大小

### Fixed
- 🐛 **模块导入问题**：修复config模块导入错误
- 📋 **文件验证**：完善文件类型和内容检查
- 🔒 **安全漏洞**：修复潜在的安全风险

## [0.2.0] - 2025-12-26

### Added
- 🧪 **新增行内代码测试用例**：添加完整的行内代码转换测试
- 📝 **增强调试功能**：在关键组件中添加详细的调试信息输出

### Changed
- 🔧 **优化列表栈管理**：重构BaseConverter中的列表嵌套处理逻辑
- 🎨 **改进任务列表显示**：使用Unicode复选框符号，提升视觉效果

### Fixed
- 🐛 **修复行内代码丢失问题**：TextConverter现在正确处理`code_inline`标记
- 📋 **修复列表自动序号问题**：有序列表现在正确显示1. 2. 3.编号
- 📏 **修复列表悬挂距离问题**：列表项正确应用缩进和悬挂缩进
- 🔗 **修复嵌套列表编号错误**：嵌套有序列表的编号现在独立且正确
- ✅ **修复任务列表符号重复**：任务列表不再显示重复的列表符号
- 📊 **修复混合列表显示问题**：有序和无序列表的嵌套现在正确区分

### Performance
- ⚡ **优化转换性能**：改进token处理逻辑，减少不必要的遍历

## [0.1.1] - 2025-12-26

### Added
- 🤖 **AI协作规则系统集成**：集成完整的Cursor AI规则系统v3.0.0
- 🧠 **智能项目感知**：自动分析项目结构、团队动态和开发阶段
- 🌍 **多语言协作环境**：支持中英文智能切换
- 📊 **实时项目分析**：基于感知数据的优化建议
- 📋 **完整的开发文档**：添加development.md和testing.md
- 🔧 **包版本管理**：在src/__init__.py中定义版本信息

### Changed
- 📝 **更新README**：添加版本徽章和AI协作特性介绍
- 🏗️ **完善架构文档**：更新版本规划和项目结构描述
- 📦 **优化包导入**：更新src/converter/__init__.py包含所有转换器
- 🔧 **修复依赖版本**：更新requirements.txt中的black版本约束

### Fixed
- 🐛 **版本一致性**：统一各文件中的版本号为0.1.1
- 📁 **分支管理**：更新文档中的分支策略描述

## [0.1.0] - 2025-12-26

### Added
- ✅ **完整Markdown转换功能**：
  - 标题转换（H1-H6）
  - 文本样式（粗体、斜体、删除线）
  - 引用块（支持嵌套）
  - 列表转换（有序、无序、多级）
  - 代码块（基础语法高亮）
  - 链接处理（内联、引用、自动）
  - 图片支持（本地、在线）
  - 表格转换（对齐、样式）
  - 分隔线
  - 任务列表（TODO）
  - HTML标签基础支持

- 🏗️ **核心架构**：
  - BaseConverter核心转换器
  - 模块化元素转换器设计
  - 完整的错误处理体系

- 🧪 **全面测试体系**：
  - 61个单元测试
  - 27个集成测试
  - 测试样例覆盖所有功能

- 🛠️ **开发工具链**：
  - 命令行接口
  - 批量转换脚本
  - Black代码格式化
  - Pytest测试框架

### Changed
- 📋 **项目初始化**：建立完整的项目结构和配置
- 🔧 **依赖管理**：配置requirements.txt和pyproject.toml
- 📚 **文档体系**：创建架构设计和技术文档

---

## Types of changes
- `Added` for new features
- `Changed` for changes in existing functionality
- `Deprecated` for soon-to-be removed features
- `Removed` for now removed features
- `Fixed` for any bug fixes
- `Security` for vulnerability fixes

---

*此变更日志遵循[语义化版本](https://semver.org/)规范。*
### Added
- T-TEST-01-01：advanced 样例与 test.md 纳入集成测试
