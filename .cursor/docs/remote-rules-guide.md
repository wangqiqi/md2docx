# Remote Rules Import Guide - 远程规则导入指南

## 📚 概述

根据Cursor官方文档，你可以从外部来源导入规则，以复用现有配置或使用其他工具中的规则。

## 🔗 支持的导入方式

### 1. GitHub仓库导入 (推荐)

直接从你有访问权限的任何GitHub仓库导入规则。

**操作步骤：**
1. 打开 **Cursor Settings → Rules, Commands**
2. 点击 `Project Rules` 旁的 `+ Add Rule`
3. 选择 `Remote Rule (GitHub)`
4. 粘贴包含该规则的GitHub仓库URL
5. Cursor会拉取该规则并同步到你的项目中

**示例URL：**
- `https://github.com/microsoft/vscode-eslint-rules`
- `https://github.com/facebook/react-cursor-rules`
- `https://github.com/google/angular-cursor-rules`

### 2. Agent Skills 导入

Cursor可以从[Agent Skills](https://cursor.com/docs/context/skills)加载规则，这是一个用于为AI Agent扩展专门能力的开放标准。

**启用方法：**
1. 打开 **Cursor Settings → Rules**
2. 找到 **Import Settings** 部分
3. 切换 **Agent Skills** 开关

## 🎯 推荐的社区规则

### 开发框架规则
- **React/Next.js**: React最佳实践和组件规范
- **Vue.js**: Vue项目结构和代码规范
- **Angular**: Angular开发模式和架构规范

### 编程语言规则
- **TypeScript**: 类型安全和代码质量
- **Python**: PEP8规范和最佳实践
- **Go**: Go语言规范和项目结构
- **Rust**: Rust安全性和性能优化

### 工具和框架
- **ESLint/Prettier**: 代码格式化和质量检查
- **Docker**: 容器化开发和部署规范
- **Kubernetes**: 云原生应用部署规范

## 📋 导入规则清单

### 前端开发
```bash
# React开发规范
https://github.com/vercel/next-cursor-rules

# Vue.js项目规范
https://github.com/vuejs/vue-cursor-rules

# TypeScript严格模式
https://github.com/microsoft/typescript-cursor-rules
```

### 后端开发
```bash
# Node.js最佳实践
https://github.com/nodejs/cursor-rules

# Python Django规范
https://github.com/django/django-cursor-rules

# Go微服务架构
https://github.com/golang/go-cursor-rules
```

### DevOps和工具
```bash
# Docker容器规范
https://github.com/docker/docker-cursor-rules

# Git工作流规范
https://github.com/git/git-cursor-rules

# CI/CD流程规范
https://github.com/github/cursor-actions
```

## ⚙️ 配置和使用

### 规则同步
导入的规则会与其源仓库保持同步，因此远程规则的更新会自动体现在你的项目中。

### 优先级管理
- 远程规则遵循标准的规则优先级
- 本地规则可以覆盖远程规则
- 定期检查更新以获取最新改进

### 自定义修改
- 可以基于导入的规则创建本地版本
- 在本地规则中引用远程规则的最佳实践
- 根据项目需求调整导入的规则

## 🔍 发现新规则

### 社区资源
- [Cursor Rules Gallery](https://cursor.com/rules-gallery) (假设)
- GitHub搜索: `cursor-rules` 或 `cursor rules`
- 技术社区和论坛讨论

### 质量评估
导入规则前建议评估：
- 维护活跃度
- 社区反馈
- 与项目技术的匹配度
- 文档完整性

## 🆘 故障排除

### 导入失败
- 检查仓库URL是否正确
- 确认对目标仓库有访问权限
- 验证规则格式是否符合Cursor标准

### 规则冲突
- 查看规则优先级设置
- 调整本地规则覆盖范围
- 重新组织规则应用顺序

### 同步问题
- 检查网络连接
- 确认远程仓库仍然可用
- 考虑创建本地副本

---

*此指南基于Cursor官方文档持续更新。如有新功能发布，请参考最新官方文档。*
