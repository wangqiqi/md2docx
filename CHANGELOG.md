# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
