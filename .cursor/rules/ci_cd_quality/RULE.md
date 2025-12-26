---
description: "CI/CD质量规范 - 标准化持续集成和代码质量检查"
globs: [".github/workflows/*.yml", ".flake8", "pyproject.toml", "**/Makefile"]
---

# 🔄 CI/CD质量规范 (CI/CD Quality Standard)

*版本: v1.0.0 | 最后更新: 2025-12-26 | 作者: AI Assistant*

## 🎯 适用场景

- GitHub Actions工作流配置
- 代码质量自动化检查
- CI/CD流程优化
- 构建和测试环境管理

## 📋 GitHub Actions配置规范

### 工作流文件结构
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, master, dev]
  pull_request:
    branches: [main, master, dev]

jobs:
  test:    # 多版本测试
  quality: # 代码质量检查
  build:   # 包构建验证
```

### 缓存策略优化
```yaml
# 推荐的缓存配置
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ matrix.python-version }}-${{ hashFiles('**/pyproject.toml') }}
    restore-keys: |
      ${{ runner.os }}-pip-${{ matrix.python-version }}-
      ${{ runner.os }}-pip-
```

### Python版本矩阵
```yaml
strategy:
  matrix:
    python-version: ['3.8', '3.9', '3.10', '3.11', '3.12']
```

## 🔍 代码质量检查配置

### Flake8配置
```ini
# .flake8
[flake8]
max-line-length = 120
extend-ignore = E203,W503,E402
exclude =
    __pycache__,
    .git,
    .venv,
    dist,
    build,
    *.egg-info
```

### 格式化工具链
```yaml
# CI中的格式化检查
- name: Run black check
  run: black --check --diff src tests

- name: Run isort check
  run: isort --check-only --diff src tests
```

### 类型检查配置
```yaml
# 可选的mypy检查，避免阻塞开发
- name: Run mypy (optional)
  run: |
    echo "Running mypy type checking..."
    mypy src --ignore-missing-imports --no-strict-optional --follow-imports=skip || echo "⚠️ mypy found some type issues, but this is acceptable for now"
  continue-on-error: true
```

## ⚠️ 常见CI/CD问题及解决方案

### hashFiles语法错误
```yaml
# ❌ 错误
key: ${{ hashFiles('**/pyproject.toml, **/requirements.txt') }}

# ✅ 正确
key: ${{ hashFiles('**/pyproject.toml', '**/requirements.txt') }}
```

### E402导入顺序错误
```
src/mddocx/webui/app.py:30:1: E402 module level import not at top of file
```
**解决方案**：
- 配置flake8忽略E402：`extend-ignore = E203,W503,E402`
- 或重构代码确保导入在文件顶部

### 格式化检查失败
```
would reformat tests/integration/test_hr_integration.py
```
**解决方案**：
- 运行 `black src tests` 自动格式化
- 提交格式化后的代码

### 缓存策略问题
- 依赖文件变化时缓存失效
- 使用 `hashFiles('**/pyproject.toml')` 只依赖核心配置文件

## 📊 CI/CD监控和优化

### 性能优化
- [ ] 使用合适大小的GitHub Actions runner
- [ ] 合理配置缓存策略
- [ ] 并行运行独立作业
- [ ] 按需运行重量级检查

### 稳定性保障
- [ ] 设置适当的超时时间
- [ ] 配置重试机制
- [ ] 使用 `continue-on-error` 处理可选检查
- [ ] 提供详细的错误日志

### 开发体验
- [ ] PR检查快速反馈
- [ ] 分支保护规则配置
- [ ] 状态徽章集成到README

## 🔧 CI/CD维护清单

### 定期检查
- [ ] Python版本矩阵更新
- [ ] 依赖项安全更新
- [ ] 缓存策略效果评估
- [ ] 运行时间优化

### 故障排查
- [ ] 查看Actions详细日志
- [ ] 检查网络连接问题
- [ ] 验证第三方服务状态
- [ ] 确认权限配置正确
