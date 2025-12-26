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
    """预览功能"""
    try:
        # 获取Markdown内容
        markdown_content = ""
        if "file" in request.files and request.files["file"].filename:
            file = request.files["file"]
            markdown_content = file.read().decode("utf-8")
        else:
            markdown_content = request.form.get("markdown", "")

        if not markdown_content:
            return render_template(
                "preview.html",
                markdown_content="",
                preview_content="请输入Markdown内容",
                error="请输入Markdown内容",
            )

        # 生成预览HTML
        preview_html = generate_preview_html(markdown_content)

        return render_template(
            "preview.html",
            markdown_content=markdown_content,
            preview_content=preview_html,
        )

    except Exception as e:
        return render_template(
            "preview.html",
            markdown_content=markdown_content if "markdown_content" in locals() else "",
            preview_content=f"预览失败: {str(e)}",
            error=str(e),
        )


def generate_preview_html(markdown_content):
    """生成预览HTML"""
    # 这里可以实现更复杂的预览逻辑
    # 目前先返回简单的格式化
    lines = markdown_content.split("\n")
    html_lines = []

    for line in lines:
        line = line.strip()
        if not line:
            continue

        # 标题
        if line.startswith("#"):
            level = len(line.split()[0])  # 计算#的数量
            text = line.lstrip("#").strip()
            html_lines.append(f"<h{level}>{text}</h{level}>")
        # 无序列表
        elif line.startswith("- ") or line.startswith("* "):
            text = line[2:].strip()
            html_lines.append(f"<li>{text}</li>")
        # 有序列表
        elif line[0].isdigit() and line[1:3] == ". ":
            text = line[3:].strip()
            html_lines.append(f"<li>{text}</li>")
        # 代码块
        elif line.startswith("```"):
            if "```" in line[3:]:
                html_lines.append("<code>" + line[3:-3] + "</code>")
            else:
                # 多行代码块开始/结束
                html_lines.append("<pre><code>")
        # 普通段落
        else:
            html_lines.append(f"<p>{line}</p>")

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
