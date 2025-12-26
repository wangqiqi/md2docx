"""
Flask Web应用
提供Markdown转DOCX的Web界面
"""

import os
import sys
import tempfile
from pathlib import Path

# 添加项目根目录到Python路径
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from flask import Flask, flash, redirect, render_template, request, send_file, url_for

from src.converter import BaseConverter

# 导入markdown解析器
try:
    from markdown_it import MarkdownIt

    md = MarkdownIt()
except ImportError:
    # 如果没有安装markdown-it-py，使用简单的解析
    md = None

# 创建Flask应用
app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "dev-secret-key-change-in-production")
app.config["MAX_CONTENT_LENGTH"] = 16 * 1024 * 1024  # 16MB max file size
app.config["UPLOAD_FOLDER"] = tempfile.gettempdir()

# 初始化转换器
converter = BaseConverter()


@app.route("/")
def index():
    """主页"""
    return render_template("index.html")


@app.route("/convert", methods=["POST"])
def convert():
    """转换处理"""
    try:
        # 获取Markdown内容
        if "file" in request.files and request.files["file"].filename:
            # 文件上传
            file = request.files["file"]
            if file.filename == "":
                flash("没有选择文件", "error")
                return redirect(url_for("index"))

            if not file.filename.lower().endswith((".md", ".markdown", ".txt")):
                flash("只支持Markdown文件 (.md, .markdown, .txt)", "error")
                return redirect(url_for("index"))

            markdown_content = file.read().decode("utf-8")
        else:
            # 文本输入
            markdown_content = request.form.get("markdown", "").strip()

        if not markdown_content:
            flash("请输入Markdown内容或上传文件", "error")
            return redirect(url_for("index"))

        # 执行转换
        doc = converter.convert(markdown_content)

        # 保存到临时文件
        import tempfile

        with tempfile.NamedTemporaryFile(delete=False, suffix=".docx") as tmp_file:
            docx_file_path = tmp_file.name
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
                os.unlink(docx_file_path)
            except (OSError, IOError):
                pass

        return response

    except Exception as e:
        flash(f"转换失败: {str(e)}", "error")
        return redirect(url_for("index"))


@app.route("/preview", methods=["POST"])
def preview():
    """预览功能 - 只返回预览内容的HTML片段"""
    try:
        # 获取Markdown内容
        markdown_content = ""
        if "file" in request.files and request.files["file"].filename:
            file = request.files["file"]
            markdown_content = file.read().decode("utf-8")
        else:
            markdown_content = request.form.get("markdown", "")

        if not markdown_content:
            return "<div class='preview-placeholder'><span class='icon'>👁️</span><p>请输入Markdown内容</p></div>"

        # 生成预览HTML
        preview_html = generate_preview_html(markdown_content)

        # 返回只包含预览内容的HTML片段
        return f"""<div class="preview-result"><div class="preview-content-rendered">{preview_html}</div></div>"""

    except Exception as e:
        error_msg = f"预览失败: {str(e)}"
        return f"<div class='preview-error' style='color: #dc3545; padding: 20px; text-align: center;'>{error_msg}</div>"


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
    flash("服务器内部错误，请稍后重试", "error")
    return redirect(url_for("index"))


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
