# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
