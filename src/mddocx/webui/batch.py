"""WebUI 批量转换：逐文件处理并打包 ZIP。"""

from __future__ import annotations

import io
import json
import os
import tempfile
import uuid
import zipfile
from dataclasses import dataclass
from typing import Callable, List, Optional, Sequence, Tuple

from werkzeug.datastructures import FileStorage
from werkzeug.utils import secure_filename

from ..converter import BaseConverter
from ..errors import (
    E_CONTENT_EMPTY,
    E_CONTENT_TOO_LARGE,
    E_FILE_TYPE_INVALID,
    E_INPUT_ENCODING,
    E_MEMORY,
    error_from_exception,
    error_info,
)


@dataclass(frozen=True)
class BatchFileError:
    filename: str
    code: str
    message: str

    def to_dict(self) -> dict:
        return {"filename": self.filename, "code": self.code, "message": self.message}


@dataclass(frozen=True)
class BatchZipResult:
    zip_bytes: bytes
    total: int
    succeeded: int
    failed: int
    errors: Tuple[BatchFileError, ...]


class BatchRequestError(Exception):
    """整批请求级错误（未进入逐文件转换）。"""

    def __init__(self, code: str, message: Optional[str] = None, status: int = 400):
        info = error_info(code, message)
        self.code = info.code
        self.message = info.message
        self.status = status
        super().__init__(info.format_user())


def _unique_docx_name(original: str, used: set[str]) -> str:
    safe = secure_filename(original) or "file.md"
    stem = safe.rsplit(".", 1)[0] if "." in safe else safe
    name = f"{stem}.docx"
    if name not in used:
        used.add(name)
        return name
    index = 2
    while True:
        candidate = f"{stem}_{index}.docx"
        if candidate not in used:
            used.add(candidate)
            return candidate
        index += 1


def _read_upload_text(
    upload: FileStorage,
    *,
    max_text_size: int,
    allowed_file: Callable[..., bool],
) -> Tuple[Optional[str], Optional[BatchFileError]]:
    filename = secure_filename(upload.filename or "") or "unknown"
    if not upload.filename:
        info = error_info(E_CONTENT_EMPTY, "没有选择文件")
        return None, BatchFileError(filename, info.code, info.message)

    if not allowed_file(upload.filename, upload):
        info = error_info(E_FILE_TYPE_INVALID)
        return None, BatchFileError(filename, info.code, info.message)

    try:
        content = upload.read().decode("utf-8")
    except UnicodeDecodeError:
        info = error_info(E_INPUT_ENCODING)
        return None, BatchFileError(filename, info.code, info.message)

    if not content.strip():
        info = error_info(E_CONTENT_EMPTY)
        return None, BatchFileError(filename, info.code, info.message)

    if len(content) > max_text_size:
        info = error_info(E_CONTENT_TOO_LARGE)
        return None, BatchFileError(filename, info.code, info.message)

    return content, None


def _convert_one(content: str, filename: str) -> Tuple[Optional[bytes], Optional[BatchFileError]]:
    try:
        doc = BaseConverter().convert(content)
        temp_name = f"md2docx_batch_{uuid.uuid4().hex}.docx"
        temp_path = os.path.join(tempfile.gettempdir(), temp_name)
        try:
            doc.save(temp_path)
            with open(temp_path, "rb") as handle:
                return handle.read(), None
        finally:
            try:
                if os.path.exists(temp_path):
                    os.unlink(temp_path)
            except OSError:
                pass
    except MemoryError:
        info = error_info(E_MEMORY)
        return None, BatchFileError(filename, info.code, info.message)
    except Exception as exc:
        info = error_from_exception(exc)
        return None, BatchFileError(filename, info.code, info.message)


def build_batch_zip(
    files: Sequence[FileStorage],
    *,
    max_batch_files: int,
    max_text_size: int,
    allowed_file: Callable[..., bool],
) -> BatchZipResult:
    uploads = [item for item in files if item and item.filename]
    if not uploads:
        raise BatchRequestError(E_CONTENT_EMPTY)

    if len(uploads) > max_batch_files:
        raise BatchRequestError(
            E_CONTENT_TOO_LARGE,
            f"单次最多上传 {max_batch_files} 个文件",
            status=413,
        )

    errors: List[BatchFileError] = []
    used_names: set[str] = set()
    buffer = io.BytesIO()

    with zipfile.ZipFile(buffer, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        succeeded = 0
        for upload in uploads:
            display_name = secure_filename(upload.filename or "") or "unknown"
            content, read_error = _read_upload_text(
                upload,
                max_text_size=max_text_size,
                allowed_file=allowed_file,
            )
            if read_error is not None:
                errors.append(read_error)
                continue

            docx_bytes, convert_error = _convert_one(content, display_name)
            if convert_error is not None:
                errors.append(convert_error)
                continue

            archive.writestr(_unique_docx_name(display_name, used_names), docx_bytes)
            succeeded += 1

        total = len(uploads)
        failed = len(errors)
        if errors:
            payload = {
                "errors": [item.to_dict() for item in errors],
                "summary": {"total": total, "succeeded": succeeded, "failed": failed},
            }
            archive.writestr("batch_errors.json", json.dumps(payload, ensure_ascii=False, indent=2))

    return BatchZipResult(
        zip_bytes=buffer.getvalue(),
        total=len(uploads),
        succeeded=succeeded,
        failed=len(errors),
        errors=tuple(errors),
    )
