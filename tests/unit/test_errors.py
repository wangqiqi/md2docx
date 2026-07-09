"""统一错误码测试"""

from mddocx.converter.base import ConvertError, MD2DocxError, ParseError
from mddocx.errors import (
    E_CONTENT_EMPTY,
    E_CONTENT_TOO_LARGE,
    E_CONVERT_FAILED,
    E_INPUT_ENCODING,
    E_INPUT_INVALID,
    E_INPUT_NOT_FOUND,
    E_MEMORY,
    E_PARSE_FAILED,
    E_RATE_LIMIT,
    E_SAVE_FAILED,
    error_from_exception,
    error_info,
)


def test_error_info_default_message():
    info = error_info(E_CONTENT_EMPTY)
    assert info.code == E_CONTENT_EMPTY
    assert "Markdown" in info.message
    assert info.format_user().startswith("[E_CONTENT_EMPTY]")


def test_error_from_file_not_found():
    info = error_from_exception(FileNotFoundError("missing.md"))
    assert info.code == E_INPUT_NOT_FOUND


def test_error_from_parse_error():
    info = error_from_exception(ParseError("bad token"))
    assert info.code == E_PARSE_FAILED


def test_error_from_convert_error():
    info = error_from_exception(ConvertError("boom"))
    assert info.code == E_CONVERT_FAILED


def test_rate_limit_code():
    info = error_info(E_RATE_LIMIT)
    assert "频繁" in info.format_user()


def test_error_from_permission_error():
    info = error_from_exception(PermissionError("locked"))
    assert info.code == E_SAVE_FAILED


def test_error_from_unicode_decode():
    info = error_from_exception(UnicodeDecodeError("utf-8", b"\xff", 0, 1, "bad"))
    assert info.code == E_INPUT_ENCODING


def test_error_from_memory_error():
    info = error_from_exception(MemoryError())
    assert info.code == E_MEMORY


def test_error_from_md2docx_error():
    info = error_from_exception(MD2DocxError("core"))
    assert info.code == E_CONVERT_FAILED


def test_error_from_value_error():
    info = error_from_exception(ValueError("bad path"))
    assert info.code == E_INPUT_INVALID


def test_error_from_markdown_too_large():
    from mddocx.converter.security import MarkdownTooLargeError

    info = error_from_exception(MarkdownTooLargeError(20_000_000))
    assert info.code == E_CONTENT_TOO_LARGE
