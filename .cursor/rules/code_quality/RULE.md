---
description: "代码质量规范 - 确保代码风格一致性和最佳实践"
globs: ["src/**/*.py", "tests/**/*.py", "**/pyproject.toml", "**/Makefile"]
---

# 💎 代码质量规范 (Code Quality Standard)

*版本: v1.0.0 | 最后更新: 2025-12-26 | 作者: AI Assistant*

## 🎯 适用场景

- 新代码编写
- 现有代码重构
- 代码审查标准
- 团队协作规范

## 📋 导入管理规范

### ✅ 推荐的导入结构
```python
# 1. 标准库导入
import os
import sys
from pathlib import Path

# 2. 第三方库导入
from flask import Flask, request, jsonify
from docx import Document

# 3. 本地模块导入
from ..converter import BaseConverter
from .config import get_config

# 4. 条件导入（可选）
try:
    from markdown_it import MarkdownIt
    HAS_MARKDOWN_IT = True
except ImportError:
    HAS_MARKDOWN_IT = False
```

### ❌ 避免的导入问题
```python
# ❌ 导入在代码执行之后
import sys
sys.path.insert(0, str(project_root))  # 先执行
from .local_module import something     # 后导入

# ❌ 通配符导入
from module import *

# ❌ 循环导入
# module_a.py: from module_b import B
# module_b.py: from module_a import A

# ❌ sys.path修改后的导入问题
import sys
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))  # ❌ 执行代码后导入
from .local_module import something

# ✅ 正确的sys.path处理
# 1. 标准库导入
import sys
from pathlib import Path

# 2. 路径设置
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# 3. 模块导入
from .local_module import something
```

#### 导入顺序错误的影响
- **flake8 E402错误**: `module level import not at top of file`
- **运行时错误**: 可能导致模块找不到
- **维护困难**: 代码结构不清晰

#### 解决方案优先级
1. **重构代码**: 将路径设置移到文件顶部
2. **条件导入**: 在函数内部进行导入
3. **配置忽略**: `extend-ignore = E203,W503,E402` (最后手段)

## 🎨 代码格式化标准

### Black配置
```python
# pyproject.toml
[tool.black]
line-length = 120
target-version = ['py38', 'py39', 'py310', 'py311', 'py312']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
)/
'''
```

### 空行规范
```python
# 函数间：2个空行
def function_a():
    pass


def function_b():
    pass

# 类方法间：1个空行
class MyClass:
    def method_a(self):
        pass

    def method_b(self):
        pass

# 逻辑块间：1个空行
def complex_function():
    # 初始化
    x = 1
    y = 2

    # 计算
    result = x + y

    # 返回
    return result
```

## 🔍 代码质量检查

### Flake8规则配置
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

### 类型检查配置
```ini
# mypy.ini 或 pyproject.toml 中的 [tool.mypy]
[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = false
ignore_missing_imports = true
no_strict_optional = true
```

## 📏 代码风格指南

### 命名规范
```python
# 类名：PascalCase
class MarkdownConverter:
    pass

# 函数名：snake_case
def convert_markdown_to_docx():
    pass

# 变量名：snake_case
markdown_content = "# Hello World"
docx_document = None

# 常量：UPPER_CASE
MAX_FILE_SIZE = 10 * 1024 * 1024
DEFAULT_ENCODING = 'utf-8'
```

### 文档字符串规范
```python
def convert_file(input_path: str, output_path: str) -> bool:
    """
    将Markdown文件转换为DOCX文件。

    Args:
        input_path: 输入的Markdown文件路径
        output_path: 输出的DOCX文件路径

    Returns:
        转换是否成功的布尔值

    Raises:
        FileNotFoundError: 输入文件不存在时抛出
        PermissionError: 权限不足时抛出

    Example:
        >>> success = convert_file("input.md", "output.docx")
        >>> print(success)
        True
    """
    pass
```

## ⚠️ 常见代码质量问题及修复

### 行太长 (E501)
```python
# ❌ 行太长
result = some_very_long_function_name_that_exceeds_the_line_length_limit(argument_one, argument_two, argument_three)

# ✅ 正确处理
result = some_very_long_function_name(
    argument_one,
    argument_two,
    argument_three
)
```

### 未使用的导入 (F401)
```python
# ❌ 未使用的导入
from pathlib import Path
import os  # 未使用

def my_function():
    return "hello"

# ✅ 移除未使用的导入
def my_function():
    return "hello"
```

### 导入顺序问题 (E402)
```python
# ❌ 导入在代码执行之后
import sys
sys.path.insert(0, '/some/path')  # 代码执行
from my_module import MyClass     # 导入

# ✅ 正确顺序
import sys
from pathlib import Path

# 先设置路径
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# 再导入本地模块
from my_module import MyClass
```

## 🧪 测试代码规范

### 测试文件结构
```python
"""
测试模块的说明文档
"""

import pytest
from unittest.mock import MagicMock

from my_module import MyClass


class TestMyClass:
    """MyClass的测试用例"""

    def test_initialization(self):
        """测试初始化功能"""
        instance = MyClass()
        assert instance is not None

    def test_some_method(self):
        """测试某个方法"""
        instance = MyClass()
        result = instance.some_method()
        assert result == expected_value
```

### 测试命名规范
- 测试类：`Test{CamelCase}`
- 测试方法：`test_snake_case`
- 夹具：`snake_case` + `_fixture`

## 🔧 开发工具配置

### Pre-commit钩子
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/psf/black
    rev: 23.7.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
```

### VS Code设置
```json
{
  "python.formatting.provider": "black",
  "python.linting.flake8Enabled": true,
  "python.linting.mypyEnabled": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  }
}
```
