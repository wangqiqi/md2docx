"""
Flask Web应用
提供Markdown转DOCX的Web界面
"""

import io
import json
import logging
import mimetypes
import os
import re
import tempfile
import uuid
from html import escape
from typing import Optional
from urllib.parse import quote

import bleach
from flask import Flask, flash, jsonify, redirect, render_template, request, send_file, url_for
from flask_wtf.csrf import CSRFProtect
from markdown_it import MarkdownIt
from mdit_py_plugins.dollarmath import dollarmath_plugin
from werkzeug.utils import secure_filename

from ..converter import BaseConverter
from ..errors import (
    E_CONTENT_EMPTY,
    E_CONTENT_TOO_LARGE,
    E_FILE_TYPE_INVALID,
    E_INPUT_ENCODING,
    E_MEMORY,
    E_PREVIEW_FAILED,
    E_RATE_LIMIT,
    E_SERVER_ERROR,
    error_from_exception,
    error_info,
)
from .config import get_config

# 与转换器保持一致的 Markdown 解析配置
ALLOWED_PREVIEW_TAGS = [
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "p",
    "br",
    "hr",
    "ul",
    "ol",
    "li",
    "strong",
    "em",
    "del",
    "code",
    "pre",
    "blockquote",
    "table",
    "thead",
    "tbody",
    "tr",
    "th",
    "td",
    "a",
    "img",
    "span",
    "div",
]
ALLOWED_PREVIEW_ATTRS = {
    "*": ["class"],
    "a": ["href", "title", "target", "rel"],
    "img": ["src", "alt", "title", "width", "height"],
}


def create_markdown_parser() -> MarkdownIt:
    """创建与 BaseConverter 一致的 Markdown 解析器"""
    return (
        MarkdownIt("commonmark", {"breaks": True, "html": True})
        .enable("strikethrough")
        .enable("emphasis")
        .enable("table")
        .use(dollarmath_plugin)
    )


md = create_markdown_parser()

logging.basicConfig(level=logging.INFO)

config = get_config()

app = Flask(__name__)
app.config.from_object(config)
app.config.setdefault("WTF_CSRF_TIME_LIMIT", None)

csrf = CSRFProtect(app)

app.logger.setLevel(logging.INFO if not config.DEBUG else logging.DEBUG)


def parse_user_error(message: str) -> dict:
    """将 ``[E_*] message`` 拆为模板可读字段，并保留原始文本。"""
    match = re.match(r"^\[(E_[A-Z0-9_]+)\]\s*(.*)$", message, re.DOTALL)
    if match is None:
        return {"code": "", "message": message, "raw": message}
    return {
        "code": match.group(1),
        "message": match.group(2),
        "raw": message,
    }


app.jinja_env.globals["parse_user_error"] = parse_user_error


def allowed_file(filename, file_obj=None):
    """验证文件是否允许上传"""
    if "." not in filename:
        return False

    ext = filename.rsplit(".", 1)[1].lower()
    if ext not in config.ALLOWED_EXTENSIONS:
        return False

    if file_obj:
        mime_type = mimetypes.guess_type(filename)[0]
        if mime_type and mime_type not in config.ALLOWED_MIME_TYPES:
            file_obj.seek(0)
            file_header = file_obj.read(512)
            file_obj.seek(0)
            try:
                file_header.decode("utf-8")
            except UnicodeDecodeError:
                return False

    return True


@app.route("/")
def index():
    """主页"""
    return render_template("index.html")


def flash_error(code: str, message: Optional[str] = None) -> None:
    flash(error_info(code, message).format_user(), "error")


@app.route("/convert", methods=["POST"])
def convert():
    """转换处理"""
    from .rate_limit import is_rate_limited

    if is_rate_limited(request.remote_addr or "unknown"):
        flash_error(E_RATE_LIMIT)
        return redirect(url_for("index")), 429

    try:
        markdown_content = ""

        if "file" in request.files and request.files["file"].filename:
            file = request.files["file"]
            if file.filename == "":
                flash_error(E_CONTENT_EMPTY, "没有选择文件")
                return redirect(url_for("index"))

            filename = secure_filename(file.filename)

            if not allowed_file(filename, file):
                flash_error(E_FILE_TYPE_INVALID)
                return redirect(url_for("index"))

            try:
                markdown_content = file.read().decode("utf-8")
            except UnicodeDecodeError:
                flash_error(E_INPUT_ENCODING)
                return redirect(url_for("index"))
        else:
            markdown_content = request.form.get("markdown", "").strip()

        if not markdown_content:
            flash_error(E_CONTENT_EMPTY)
            return redirect(url_for("index"))

        if len(markdown_content) > config.MAX_TEXT_CONTENT_SIZE:
            flash_error(E_CONTENT_TOO_LARGE)
            return redirect(url_for("index"))

        doc = BaseConverter().convert(markdown_content)

        temp_filename = f"md2docx_{uuid.uuid4().hex}.docx"
        temp_dir = tempfile.gettempdir()
        docx_file_path = os.path.join(temp_dir, temp_filename)

        try:
            doc.save(docx_file_path)

            response = send_file(
                docx_file_path,
                as_attachment=True,
                download_name="converted.docx",
                mimetype="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            )

            @response.call_on_close
            def cleanup():
                try:
                    if os.path.exists(docx_file_path):
                        os.unlink(docx_file_path)
                except (OSError, IOError) as e:
                    app.logger.warning(f"清理临时文件失败: {e}")

            return response

        except Exception as save_error:
            try:
                if os.path.exists(docx_file_path):
                    os.unlink(docx_file_path)
            except (OSError, IOError):
                pass
            raise save_error

    except UnicodeDecodeError:
        flash_error(E_INPUT_ENCODING)
    except MemoryError:
        flash_error(E_MEMORY)
    except Exception as e:
        app.logger.error(f"转换失败: {str(e)}", exc_info=True)
        flash(error_from_exception(e).format_user(), "error")

    return redirect(url_for("index"))


@app.route("/convert/batch", methods=["POST"])
def convert_batch():
    """批量转换：多文件上传，返回 ZIP（含 batch_errors.json 失败清单）。"""
    from .batch import BatchRequestError, build_batch_zip
    from .rate_limit import is_rate_limited

    if is_rate_limited(request.remote_addr or "unknown"):
        info = error_info(E_RATE_LIMIT)
        return jsonify({"code": info.code, "message": info.message}), 429

    files = request.files.getlist("files")
    try:
        result = build_batch_zip(
            files,
            max_batch_files=config.MAX_BATCH_FILES,
            max_text_size=config.MAX_TEXT_CONTENT_SIZE,
            allowed_file=allowed_file,
        )
    except BatchRequestError as exc:
        return jsonify({"code": exc.code, "message": exc.message}), exc.status

    zip_buffer = io.BytesIO(result.zip_bytes)
    zip_buffer.seek(0)
    response = send_file(
        zip_buffer,
        as_attachment=True,
        download_name="batch_converted.zip",
        mimetype="application/zip",
    )
    summary = {
        "total": result.total,
        "succeeded": result.succeeded,
        "failed": result.failed,
    }
    response.headers["X-Batch-Summary"] = quote(json.dumps(summary, ensure_ascii=False, separators=(",", ":")))
    response.headers["X-Batch-Errors"] = quote(
        json.dumps(
            [item.to_dict() for item in result.errors],
            ensure_ascii=False,
            separators=(",", ":"),
        )
    )
    return response


@app.route("/preview", methods=["POST"])
def preview():
    """预览功能 - 只返回预览内容的HTML片段"""
    from .rate_limit import is_rate_limited

    if is_rate_limited(request.remote_addr or "unknown"):
        return _preview_error(error_info(E_RATE_LIMIT).format_user())

    try:
        markdown_content = ""
        if "file" in request.files and request.files["file"].filename:
            file = request.files["file"]
            filename = secure_filename(file.filename)

            if not allowed_file(filename, file):
                return _preview_error(error_info(E_FILE_TYPE_INVALID).format_user())

            try:
                markdown_content = file.read().decode("utf-8")
            except UnicodeDecodeError:
                return _preview_error(error_info(E_INPUT_ENCODING).format_user())
        else:
            markdown_content = request.form.get("markdown", "")

        if not markdown_content or len(markdown_content.strip()) == 0:
            return _preview_placeholder("请输入Markdown内容")

        if len(markdown_content) > config.MAX_PREVIEW_CONTENT_SIZE:
            return _preview_error(error_info(E_CONTENT_TOO_LARGE).format_user())

        preview_html = generate_preview_html(markdown_content.strip())
        return f'<div class="preview-result">' f'<div class="preview-content-rendered">{preview_html}</div>' f"</div>"

    except Exception as e:
        app.logger.error(f"预览失败: {str(e)}", exc_info=True)
        return _preview_error(error_info(E_PREVIEW_FAILED).format_user())


def _preview_error(message: str) -> str:
    return f"<div class='preview-error'>" f"<span class='icon'>❌</span><p>{escape(message)}</p></div>"


def _preview_placeholder(message: str) -> str:
    return f"<div class='preview-placeholder'>" f"<span class='icon'>👁️</span><p>{escape(message)}</p></div>"


def sanitize_preview_html(html_content: str) -> str:
    """消毒预览 HTML，防止 XSS"""
    return bleach.clean(
        html_content,
        tags=ALLOWED_PREVIEW_TAGS,
        attributes=ALLOWED_PREVIEW_ATTRS,
        strip=True,
    )


def generate_preview_html(markdown_content):
    """生成预览HTML"""
    html_content = md.render(markdown_content)
    safe_html = sanitize_preview_html(html_content)
    return (
        '<div class="markdown-preview" '
        "style=\"font-family: 'Arial', sans-serif; line-height: 1.6;\">"
        f"{safe_html}"
        "</div>"
    )


@app.errorhandler(413)
def too_large(e):
    """文件过大错误"""
    flash_error(E_CONTENT_TOO_LARGE, "文件大小超过限制 (16MB)")
    return redirect(url_for("index"))


@app.errorhandler(500)
def internal_error(e):
    """服务器错误"""
    app.logger.error(f"服务器错误: {str(e)}", exc_info=True)
    flash_error(E_SERVER_ERROR)
    return redirect(url_for("index"))


@app.after_request
def add_security_headers(response):
    """添加安全头"""
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "script-src 'self'; "
        "style-src 'self' 'unsafe-inline'; "
        "img-src 'self' data: https:; "
        "frame-ancestors 'none'"
    )
    return response


def main():
    """命令行入口点"""
    app.run(debug=config.DEBUG, host=config.HOST, port=config.PORT)


if __name__ == "__main__":
    main()
