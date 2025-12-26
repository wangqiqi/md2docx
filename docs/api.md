# Web API 文档

## 概述

Markdown to DOCX Converter 提供了完整的Web API，允许通过HTTP请求进行文档转换操作。

## 基础信息

- **基础URL**: `http://localhost:5000` (开发环境)
- **认证**: 无需认证
- **数据格式**: JSON (请求), HTML/DOCX (响应)
- **字符编码**: UTF-8

## API 端点

### 1. 主页

**GET** `/`

获取Web界面主页。

**响应**: HTML页面

### 2. 文档转换

**POST** `/convert`

将Markdown内容转换为DOCX文档。

**请求参数**:

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `markdown` | string | 否 | Markdown文本内容 |
| `file` | file | 否 | Markdown文件上传 |

**注意**: `markdown` 和 `file` 参数必须至少提供一个。

**响应**:
- **成功**: DOCX文件下载 (Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document)
- **失败**: 重定向到主页并显示错误消息

**示例**:

```bash
# 文本转换
curl -X POST -F "markdown=# Hello World" http://localhost:5000/convert -o output.docx

# 文件上传转换
curl -X POST -F "file=@document.md" http://localhost:5000/convert -o output.docx
```

### 3. 预览功能

**POST** `/preview`

预览Markdown内容的转换效果。

**请求参数**:

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `markdown` | string | 否 | Markdown文本内容 |
| `file` | file | 否 | Markdown文件上传 |

**响应**:
- **成功**: HTML预览页面
- **失败**: 预览页面显示错误信息

**示例**:

```bash
curl -X POST -F "markdown=# Preview Test" http://localhost:5000/preview
```

## 错误处理

### HTTP 状态码

- `200`: 成功
- `302`: 重定向 (通常用于错误情况)
- `413`: 文件过大
- `500`: 服务器内部错误

### 错误消息

错误信息会通过Flash消息显示在Web界面中，包含以下类型：

- `error`: 转换失败、文件格式错误等
- `success`: 操作成功
- `warning`: 警告信息

## 文件限制

- **最大文件大小**: 16MB
- **支持的文件类型**: `.md`, `.markdown`, `.txt`
- **字符编码**: UTF-8 (推荐)

## 安全考虑

### 输入验证
- Markdown内容长度限制
- 文件类型严格检查
- XSS防护 (通过Flask模板转义)

### 文件处理
- 临时文件自动清理
- 无文件系统永久存储
- 安全的文件路径处理

## 使用示例

### Python 客户端

```python
import requests

# 文本转换
response = requests.post('http://localhost:5000/convert',
                        data={'markdown': '# Hello\n\nWorld!'})

if response.status_code == 200:
    with open('output.docx', 'wb') as f:
        f.write(response.content)

# 文件上传
with open('document.md', 'rb') as f:
    files = {'file': f}
    response = requests.post('http://localhost:5000/convert', files=files)

    if response.status_code == 200:
        with open('output.docx', 'wb') as f:
            f.write(response.content)
```

### JavaScript 客户端

```javascript
// 文件上传示例
const formData = new FormData();
formData.append('file', fileInput.files[0]);

fetch('/convert', {
    method: 'POST',
    body: formData
})
.then(response => response.blob())
.then(blob => {
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'converted.docx';
    a.click();
});
```

## 部署指南

### 开发环境

```bash
python -m webui.app
```

### 生产环境

```bash
# 使用Gunicorn
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 webui.app:app

# 使用Docker
docker build -t md2docx .
docker run -p 8000:8000 md2docx
```

## 监控和日志

### 应用日志
- Flask 应用日志输出到控制台
- 错误信息记录在应用日志中

### 性能监控
- 转换时间统计
- 文件大小监控
- 错误率跟踪

## 版本信息

- **API 版本**: v1.0
- **最后更新**: 2025-12-26
- **兼容性**: Python 3.8+

---

*此API文档会随着功能的扩展而更新。如有问题或建议，请查看项目Issues。*</contents>
</xai:function_call">Write contents to /home/saida/workspace/md2docx/docs/api.md
