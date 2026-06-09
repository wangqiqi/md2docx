"""
统一用户可见错误码与消息（CLI / WebUI 共用）。
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

from .converter.base import ConvertError, MD2DocxError, ParseError


@dataclass(frozen=True)
class ErrorInfo:
    code: str
    message: str

    def format_user(self) -> str:
        return f"[{self.code}] {self.message}"


# 错误码常量
E_INPUT_NOT_FOUND = "E_INPUT_NOT_FOUND"
E_INPUT_INVALID = "E_INPUT_INVALID"
E_INPUT_ENCODING = "E_INPUT_ENCODING"
E_CONTENT_EMPTY = "E_CONTENT_EMPTY"
E_CONTENT_TOO_LARGE = "E_CONTENT_TOO_LARGE"
E_FILE_TYPE_INVALID = "E_FILE_TYPE_INVALID"
E_CONVERT_FAILED = "E_CONVERT_FAILED"
E_PARSE_FAILED = "E_PARSE_FAILED"
E_SAVE_FAILED = "E_SAVE_FAILED"
E_MEMORY = "E_MEMORY"
E_RATE_LIMIT = "E_RATE_LIMIT"
E_PREVIEW_FAILED = "E_PREVIEW_FAILED"
E_SERVER_ERROR = "E_SERVER_ERROR"

_MESSAGES = {
    E_INPUT_NOT_FOUND: "输入文件不存在",
    E_INPUT_INVALID: "输入路径无效",
    E_INPUT_ENCODING: "文件编码错误，请使用 UTF-8",
    E_CONTENT_EMPTY: "请输入 Markdown 内容或上传文件",
    E_CONTENT_TOO_LARGE: "内容过大，请分批处理",
    E_FILE_TYPE_INVALID: "文件类型不支持或文件内容无效",
    E_CONVERT_FAILED: "转换失败，请检查内容格式",
    E_PARSE_FAILED: "Markdown 解析失败",
    E_SAVE_FAILED: "无法保存文件，请关闭占用该文件的应用后重试",
    E_MEMORY: "文件过大，内存不足",
    E_RATE_LIMIT: "请求过于频繁，请稍后再试",
    E_PREVIEW_FAILED: "预览生成失败，请稍后重试",
    E_SERVER_ERROR: "服务器内部错误，请稍后重试",
}


def error_info(code: str, message: Optional[str] = None) -> ErrorInfo:
    return ErrorInfo(code=code, message=message or _MESSAGES.get(code, "未知错误"))


def error_from_exception(exc: Exception) -> ErrorInfo:
    from .converter.security import MarkdownTooLargeError

    if isinstance(exc, MarkdownTooLargeError):
        return error_info(E_CONTENT_TOO_LARGE, str(exc) or None)
    if isinstance(exc, FileNotFoundError):
        return error_info(E_INPUT_NOT_FOUND, str(exc) or None)
    if isinstance(exc, PermissionError):
        return error_info(E_SAVE_FAILED, str(exc) or None)
    if isinstance(exc, UnicodeDecodeError):
        return error_info(E_INPUT_ENCODING)
    if isinstance(exc, MemoryError):
        return error_info(E_MEMORY)
    if isinstance(exc, ParseError):
        return error_info(E_PARSE_FAILED, str(exc) or None)
    if isinstance(exc, ConvertError):
        return error_info(E_CONVERT_FAILED, str(exc) or None)
    if isinstance(exc, MD2DocxError):
        return error_info(E_CONVERT_FAILED, str(exc) or None)
    if isinstance(exc, ValueError):
        return error_info(E_INPUT_INVALID, str(exc) or None)
    return error_info(E_CONVERT_FAILED, str(exc) or None)
