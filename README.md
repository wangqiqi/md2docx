# Markdown to DOCX 转换工具

[![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)](https://github.com/wangqiqi/md2docx/releases/tag/v0.2.0)
[![Cursor AI Rules](https://img.shields.io/badge/Cursor%20AI%20Rules-v3.0.0-green.svg)](https://github.com/wangqiqi/cursor-ai-rules)

一个功能强大的 Markdown 转 DOCX 文档转换工具，支持丰富的 Markdown 语法，提供命令行和批量转换功能，能够生成格式精美的 DOCX 文档。

**✨ 新版本特性：**
- 🤖 集成 Cursor AI 协作规则系统 v3.0.0
- 🧠 智能项目感知和自动进化
- 🌍 多语言协作环境支持
- 📊 实时项目分析和优化建议

## 特性

- 支持标准 Markdown 语法
- 完整的格式转换（标题、列表、代码块、表格、引用、图片等）
- 批量转换功能
- 命令行接口
- 本地处理，保护隐私

## 已实现功能

- ✅ 标题转换（h1-h6）
- ✅ 段落和文本样式（粗体、斜体、删除线）
- ✅ 引用块（支持多层嵌套）
- ✅ 列表转换（有序列表、无序列表、多级嵌套）
- ✅ 代码块（支持语法高亮）
- ✅ 链接处理（内联链接、引用链接、URL自动链接）
- ✅ 图片支持（本地图片、在线图片）
- ✅ 表格转换（基础表格、对齐方式）
- ✅ 分隔线
- ✅ 任务列表（TODO列表）
- ✅ 基础HTML标签支持

## 质量保证

项目采用专业级的质量保证体系，确保代码可靠性和开发效率：

### 🧪 测试体系
- **89个测试用例** - 覆盖核心功能和边界条件
- **85%+ 代码覆盖率** - 多维度测试保证
- **大文件测试** - 支持1MB+文档处理
- **边界条件测试** - Unicode、嵌套、异常输入

### 🔄 CI/CD 自动化
- **GitHub Actions** - 多Python版本测试 (3.8-3.12)
- **自动化检查** - 代码质量、格式、安全性
- **持续集成** - 每次提交自动验证

### 🛠️ 开发工具链
- **pre-commit** - 提交前代码质量检查
- **black + isort** - 自动代码格式化和导入排序
- **flake8** - 代码风格和错误检查
- **依赖分离** - 开发/生产环境独立配置

## 规划与路线图

📋 详细的开发规划和功能路线图请查看：[项目规划文档](docs/plan.md)

**已完成 ✅:**
- ✅ 专业测试体系 (89个测试，85%+覆盖率)
- ✅ CI/CD自动化 (GitHub Actions多版本测试)
- ✅ 代码质量保证 (pre-commit + 多工具检查)

**开发中 🔄:**
- 🔄 Web界面 (Flask + 基础前端) (v0.3.0)
- 🔄 实时预览功能 (v0.3.0)
- 🔄 自定义样式配置 (v0.3.0)

**规划中 📋:**
- 🔲 数学公式支持 (v0.4.0)
- 🔲 流程图支持 (v0.4.0)
- 🔲 双向转换 (v0.5.0)
- 🔲 插件系统 (v1.0.0)

## 开发环境要求

- Python 3.8+
- python-docx
- markdown-it-py
- 其他依赖见 requirements.txt

## 安装

### 开发环境安装（推荐）

如果您要进行开发、测试或贡献代码：

1. 克隆仓库：
```bash
git clone [repository-url]
cd md2docx
```

2. 创建虚拟环境：
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate  # Windows
```

3. 安装开发依赖：
```bash
pip install -r requirements-dev.txt
```

### 生产环境安装

如果您只是想使用 md2docx 进行文档转换：

```bash
pip install -r requirements-prod.txt
```

或直接从 PyPI 安装：
```bash
pip install md2docx
```

### 依赖说明

- **`requirements-prod.txt`**：仅包含运行时必需的依赖，轻量化安装
- **`requirements-dev.txt`**：包含所有开发、测试和构建工具
- **`requirements.txt`**：指向开发依赖的符号链接，向后兼容

## 使用方法

### 单文件转换

```bash
python -m src.cli input.md output.docx
```

### 批量转换

```bash
python scripts/batch_convert_test.py --input-dir your_md_folder --output-dir your_docx_folder
```

## 项目结构

```
md2docx/
├── src/                    # 源代码
│   ├── converter/         # 转换核心
│   │   ├── base.py       # 基础转换类
│   │   ├── elements/     # 各类元素转换器
│   │       ├── base.py   # 基础元素转换器
│   │       ├── text.py   # 文本相关（段落、样式）
│   │       ├── heading.py # 标题转换
│   │       ├── list.py   # 列表转换
│   │       ├── code.py   # 代码块转换
│   │       ├── table.py  # 表格转换
│   │       ├── image.py  # 图片转换
│   │       ├── links.py  # 链接转换
│   │       ├── blockquote.py # 引用块转换
│   │       ├── hr.py     # 分隔线转换
│   │       ├── task_list.py # 任务列表转换
│   │       └── html.py   # HTML标签转换
│   └── cli.py          # 命令行接口
├── tests/               # 测试用例
│   ├── unit/           # 单元测试
│   ├── integration/    # 集成测试
│   └── samples/        # 测试样例
│       ├── basic/      # 基础语法样例
│       └── advanced/   # 高级语法样例
├── docs/               # 文档
├── scripts/              # 工具脚本目录
│   ├── batch_convert_test.py    # 批量转换脚本
│   └── test_roundtrip_demo.py   # 闭环测试演示
├── requirements-prod.txt   # 生产环境依赖
├── requirements-dev.txt    # 开发环境依赖
├── requirements.txt        # 开发依赖符号链接
└── README.md          # 项目说明
```

## 开发指南

请参考 `docs/architecture.md` 了解详细的架构设计和开发规范。

## 测试

运行测试：
```bash
pytest tests/
```

## 贡献指南

1. Fork 项目
2. 创建特性分支
3. 提交变更
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License
