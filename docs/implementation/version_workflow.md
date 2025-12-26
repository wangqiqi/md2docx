# 📦 版本管理工作流程 (Version Management Workflow)

*版本: v1.0.0 | 最后更新: 2025-12-26 | 作者: AI Assistant*

## 🎯 概述

本文档详细记录了项目中的版本管理工作流程、具体实施步骤和问题解决方案。

## 📋 版本号更新清单

### 🔧 必须更新的文件

1. **`pyproject.toml`**
   ```toml
   [project]
   version = "0.4.3"  # ← 更新此处
   ```

2. **`src/mddocx/__init__.py`**
   ```python
   __version__ = "0.4.3"  # ← 更新此处
   ```

3. **`README.md`**
   ```markdown
   [![Version](https://img.shields.io/badge/version-0.4.3-blue.svg)](https://github.com/wangqiqi/md2docx/releases/tag/v0.4.3)
   ```

### 🏷️ 版本号格式规范

- **格式**: `x.y.z` (语义化版本)
- **示例**: `0.4.3`, `1.0.0`, `2.1.5`
- **标签**: `v{x.y.z}` (如: `v0.4.3`)

## ✅ 发布前检查清单

### 🔍 代码质量验证
- [ ] `black --check --diff src tests` 通过
- [ ] `flake8 src tests` 0个错误
- [ ] `python -m pytest -v` 全部测试通过
- [ ] `mypy src` 类型检查完成

### 📋 版本一致性检查
- [ ] 所有文件版本号完全一致
- [ ] README徽章指向正确的发布版本
- [ ] CHANGELOG.md已更新发布说明
- [ ] 文档中的版本引用已更新

### 🏷️ Git操作规范
- [ ] 创建带详细注释的标签：
  ```bash
  git tag -a v0.4.3 -m "Release version 0.4.3

  - 修复flake8代码质量问题
  - 重构测试文件和脚本
  - 更新项目配置和文档
  - 改进WebUI应用和异常处理
  - 新增链接转换器和CLI测试
  - 所有测试通过"
  ```

- [ ] 推送标签触发发布：
  ```bash
  git push origin v0.4.3
  ```

## ⚠️ 常见问题与解决方案

### 版本号不一致
```bash
# 检查所有版本号
grep -r "0\.4\.[0-9]" --include="*.py" --include="*.toml" --include="*.md" .
```

### 忘记更新某个文件
- 使用检查清单逐一验证
- 提交前运行完整测试确保一切正常

### 标签管理错误
```bash
# 删除错误的标签
git tag -d v0.4.3
git push origin --delete v0.4.3

# 重新创建正确标签
git tag -a v0.4.3 -m "详细的发布说明"
git push origin v0.4.3
```

## 📚 相关链接

- [通用版本管理规范](../rules/version_management.md) - 通用原则和规则
- [语义化版本规范](https://semver.org/)
- [CHANGELOG格式规范](https://keepachangelog.com/)
