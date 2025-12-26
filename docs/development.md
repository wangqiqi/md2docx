# Markdown to DOCX 转换工具 - 开发指南

## 1. 开发环境设置

### 环境要求
- **Python**: 3.8+
- **操作系统**: Linux/macOS/Windows
- **依赖管理**: pip + virtualenv

### 快速开始
```bash
# 1. 克隆项目
git clone https://github.com/wangqiqi/md2docx.git
cd md2docx

# 2. 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或 venv\Scripts\activate  # Windows

# 3. 安装依赖
pip install -r requirements.txt

# 4. 运行测试验证环境
pytest tests/
```

## 2. 项目结构详解

### 核心模块说明

#### `src/converter/base.py`
- **BaseConverter类**: 核心转换器，协调所有元素转换
- **错误处理**: MD2DocxError、ParseError、ConvertError
- **调试支持**: 可选的调试信息输出

#### `src/converter/elements/`
- **ElementConverter**: 基础转换器接口
- **各元素转换器**: 针对不同Markdown元素的专门处理

#### `src/cli.py`
- **命令行接口**: 单文件转换支持
- **参数处理**: 输入输出路径、调试选项
- **错误处理**: 文件占用等异常情况处理

### 测试结构
```
tests/
├── unit/           # 单元测试
│   └── test_elements/  # 各元素转换器测试
├── integration/    # 集成测试
│   └── test_*.py   # 端到端转换测试
└── samples/        # 测试样例
    ├── basic/      # 基础语法样例
    └── advanced/   # 高级语法样例
```

## 3. 开发工作流

### 分支策略
```
master (主分支)
├── 稳定版本发布
└── 生产就绪代码

dev (开发分支)
├── 日常开发
├── 功能集成
└── 从master创建feature分支

feature/* (功能分支)
├── 新功能开发
├── 从dev分支创建
└── 完成后合并回dev
```

### 提交规范
```bash
# 格式: <type>(<scope>): <subject>
# 例如:
feat: 添加图片转换功能
fix: 修复表格对齐问题
docs: 更新开发指南
test: 添加列表转换测试
refactor: 重构错误处理逻辑
```

### 代码审查流程
1. **创建功能分支**: `git checkout -b feature/new-feature`
2. **编写代码**: 遵循代码规范
3. **编写测试**: 确保测试覆盖
4. **提交代码**: `git commit -m "feat: 功能描述"`
5. **推送分支**: `git push origin feature/new-feature`
6. **创建PR**: 在GitHub上创建Pull Request
7. **代码审查**: 团队成员审查代码
8. **合并代码**: 审查通过后合并到dev分支

## 4. 代码规范

### Python代码风格
```python
# 使用Black进行代码格式化
# 类型注解必须完整
# 函数必须有文档字符串

def convert_element(self, element: Any) -> Any:
    """转换元素为DOCX格式

    Args:
        element: 要转换的元素

    Returns:
        转换后的DOCX元素
    """
    pass
```

### 命名约定
- **类名**: PascalCase (如 `BaseConverter`, `HeadingConverter`)
- **方法名**: snake_case (如 `convert_heading`, `process_text`)
- **变量名**: snake_case (如 `input_file`, `output_path`)
- **常量**: UPPER_CASE (如 `MAX_RETRY_COUNT`)

### 错误处理
```python
try:
    # 可能出错的操作
    result = risky_operation()
except SpecificError as e:
    # 具体错误处理
    logger.error(f"具体错误: {e}")
    raise ConvertError(f"转换失败: {e}") from e
except Exception as e:
    # 通用错误处理
    logger.error(f"未知错误: {e}")
    raise MD2DocxError(f"系统错误: {e}") from e
```

## 5. 测试开发

### 单元测试编写
```python
import pytest
from src.converter.elements.heading import HeadingConverter

class TestHeadingConverter:
    def test_h1_conversion(self):
        converter = HeadingConverter()
        # 测试H1标题转换
        pass

    def test_h6_conversion(self):
        # 测试H6标题转换
        pass
```

### 集成测试编写
```python
def test_full_markdown_conversion():
    """测试完整Markdown文档转换"""
    input_md = """
    # 标题
    这是一个**粗体**文本。

    - 项目1
    - 项目2
    """

    converter = BaseConverter()
    doc = converter.convert(input_md)

    # 验证转换结果
    assert doc is not None
```

### 测试运行
```bash
# 运行所有测试
pytest

# 运行单元测试
pytest tests/unit/

# 运行集成测试
pytest tests/integration/

# 生成覆盖率报告
pytest --cov=src --cov-report=html
```

## 6. 调试技巧

### 调试模式
```bash
# 启用调试输出
python -m src.cli input.md output.docx --debug
```

### 日志配置
```python
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

### 常见调试场景
1. **转换结果异常**: 检查元素转换器的输出
2. **样式问题**: 验证DOCX样式设置
3. **解析错误**: 检查Markdown解析结果
4. **性能问题**: 使用cProfile分析性能瓶颈

## 7. 性能优化

### 代码优化
- **避免重复解析**: 缓存解析结果
- **批量处理**: 支持多个文件批量转换
- **内存管理**: 大文件处理时的内存优化

### 工具使用
```bash
# 性能分析
python -m cProfile -s time script.py

# 内存分析
pip install memory_profiler
python -m memory_profiler script.py
```

## 8. 扩展开发

### 添加新元素转换器
1. **创建转换器类**: 继承`ElementConverter`
2. **实现转换逻辑**: `convert`方法
3. **注册转换器**: 在`BaseConverter`中注册
4. **编写测试**: 创建对应的单元测试
5. **更新文档**: 在README中添加新功能说明

### 示例：添加数学公式支持
```python
# src/converter/elements/math.py
class MathConverter(ElementConverter):
    def convert(self, math_block):
        # 实现数学公式转换逻辑
        pass

# 在BaseConverter中注册
self.register_converter('math', MathConverter())
```

## 9. 发布准备

### 版本发布流程
1. **更新版本号**: 修改`pyproject.toml`和`__init__.py`
2. **更新文档**: 完善CHANGELOG和README
3. **运行测试**: 确保所有测试通过
4. **创建标签**: `git tag v1.0.0`
5. **打包发布**: 使用PyInstaller打包

### 打包配置
```bash
# 使用PyInstaller打包
pyinstaller --onefile --name md2docx src/cli.py

# 或使用setuptools
python setup.py sdist bdist_wheel
```

## 10. 故障排除

### 常见问题
1. **依赖安装失败**: 检查Python版本和pip配置
2. **测试失败**: 运行`pytest -v`查看详细错误
3. **转换结果异常**: 使用`--debug`选项查看调试信息
4. **性能问题**: 使用性能分析工具定位瓶颈

### 获取帮助
- **问题反馈**: 在GitHub Issues中提交问题
- **贡献指南**: 查看CONTRIBUTING.md
- **开发讨论**: 参与GitHub Discussions

---

*此开发指南将随着项目发展持续更新。如有问题或建议，请提交Issue或PR。*

