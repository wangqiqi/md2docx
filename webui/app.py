"""
Flask Web应用
提供Markdown转DOCX的Web界面
"""

import os
import sys
import tempfile
import mimetypes
import uuid
from pathlib import Path

# 添加项目根目录到Python路径
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from flask import Flask, flash, redirect, render_template, request, send_file, url_for, jsonify
from werkzeug.utils import secure_filename

from src.converter import BaseConverter
from .config import get_config

# 导入markdown解析器
try:
    from markdown_it import MarkdownIt

    md = MarkdownIt()
except ImportError:
    # 如果没有安装markdown-it-py，使用简单的解析
    md = None

# 配置日志
import logging
logging.basicConfig(level=logging.INFO)

# 加载配置
config = get_config()

# 创建Flask应用
app = Flask(__name__)
app.config.from_object(config)

# 设置应用日志
app.logger.setLevel(logging.INFO if not config.DEBUG else logging.DEBUG)

# 初始化转换器
converter = BaseConverter()


def allowed_file(filename, file_obj=None):
    """验证文件是否允许上传"""
    # 检查文件扩展名
    if '.' not in filename:
        return False

    ext = filename.rsplit('.', 1)[1].lower()
    if ext not in config.ALLOWED_EXTENSIONS:
        return False

    # 如果提供了文件对象，检查MIME类型
    if file_obj:
        mime_type = mimetypes.guess_type(filename)[0]
        if mime_type and mime_type not in config.ALLOWED_MIME_TYPES:
            # 额外检查文件头（更严格的验证）
            file_obj.seek(0)
            file_header = file_obj.read(512)
            file_obj.seek(0)

            # 检查是否是文本文件（简单的启发式检查）
            try:
                file_header.decode('utf-8')
            except UnicodeDecodeError:
                return False

    return True


@app.route("/")
def index():
    """主页"""
    return render_template("index.html")


@app.route("/convert", methods=["POST"])
def convert():
    """转换处理"""
    try:
        markdown_content = ""

        # 获取Markdown内容
        if "file" in request.files and request.files["file"].filename:
            # 文件上传
            file = request.files["file"]
            if file.filename == "":
                flash("没有选择文件", "error")
                return redirect(url_for("index"))

            # 使用安全文件名验证
            filename = secure_filename(file.filename)

            # 验证文件类型和内容
            if not allowed_file(filename, file):
                flash("文件类型不支持或文件内容无效", "error")
                return redirect(url_for("index"))

            try:
                markdown_content = file.read().decode("utf-8")
            except UnicodeDecodeError:
                flash("文件编码错误，请使用UTF-8编码的文件", "error")
                return redirect(url_for("index"))
        else:
            # 文本输入
            markdown_content = request.form.get("markdown", "").strip()

        if not markdown_content:
            flash("请输入Markdown内容或上传文件", "error")
            return redirect(url_for("index"))

        # 检查内容长度
        if len(markdown_content) > config.MAX_TEXT_CONTENT_SIZE:
            flash("内容过大，请分批处理", "error")
            return redirect(url_for("index"))

        # 执行转换
        doc = converter.convert(markdown_content)

        # 保存到临时文件 - 使用更安全的方式
        import tempfile
        import uuid

        temp_filename = f"md2docx_{uuid.uuid4().hex}.docx"
        temp_dir = tempfile.gettempdir()
        docx_file_path = os.path.join(temp_dir, temp_filename)

        try:
            doc.save(docx_file_path)

            # 返回文件下载
            response = send_file(
                docx_file_path,
                as_attachment=True,
                download_name="converted.docx",
                mimetype="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            )

            # 设置清理回调
            @response.call_on_close
            def cleanup():
                try:
                    if os.path.exists(docx_file_path):
                        os.unlink(docx_file_path)
                except (OSError, IOError) as e:
                    app.logger.warning(f"清理临时文件失败: {e}")

            return response

        except Exception as save_error:
            # 清理可能已创建的文件
            try:
                if os.path.exists(docx_file_path):
                    os.unlink(docx_file_path)
            except:
                pass
            raise save_error

    except UnicodeDecodeError:
        flash("文件编码错误，请使用UTF-8编码", "error")
    except MemoryError:
        flash("文件过大，内存不足", "error")
    except Exception as e:
        app.logger.error(f"转换失败: {str(e)}", exc_info=True)
        flash("转换失败，请检查内容格式", "error")

    return redirect(url_for("index"))


@app.route("/preview", methods=["POST"])
def preview():
    """预览功能 - 只返回预览内容的HTML片段"""
    try:
        # 获取Markdown内容
        markdown_content = ""
        if "file" in request.files and request.files["file"].filename:
            file = request.files["file"]
            filename = secure_filename(file.filename)

            # 验证文件
            if not allowed_file(filename, file):
                return "<div class='preview-error'><span class='icon'>❌</span><p>不支持的文件类型</p></div>"

            try:
                markdown_content = file.read().decode("utf-8")
            except UnicodeDecodeError:
                return "<div class='preview-error'><span class='icon'>❌</span><p>文件编码错误</p></div>"
        else:
            markdown_content = request.form.get("markdown", "")

        if not markdown_content or len(markdown_content.strip()) == 0:
            return "<div class='preview-placeholder'><span class='icon'>👁️</span><p>请输入Markdown内容</p></div>"

        # 限制预览内容长度
        if len(markdown_content) > config.MAX_PREVIEW_CONTENT_SIZE:
            return "<div class='preview-error'><span class='icon'>⚠️</span><p>内容过长，无法预览</p></div>"

        # 生成预览HTML
        preview_html = generate_preview_html(markdown_content.strip())

        # 返回只包含预览内容的HTML片段
        return f"""<div class="preview-result"><div class="preview-content-rendered">{preview_html}</div></div>"""

    except Exception as e:
        app.logger.error(f"预览失败: {str(e)}", exc_info=True)
        error_msg = "预览生成失败，请稍后重试"
        return f"<div class='preview-error'><span class='icon'>❌</span><p>{error_msg}</p></div>"


def generate_preview_html(markdown_content):
    """生成预览HTML"""
    if md:
        # 使用markdown-it-py生成HTML
        html_content = md.render(markdown_content)
        # 添加一些基础样式，让预览更接近DOCX样式
        styled_html = f"""
        <div class="markdown-preview" style="font-family: 'Arial', sans-serif; line-height: 1.6;">
            {html_content}
        </div>
        """
        return styled_html
    else:
        # 降级到简单格式化
        lines = markdown_content.split("\n")
        html_lines = []

        for line in lines:
            line = line.strip()
            if not line:
                html_lines.append("<br>")
                continue

            # 标题
            if line.startswith("#"):
                level = len(line.split()[0])  # 计算#的数量
                text = line.lstrip("#").strip()
                html_lines.append(
                    f"<h{level} style='margin: 16px 0 8px 0; font-weight: bold;'>{text}</h{level}>"
                )
            # 无序列表
            elif line.startswith("- ") or line.startswith("* "):
                text = line[2:].strip()
                html_lines.append(f"<li style='margin-left: 20px;'>{text}</li>")
            # 有序列表
            elif line[0].isdigit() and line[1:3] == ". ":
                text = line[3:].strip()
                html_lines.append(f"<li style='margin-left: 20px;'>{text}</li>")
            # 代码块
            elif line.startswith("```"):
                if "```" in line[3:]:
                    code = line[3:-3]
                    code_style = "background: #f4f4f4; padding: 2px 4px; border-radius: 3px; font-family: monospace;"
                    html_lines.append(f"<code style='{code_style}'>{code}</code>")
                else:
                    pre_style = "background: #f4f4f4; padding: 12px; border-radius: 4px; font-family: monospace; margin: 8px 0;"
                    html_lines.append(f"<pre style='{pre_style}'>")
            # 内联代码
            elif "`" in line:
                # 简单的内联代码处理
                parts = line.split("`")
                formatted_parts = []
                for i, part in enumerate(parts):
                    if i % 2 == 1:  # 奇数索引是代码
                        inline_code_style = "background: #f4f4f4; padding: 1px 3px; border-radius: 2px; font-family: monospace;"
                        formatted_parts.append(f"<code style='{inline_code_style}'>{part}</code>")
                    else:
                        formatted_parts.append(part)
                html_lines.append(f"<p>{''.join(formatted_parts)}</p>")
            # 粗体
            elif "**" in line:
                text = line.replace("**", "<strong>", 1).replace("**", "</strong>", 1)
                html_lines.append(f"<p>{text}</p>")
            # 斜体
            elif "*" in line:
                text = line.replace("*", "<em>", 1).replace("*", "</em>", 1)
                html_lines.append(f"<p>{text}</p>")
            # 普通段落
            else:
                html_lines.append(f"<p style='margin: 8px 0;'>{line}</p>")

        return "\n".join(html_lines)


@app.errorhandler(413)
def too_large(e):
    """文件过大错误"""
    flash("文件大小超过限制 (16MB)", "error")
    return redirect(url_for("index"))


@app.errorhandler(500)
def internal_error(e):
    """服务器错误"""
    app.logger.error(f"服务器错误: {str(e)}", exc_info=True)
    flash("服务器内部错误，请稍后重试", "error")
    return redirect(url_for("index"))


@app.after_request
def add_security_headers(response):
    """添加安全头"""
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    return response


if __name__ == "__main__":
    app.run(
        debug=config.DEBUG,
        host=config.HOST,
        port=config.PORT
    )
