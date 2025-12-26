# Markdown to DOCX 转换工具 - 测试规范

## 1. 测试概述

### 测试目标
- **确保功能正确性**: 验证所有Markdown转换功能按预期工作
- **防止回归**: 避免新功能破坏现有功能
- **提高代码质量**: 通过测试驱动的开发方式
- **文档化行为**: 测试用例作为功能使用示例

### 测试策略
- **单元测试**: 测试单个组件的功能
- **集成测试**: 测试组件间的协作
- **端到端测试**: 测试完整转换流程
- **回归测试**: 确保现有功能不受影响

## 2. 测试结构

### 目录结构
```
tests/
├── conftest.py              # 测试配置和fixtures
├── unit/                    # 单元测试
│   └── test_elements/       # 元素转换器测试
│       ├── test_heading.py  # 标题转换测试
│       ├── test_text.py     # 文本样式测试
│       ├── test_list.py     # 列表转换测试
│       └── ...              # 其他元素测试
├── integration/             # 集成测试
│   ├── test_full_conversion.py    # 完整转换测试
│   ├── test_table_integration.py  # 表格集成测试
│   └── ...                        # 其他集成测试
└── samples/                 # 测试样例数据
    ├── basic/               # 基础语法样例
    │   ├── headings.md      # 标题样例
    │   ├── text_styles.md   # 文本样式样例
    │   └── ...              # 其他基础样例
    └── advanced/            # 高级语法样例
        ├── tables.md        # 表格样例
        ├── math.md          # 数学公式样例
        └── ...              # 其他高级样例
```

### 测试文件命名规范
- **单元测试**: `test_*.py`
- **测试方法**: `test_*()`
- **fixtures**: `*_fixture` 或在`conftest.py`中定义

## 3. 单元测试规范

### 测试类结构
```python
import pytest
from src.converter.elements.heading import HeadingConverter

class TestHeadingConverter:
    """标题转换器测试类"""

    @pytest.fixture
    def converter(self):
        """创建转换器实例"""
        return HeadingConverter()

    def test_h1_conversion(self, converter):
        """测试H1标题转换"""
        # 测试逻辑
        pass

    def test_h6_conversion(self, converter):
        """测试H6标题转换"""
        # 测试逻辑
        pass

    def test_heading_with_styles(self, converter):
        """测试带样式的标题"""
        # 测试逻辑
        pass
```

### 测试原则
1. **独立性**: 每个测试独立运行，不依赖其他测试
2. **可重复性**: 多次运行结果一致
3. **快速执行**: 单个测试在秒级完成
4. **明确断言**: 清晰的成功/失败标准

### 断言规范
```python
# 正确示例
assert result is not None
assert len(paragraphs) == 3
assert paragraph.text == "期望文本"

# 避免模糊断言
# assert result  # 太模糊
# assert True    # 无意义
```

## 4. 集成测试规范

### 端到端测试
```python
def test_full_markdown_conversion():
    """测试完整Markdown文档转换"""

    # 测试数据
    markdown_content = """
    # 主标题

    这是一个**粗体**和*斜体*文本。

    ## 二级标题

    - 项目1
    - 项目2
      - 子项目

    ```python
    print("Hello, World!")
    ```

    | 表头1 | 表头2 |
    |-------|-------|
    | 数据1 | 数据2 |
    """

    # 执行转换
    converter = BaseConverter()
    doc = converter.convert(markdown_content)

    # 验证结果
    assert doc is not None

    # 验证标题
    headings = [p for p in doc.paragraphs if p.style.name.startswith('Heading')]
    assert len(headings) == 2

    # 验证列表
    # ... 更多验证逻辑
```

### 组件集成测试
```python
def test_table_with_list_integration():
    """测试表格和列表的集成转换"""

    content = """
    | 功能 | 状态 |
    |------|------|
    | 标题 | ✅ |
    | 列表 | ✅ |

    - 功能列表
      - 子功能1
      - 子功能2
    """

    converter = BaseConverter()
    doc = converter.convert(content)

    # 验证表格存在
    tables = doc.tables
    assert len(tables) == 1

    # 验证列表存在
    # ... 验证逻辑
```

## 5. 测试数据管理

### 样例文件规范
- **文件位置**: `tests/samples/basic/` 或 `tests/samples/advanced/`
- **命名规范**: `功能名称.md` (如 `headings.md`, `tables.md`)
- **内容规范**: 包含该功能的各种边界情况
- **注释说明**: 在文件中添加注释说明特殊情况

### 示例样例文件
```markdown
<!-- tests/samples/basic/headings.md -->
# H1 标题
## H2 标题
### H3 标题
#### H4 标题
##### H5 标题
###### H6 标题

# 带*样式*的标题
## 带**粗体**的标题
### 带[链接](url)的标题
```

## 6. 测试运行和报告

### 基本运行命令
```bash
# 运行所有测试
pytest

# 运行单元测试
pytest tests/unit/

# 运行集成测试
pytest tests/integration/

# 运行特定测试文件
pytest tests/unit/test_elements/test_heading.py

# 运行特定测试方法
pytest tests/unit/test_elements/test_heading.py::TestHeadingConverter::test_h1_conversion
```

### 测试配置
```ini
# pyproject.toml 中的pytest配置
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --tb=short"
markers = [
    "slow: 运行较慢的测试",
    "integration: 集成测试",
    "unit: 单元测试"
]
```

### 覆盖率报告
```bash
# 生成HTML覆盖率报告
pytest --cov=src --cov-report=html

# 生成终端覆盖率报告
pytest --cov=src --cov-report=term

# 生成XML报告（用于CI）
pytest --cov=src --cov-report=xml
```

## 7. 测试质量标准

### 覆盖率要求
- **语句覆盖率**: ≥ 90%
- **分支覆盖率**: ≥ 80%
- **函数覆盖率**: ≥ 95%

### 性能标准
- **单元测试**: 单个测试 < 0.1秒
- **集成测试**: 单个测试 < 1秒
- **全量测试**: 总运行时间 < 30秒

### 稳定性要求
- **测试通过率**: 100% (除跳过测试外)
- **随机失败**: < 1% (允许的随机失败率)

## 8. CI/CD集成

### GitHub Actions配置
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.8'
    - name: Install dependencies
      run: pip install -r requirements.txt
    - name: Run tests with coverage
      run: pytest --cov=src --cov-report=xml
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
```

## 9. 测试维护

### 测试重构
当代码重构时，需要相应更新测试：
1. **接口变更**: 更新测试中的调用方式
2. **行为变更**: 修改测试断言
3. **新增功能**: 添加新的测试用例

### 测试债务管理
```python
@pytest.mark.skip(reason="需要重构后实现")
def test_future_feature():
    """将来要实现的功能测试"""
    pass
```

### 性能回归检测
```python
def test_conversion_performance(benchmark):
    """性能回归测试"""
    markdown_content = generate_large_markdown()

    # 基准测试
    result = benchmark(convert_markdown, markdown_content)

    # 性能断言
    assert result.stats.mean < 1.0  # 平均转换时间 < 1秒
```

## 10. 调试和故障排除

### 调试测试失败
```bash
# 显示详细错误信息
pytest -v --tb=long

# 进入调试模式
pytest --pdb

# 只运行失败的测试
pytest --lf

# 显示print输出
pytest -s
```

### 常见问题解决
1. **路径问题**: 使用`pathlib.Path`和相对路径
2. **编码问题**: 统一使用UTF-8编码
3. **依赖问题**: 在`conftest.py`中正确设置fixtures
4. **并发问题**: 避免测试间的状态共享

---

*此测试规范确保项目质量和可维护性。请所有开发者遵循此规范编写和维护测试。*
