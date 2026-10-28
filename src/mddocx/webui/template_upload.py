"""Optional Word template uploads for WebUI convert routes."""

from __future__ import annotations

import os
import tempfile
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator, Optional

from werkzeug.datastructures import FileStorage
from werkzeug.utils import secure_filename

from ..errors import E_CONTENT_TOO_LARGE, E_FILE_TYPE_INVALID, error_info

_TEMPLATE_SUFFIXES = {".docx", ".dotx"}
DEFAULT_MAX_TEMPLATE_BYTES = 5 * 1024 * 1024


class TemplateUploadError(Exception):
    """Invalid or oversize template upload."""

    def __init__(self, code: str, message: Optional[str] = None):
        info = error_info(code, message)
        self.code = info.code
        self.message = info.message
        super().__init__(info.format_user())


def is_allowed_template_filename(filename: str) -> bool:
    name = (filename or "").lower()
    return any(name.endswith(suffix) for suffix in _TEMPLATE_SUFFIXES)


def save_template_upload(
    upload: FileStorage,
    *,
    max_bytes: int = DEFAULT_MAX_TEMPLATE_BYTES,
) -> str:
    """Persist upload to a temp path; caller must unlink."""
    if not upload or not upload.filename:
        raise TemplateUploadError(E_FILE_TYPE_INVALID, "未选择模板文件")

    filename = secure_filename(upload.filename)
    if not is_allowed_template_filename(filename):
        raise TemplateUploadError(E_FILE_TYPE_INVALID, "模板须为 .docx 或 .dotx")

    suffix = Path(filename).suffix.lower() or ".docx"
    fd, path = tempfile.mkstemp(suffix=suffix, prefix="md2docx_tpl_")
    written = 0
    try:
        with os.fdopen(fd, "wb") as handle:
            while True:
                chunk = upload.stream.read(1024 * 64)
                if not chunk:
                    break
                written += len(chunk)
                if written > max_bytes:
                    raise TemplateUploadError(
                        E_CONTENT_TOO_LARGE,
                        f"模板文件不能超过 {max_bytes // (1024 * 1024)}MB",
                    )
                handle.write(chunk)
    except Exception:
        try:
            os.unlink(path)
        except FileNotFoundError:
            pass
        raise

    return path


@contextmanager
def optional_template_path(
    upload: Optional[FileStorage],
    *,
    max_bytes: int = DEFAULT_MAX_TEMPLATE_BYTES,
) -> Iterator[Optional[str]]:
    """Yield temp template path or None; delete temp file on exit."""
    path: Optional[str] = None
    try:
        if upload and upload.filename:
            path = save_template_upload(upload, max_bytes=max_bytes)
        yield path
    finally:
        if path:
            try:
                os.unlink(path)
            except FileNotFoundError:
                pass
