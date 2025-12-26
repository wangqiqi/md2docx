# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
