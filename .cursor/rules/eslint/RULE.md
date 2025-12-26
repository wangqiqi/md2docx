---
description: "ESLint代码质量检查集成 - 自动检测和修复JavaScript代码问题"
globs: ["*.js", "*.ts", "*.jsx", "*.tsx"]
alwaysApply: true
---

# 🔍 ESLint 代码质量检查集成

## 🎯 功能特性

- **自动代码检查**: 文件保存时自动运行ESLint检查
- **智能修复建议**: 提供可自动修复的问题解决方案
- **配置管理**: 支持项目级和全局ESLint配置
- **性能优化**: 仅在相关文件类型上运行，避免不必要的检查

## 📋 检查规则

### 基础语法检查
- 分号使用一致性
- 引号风格统一
- 未使用变量检测
- 控制台输出警告

### 代码质量规则
- 变量命名规范
- 函数复杂度控制
- 代码重复检测
- 最佳实践遵循

## ⚙️ 配置选项

```json
{
  "semi": ["error", "always"],
  "quotes": ["error", "single"],
  "no-unused-vars": "warn",
  "no-console": "off",
  "complexity": ["error", 10],
  "max-lines-per-function": ["error", 50]
}
```

## 🚀 使用方法

### 自动模式
插件启用后，会在以下时机自动运行：
- 文件保存时
- Git提交前
- 手动触发检查

### 手动检查
```bash
# 检查当前目录
./cursor/scripts/check.sh

# 检查指定文件
./cursor/scripts/check.sh file.js

# 自动修复
./cursor/scripts/check.sh --fix
```

## 📊 报告格式

### 检查结果
```
📁 检查文件: src/app.js
✅ 通过检查: 45个规则
⚠️  警告: 2个问题
❌ 错误: 1个问题

🔧 可自动修复: 2个问题
💡 建议修复: 1个问题
```

### 修复建议
```
建议修复的问题:
1. 缺少分号 (自动修复可用)
2. 未使用变量 'unusedVar' (需要手动处理)
3. 引号不一致 (自动修复可用)
```

---

*ESLint代码质量检查集成确保JavaScript/TypeScript项目的代码质量和一致性，提升开发效率和代码可维护性。*
