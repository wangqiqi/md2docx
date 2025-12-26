# 贡献指南

感谢您对 Markdown to DOCX 转换工具项目的兴趣！我们欢迎各种形式的贡献，包括但不限于：

- 🐛 报告bug
- 💡 提出新功能建议
- 📝 改进文档
- 🔧 提交代码修复
- 🧪 添加测试用例

## 🚀 快速开始

### 开发环境设置

1. **克隆项目**
   ```bash
   git clone https://github.com/wangqiqi/md2docx.git
   cd md2docx
   ```

2. **安装开发依赖**
   ```bash
   pip install -e .[dev]
   ```

3. **运行测试**
   ```bash
   pytest
   ```

### 代码规范

我们使用以下工具确保代码质量：

- **代码格式化**: Black
- **导入排序**: isort
- **代码检查**: flake8
- **类型检查**: mypy

#### 自动格式化代码
```bash
# 格式化代码
black src/ tests/

# 排序导入
isort src/ tests/

# 检查代码规范
flake8 src/ tests/

# 类型检查
mypy src/
```

## 🐛 报告问题

在使用过程中遇到问题时，请：

1. 检查 [Issues](../../issues) 是否已有类似问题
2. 如果没有，创建一个新的 Issue，包含：
   - 详细的问题描述
   - 重现步骤
   - 期望的行为
   - 实际的行为
   - 环境信息（Python版本、操作系统等）

## 💡 功能请求

有新功能想法时：

1. 检查是否已有相关 Issue 或功能已在开发中
2. 创建 Feature Request，描述：
   - 功能的具体需求
   - 使用场景
   - 可能的实现方式

## 🔧 代码贡献

### 提交 Pull Request

1. **Fork 项目** 到您的 GitHub 账户

2. **创建特性分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **编写代码**
   - 遵循现有代码风格
   - 添加必要的测试
   - 更新相关文档

4. **提交测试**
   ```bash
   # 运行所有测试
   pytest

   # 检查覆盖率
   pytest --cov=src/mddocx --cov-report=html
   ```

5. **提交更改**
   ```bash
   git add .
   black src/ tests/  # 格式化代码
   isort src/ tests/  # 排序导入
   git commit -m "feat: 添加新功能"
   ```

6. **推送分支**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 详细描述更改内容
   - 关联相关 Issue

### 代码风格指南

- **命名规范**: 使用 snake_case (函数和变量), PascalCase (类)
- **文档字符串**: 使用 Google 风格的 docstring
- **类型注解**: 为所有公共函数添加类型注解
- **错误处理**: 使用具体的异常类型，避免裸 `except`
- **测试覆盖**: 保持高测试覆盖率 (>80%)

### 提交信息规范

我们使用 [Conventional Commits](https://conventionalcommits.org/) 规范：

```
type(scope): description

[optional body]

[optional footer]
```

**类型**:
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或工具配置

**示例**:
```
feat: 添加图片缓存功能

- 实现图片URL缓存机制
- 添加缓存清理功能
- 提升图片加载性能

Closes #123
```

## 🧪 测试策略

### 单元测试
- 位于 `tests/unit/` 目录
- 测试单个组件的功能
- 使用 pytest fixtures 管理测试数据

### 集成测试
- 位于 `tests/integration/` 目录
- 测试组件间的交互
- 验证端到端功能

### WebUI 测试
- 位于 `tests/webui/` 目录
- 测试Web界面功能
- 使用 Flask 的测试客户端

### 测试覆盖率
- 目标覆盖率: >80%
- 使用 `pytest-cov` 生成覆盖率报告
- 重点覆盖核心转换逻辑

## 📚 文档更新

### 更新现有文档
- 修改 `docs/` 目录下的相应文件
- 保持文档与代码同步

### 添加新文档
- 在 `docs/` 目录创建新文件
- 更新 `README.md` 中的链接

## 🔄 开发工作流

1. **选择任务**: 从 [Issues](../../issues) 中选择任务
2. **创建分支**: `git checkout -b feature/issue-number-description`
3. **开发代码**: 实现功能并添加测试
4. **代码审查**: 运行所有检查工具
5. **提交PR**: 创建 Pull Request 并等待审查

## 📞 获取帮助

如果您在贡献过程中遇到问题：

- 查看 [文档](../../docs)
- 搜索现有 [Issues](../../issues)
- 创建新的 Issue 询问

我们致力于让贡献过程尽可能顺畅，感谢您的参与！ 🎉
