# Markdown to DOCX WebUI

基于Flask的Markdown转DOCX Web界面，提供现代化的用户体验。

## 🚀 特性

- **现代化界面**: 响应式设计，支持一次性阅读体验
- **实时预览**: 输入Markdown后实时生成DOCX预览
- **文件上传**: 支持拖拽上传Markdown文件
- **安全可靠**: 严格的文件验证和安全头保护
- **高性能**: 防抖优化和异步处理
- **易于部署**: 支持多种环境配置

## 📦 安装

```bash
cd webui
pip install -r ../../requirements.txt
```

## 🔧 配置

### 环境变量

- `FLASK_ENV`: 环境设置 (`development` 或 `production`)
- `SECRET_KEY`: Flask应用密钥（生产环境必需）
- `HOST`: 服务器主机 (默认: `0.0.0.0`)
- `PORT`: 服务器端口 (默认: `5000`)
- `UPLOAD_FOLDER`: 上传文件夹路径 (默认: `/tmp`)

### 示例

```bash
export FLASK_ENV=production
export SECRET_KEY=your-secret-key-here
export PORT=8000
python app.py
```

## 🎯 使用方法

1. **启动应用**:
   ```bash
   python app.py
   ```

2. **访问界面**:
   打开浏览器访问 `http://localhost:5000`

3. **使用功能**:
   - 在左侧输入Markdown内容
   - 右侧实时预览DOCX效果
   - 点击"转换为DOCX"下载文件

## 🏗️ 架构

```
webui/
├── app.py          # Flask应用主文件
├── config.py       # 配置管理
├── templates/      # HTML模板
├── static/         # 静态文件
│   ├── css/
│   └── js/
└── tests/          # 测试文件
```

## 🔒 安全特性

- 文件类型和内容验证
- 请求大小限制
- 安全的临时文件处理
- HTTP安全头保护
- CSRF防护（推荐添加）

## 🧪 测试

```bash
cd webui
python -m pytest tests/
```

## 📈 性能优化

- **防抖处理**: 输入防抖800ms，减少服务器请求
- **内容限制**: 预览内容限制2MB，转换内容限制5MB
- **异步处理**: 支持请求超时和取消
- **缓存优化**: 临时文件安全清理

## 🎨 UI设计

### 一次性阅读体验
- 编辑器和预览面板固定高度，不出现页面滚动
- 特性介绍页面压缩布局，确保一页显示完整
- 响应式设计，适配不同屏幕尺寸

### 交互优化
- 实时预览带加载状态
- 键盘快捷键支持 (Ctrl+Enter提交, Ctrl+Shift+P切换预览)
- 文件上传预览和验证

## 🔧 开发

### 添加新功能
1. 在 `app.py` 中添加路由
2. 在 `templates/` 中添加模板
3. 在 `static/js/` 中添加交互逻辑
4. 添加相应的CSS样式

### 代码规范
- 使用配置管理替代硬编码
- 添加适当的错误处理和日志
- 为新功能添加测试

## 📝 API文档

### 主要端点

- `GET /`: 主页
- `POST /convert`: 转换Markdown为DOCX
- `POST /preview`: 生成预览HTML

### 请求示例

```bash
# 预览请求
curl -X POST http://localhost:5000/preview \
  -d "markdown=# Hello World"

# 转换请求
curl -X POST http://localhost:5000/convert \
  -F "markdown=# Hello World"
```

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📄 许可证

与主项目保持一致。
