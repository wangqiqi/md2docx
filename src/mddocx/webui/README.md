# Markdown to DOCX WebUI

基于 Flask 的 Markdown 转 DOCX Web 界面，提供现代化的用户体验。

## 🚀 特性

- **现代化界面**: 响应式设计，支持一次性阅读体验
- **实时预览**: 输入 Markdown 后实时生成 DOCX 预览
- **文件上传**: 支持拖拽上传 Markdown 文件
- **批量转换**: 最多选择 20 个文件，下载 DOCX ZIP，并显示成功/失败摘要
- **错误可读**: 单文件与批量结果展示 `[E_*]` 错误码、说明和文件名
- **安全可靠**: bleach 预览消毒、CSP 头、CSRF 防护、per-IP 限流
- **高性能**: 防抖优化和异步处理
- **易于部署**: 支持 development / production 配置

## 📦 安装

从项目根目录安装（依赖见 `pyproject.toml`）：

```bash
pip install -e ".[dev]"
# 或生产环境
pip install .
```

## 🔧 配置

### 环境变量

- `FLASK_ENV`: 环境设置 (`development` 或 `production`)
- `SECRET_KEY`: Flask 应用密钥（**生产环境必需**）
- `HOST`: 服务器主机（默认: `127.0.0.1`；生产可通过环境变量覆盖）
- `PORT`: 服务器端口 (默认: `5000`)
- `UPLOAD_FOLDER`: 上传文件夹路径 (默认: `/tmp`)

### 示例

```bash
export FLASK_ENV=production
export SECRET_KEY=your-secret-key-here
export HOST=0.0.0.0   # 生产绑定（开发默认 127.0.0.1）
export PORT=8000
mddocx-webui
```

## 🎯 使用方法

1. **启动应用**:
   ```bash
   mddocx-webui
   # 或
   python -m mddocx.webui.app
   ```

2. **访问界面**:
   打开浏览器访问 `http://127.0.0.1:5000`

3. **使用功能**:
   - 在左侧输入 Markdown 内容
   - 右侧实时预览 DOCX 效果
   - 点击「转换为 DOCX」下载文件
   - 点击「批量选择」选取多个文件，再下载 `batch_converted.zip`
   - 部分文件失败时，页面直接显示失败项；ZIP 内同时包含 `batch_errors.json`

## 🏗️ 架构

```
src/mddocx/webui/
├── app.py          # Flask 应用主文件
├── batch.py        # 批量转换与 ZIP / batch_errors.json 打包
├── config.py       # 配置管理
├── rate_limit.py   # per-IP 限流
├── templates/      # HTML 模板
├── static/         # 静态文件
│   ├── css/
│   └── js/
└── tests/          # 测试（已纳入 CI）
```

## 🔒 安全特性

- 文件类型和内容验证
- 请求大小限制
- 安全的临时文件处理
- HTTP 安全头（CSP 等）
- Flask-WTF CSRF 防护
- 预览 HTML bleach 消毒

## 🧪 测试

```bash
pytest -q src/mddocx/webui/tests/
```

## 📈 性能优化

- **防抖处理**: 输入防抖 800ms，减少服务器请求
- **内容限制**: 预览内容限制 2MB，转换内容限制 5MB
- **批量限制**: `MAX_BATCH_FILES` 默认 20；批量请求按整批计一次限流
- **异步处理**: 支持请求超时和取消
- **缓存优化**: 临时文件安全清理

## 🎨 UI 设计

### 一次性阅读体验
- 编辑器和预览面板固定高度，不出现页面滚动
- 特性介绍页面压缩布局，确保一页显示完整
- 响应式设计，适配不同屏幕尺寸

### 交互优化
- 实时预览带加载状态
- 批量转换显示阶段进度、成功/失败数量和逐文件错误
- 键盘快捷键支持 (Ctrl+Enter 提交, Ctrl+Shift+P 切换预览)
- 文件上传预览和验证

## 🔧 开发

### 添加新功能
1. 在 `app.py` 中添加路由
2. 在 `templates/` 中添加模板
3. 在 `static/js/` 中添加交互逻辑
4. 添加相应的 CSS 样式

### 代码规范
- 使用配置管理替代硬编码
- 添加适当的错误处理和日志
- 为新功能添加测试

## 📝 API 文档

详见 [`docs/04_API与部署.md`](../../docs/04_API与部署.md)。

### 主要端点

- `GET /`: 主页
- `POST /convert`: 转换 Markdown 为 DOCX
- `POST /convert/batch`: `files` 多文件上传，返回 ZIP；失败清单位于 `batch_errors.json`
- `POST /preview`: 生成预览 HTML

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

与主项目保持一致。
