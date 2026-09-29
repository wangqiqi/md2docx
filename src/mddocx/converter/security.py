"""
图片与 URL 安全校验工具
"""

import ipaddress
import socket
from pathlib import Path
from typing import Callable, Optional, Set
from urllib.parse import urljoin, urlparse

import requests

# 允许下载的最大图片大小（10MB）
MAX_IMAGE_BYTES = 10 * 1024 * 1024

# Markdown 源文最大体积（与 WebUI MAX_CONTENT_LENGTH 对齐）
MAX_MARKDOWN_BYTES = 16 * 1024 * 1024

# 超过此 UTF-8 字节数时自动按一级标题分块转换
CHUNKED_THRESHOLD = 512 * 1024

# 图片缓存最大条目数
MAX_IMAGE_CACHE_ENTRIES = 64

# 图片缓存总字节上限（64 × 10MB 条目上限过宽，这里再兜一层内存）
MAX_IMAGE_CACHE_BYTES = 64 * 1024 * 1024

MERMAID_INK_HOST = "mermaid.ink"
CODECOGS_HOST = "latex.codecogs.com"
MAX_CODECOGS_URL_LEN = 8192

# 远程资源下载的最大跳转次数与跳转状态码
MAX_REDIRECTS = 3
_REDIRECT_STATUSES = frozenset({301, 302, 303, 307, 308})


class MarkdownTooLargeError(Exception):
    """Markdown 文本或文件超过 MAX_MARKDOWN_BYTES。"""

    def __init__(self, size: int, limit: int = MAX_MARKDOWN_BYTES) -> None:
        self.size = size
        self.limit = limit
        super().__init__(f"Markdown 内容过大: {size} 字节，上限 {limit} 字节")


def markdown_utf8_byte_size(text: str) -> int:
    """返回 Markdown 文本的 UTF-8 字节长度。"""
    return len(text.encode("utf-8"))


def validate_markdown_size(text: str) -> int:
    """校验 Markdown 体积；超限抛出 MarkdownTooLargeError。"""
    size = markdown_utf8_byte_size(text)
    if size > MAX_MARKDOWN_BYTES:
        raise MarkdownTooLargeError(size)
    return size


def stream_file_byte_size(path: Path, limit: int = MAX_MARKDOWN_BYTES) -> int:
    """流式统计文件字节数；超过 limit 时立即抛出 MarkdownTooLargeError。"""
    size = 0
    with open(path, "rb") as handle:
        while True:
            block = handle.read(8192)
            if not block:
                break
            size += len(block)
            if size > limit:
                raise MarkdownTooLargeError(size, limit)
    return size


def is_allowed_codecogs_url(url: str) -> bool:
    """校验 CodeCogs LaTeX 渲染 URL（仅允许固定服务域名与路径）"""
    try:
        parsed = urlparse(url)
    except Exception:
        return False
    if len(url) > MAX_CODECOGS_URL_LEN:
        return False
    return (
        parsed.scheme == "https"
        and (parsed.hostname or "").lower() == CODECOGS_HOST
        and parsed.path.startswith("/png.latex")
    )


def is_allowed_mermaid_ink_url(url: str) -> bool:
    """校验 mermaid.ink 渲染 URL（仅允许固定服务域名）"""
    try:
        parsed = urlparse(url)
    except Exception:
        return False
    return (
        parsed.scheme == "https"
        and (parsed.hostname or "").lower() == MERMAID_INK_HOST
        and parsed.path.startswith("/img/")
    )


_BLOCKED_HOSTNAMES: Set[str] = {
    "localhost",
    "localhost.localdomain",
    "metadata.google.internal",
}


def is_private_ip(ip_str: str) -> bool:
    """判断 IP 是否为私有/保留地址"""
    try:
        ip = ipaddress.ip_address(ip_str)
    except ValueError:
        return False
    return ip.is_private or ip.is_loopback or ip.is_link_local or ip.is_reserved or ip.is_multicast


def is_safe_remote_url(url: str) -> bool:
    """校验远程图片 URL，防止 SSRF"""
    try:
        parsed = urlparse(url)
    except Exception:
        return False

    if parsed.scheme not in ("http", "https"):
        return False

    hostname = (parsed.hostname or "").lower()
    if not hostname:
        return False

    if hostname in _BLOCKED_HOSTNAMES:
        return False

    # 字面量 IP
    try:
        if is_private_ip(hostname):
            return False
    except ValueError:
        pass

    # 域名解析后检查
    try:
        for info in socket.getaddrinfo(hostname, None):
            addr = info[4][0]
            if is_private_ip(str(addr)):
                return False
    except socket.gaierror:
        return False

    return True


def _read_limited(response: "requests.Response", max_bytes: int) -> Optional[bytes]:
    """流式读取响应体；超过 max_bytes 立即放弃。"""
    chunks = []
    total = 0
    for chunk in response.iter_content(chunk_size=8192):
        total += len(chunk)
        if total > max_bytes:
            return None
        chunks.append(chunk)
    return b"".join(chunks)


def fetch_remote_bytes(
    url: str,
    *,
    validator: Callable[[str], bool],
    timeout: float = 10.0,
    max_bytes: int = MAX_IMAGE_BYTES,
    content_type_prefix: Optional[str] = None,
    max_redirects: int = MAX_REDIRECTS,
) -> Optional[bytes]:
    """下载远程资源，对每一跳重定向都重新做 URL 校验。

    直接跟随重定向会让一个通过校验的公网 URL 302 到内网 / 云元数据地址
    （SSRF），因此这里手动逐跳跟随并对新 URL 再次调用 ``validator``；跳转次数
    超过 ``max_redirects`` 或任一步失败都返回 None。

    Args:
        url: 初始 URL
        validator: URL 白名单校验函数（如 ``is_safe_remote_url`` / 固定域名校验）
        timeout: 单次请求超时秒数
        max_bytes: 响应体上限
        content_type_prefix: 非空时要求 Content-Type 含该子串（如 ``image``）
        max_redirects: 最大跳转次数
    """
    current = url
    for _ in range(max_redirects + 1):
        if not validator(current):
            return None
        try:
            response = requests.get(current, timeout=timeout, stream=True, allow_redirects=False)
        except Exception:
            return None
        try:
            if response.status_code in _REDIRECT_STATUSES:
                location = response.headers.get("Location")
                if not location:
                    return None
                current = urljoin(current, location)
                continue
            if response.status_code != 200:
                return None
            content_type = response.headers.get("Content-Type", "")
            if content_type_prefix and content_type and content_type_prefix not in content_type:
                return None
            content_length = response.headers.get("Content-Length")
            if content_length:
                try:
                    if int(content_length) > max_bytes:
                        return None
                except (TypeError, ValueError):
                    pass
            return _read_limited(response, max_bytes)
        except Exception:
            return None
        finally:
            response.close()
    return None


def resolve_safe_local_path(
    src: str,
    base_dir: Optional[Path] = None,
    extra_allowed_dirs: Optional[Set[Path]] = None,
) -> Optional[Path]:
    """解析并校验本地图片路径，防止路径遍历

    Args:
        src: Markdown 中的图片路径
        base_dir: Markdown 源文件所在目录（CLI 场景）
        extra_allowed_dirs: 额外允许的根目录（如测试样例目录）

    Returns:
        校验通过后的绝对路径，失败返回 None
    """
    if not src or src.startswith(("http://", "https://", "data:")):
        return None

    # 拒绝绝对路径与父目录跳转
    if Path(src).is_absolute() or ".." in Path(src).parts:
        return None

    allowed_roots: list[Path] = []
    if base_dir is not None:
        allowed_roots.append(Path(base_dir).resolve())
    if extra_allowed_dirs:
        allowed_roots.extend(d.resolve() for d in extra_allowed_dirs)

    if not allowed_roots:
        return None

    for root in allowed_roots:
        try:
            candidate = (root / src).resolve()
            if not candidate.is_file():
                continue
            candidate.relative_to(root)
            return candidate
        except (OSError, ValueError):
            continue

    return None
