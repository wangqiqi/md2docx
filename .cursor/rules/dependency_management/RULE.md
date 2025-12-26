---
description: "依赖管理规范 - 统一Python项目依赖配置和版本管理"
globs: ["**/pyproject.toml", "**/requirements*.txt", "**/Pipfile*", "**/poetry.lock", "**/Makefile"]
---

# 📦 依赖管理规范 (Dependency Management Standard)

*版本: v1.0.0 | 最后更新: 2025-12-26 | 作者: AI Assistant*

## 🎯 适用场景

- Python项目依赖配置
- 包版本管理
- 开发/生产环境区分
- CI/CD依赖安装
- 安全更新管理

## 📋 依赖管理最佳实践

### 现代Python项目配置

#### ✅ pyproject.toml统一配置
```toml
[project]
name = "mddocx"
version = "0.4.3"
dependencies = [
    "python-docx>=0.8.11",
    "markdown-it-py>=2.1.0",
    "flask>=2.0.0",
    "werkzeug>=2.0.0"
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "coverage>=7.0.0",
    "flake8>=6.0.0",
    "black>=23.0.0",
    "mypy>=1.0.0",
    "isort>=5.12.0",
    "build>=1.0.0",
    "twine>=4.0.0"
]
docs = [
    "sphinx>=5.0.0",
    "sphinx-rtd-theme>=1.2.0"
]

[build-system]
requires = ["setuptools>=42", "wheel"]
build-backend = "setuptools.build_meta"
```

#### 安装命令标准化
```bash
# 开发环境安装
pip install -e .[dev]

# 生产环境安装
pip install mddocx

# 仅核心依赖
pip install .
```

## ⚠️ 常见依赖管理问题

### 多重依赖文件混乱

#### ❌ 反面模式
```
requirements.txt
requirements-dev.txt
requirements-prod.txt
setup.py
Pipfile
poetry.lock
```

**问题表现**:
- 版本不一致
- 安装命令混乱
- 维护困难

#### ✅ 推荐方案
- 使用单一 `pyproject.toml`
- 可选依赖分组
- 清晰的安装说明

### CI/CD依赖缓存问题

#### 缓存key配置
```yaml
# ❌ 错误的缓存key
key: ${{ hashFiles('**/pyproject.toml,**/requirements.txt') }}

# ✅ 正确的缓存key
key: ${{ hashFiles('**/pyproject.toml') }}
```

### 依赖版本管理

#### 版本约束规范
```toml
# ✅ 推荐的版本约束
dependencies = [
    "python-docx>=0.8.11",      # 最低版本
    "markdown-it-py>=2.1.0",    # 兼容版本
    "flask>=2.0.0,<3.0.0",     # 版本范围
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",            # 稳定版本
    "black>=23.0.0",            # 功能版本
]
```

### 安全依赖更新

#### 定期检查
```bash
# 检查过期包
pip list --outdated

# 检查安全漏洞
pip-audit
safety check

# 更新依赖
pip install --upgrade -e .[dev]
```

## 🔧 依赖管理维护清单

### 定期检查
- [ ] 依赖版本更新
- [ ] 安全漏洞扫描
- [ ] 兼容性测试
- [ ] 包大小优化

### 故障排查
- [ ] 解决版本冲突
- [ ] 处理弃用警告
- [ ] 清理未使用依赖
- [ ] 更新构建工具

### 文档同步
- [ ] 更新README安装说明
- [ ] 维护CHANGELOG
- [ ] 记录重大版本更新

## 📊 依赖管理监控

### 包大小控制
- 监控wheel包大小
- 评估依赖树复杂度
- 考虑精简依赖

### 兼容性保障
- 测试多Python版本
- 验证平台兼容性
- 确认许可证兼容

### 性能优化
- 选择高效实现
- 避免重叠功能包
- 使用轻量级替代品
