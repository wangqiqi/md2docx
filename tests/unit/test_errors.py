"""统一错误码测试"""

from mddocx.converter.base import ConvertError, ParseError
from mddocx.errors import (
    E_CONTENT_EMPTY,
    E_CONVERT_FAILED,
    E_INPUT_NOT_FOUND,
    E_PARSE_FAILED,
    E_RATE_LIMIT,
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
