"""
图片与 URL 安全校验工具
"""

import ipaddress
import socket
from pathlib import Path
from typing import Optional, Set
from urllib.parse import urlparse

# 允许下载的最大图片大小（10MB）
MAX_IMAGE_BYTES = 10 * 1024 * 1024

# 图片缓存最大条目数
MAX_IMAGE_CACHE_ENTRIES = 64

MERMAID_INK_HOST = "mermaid.ink"


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
    return (
        ip.is_private
        or ip.is_loopback
        or ip.is_link_local
        or ip.is_reserved
        or ip.is_multicast
    )


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
            if is_private_ip(addr):
                return False
    except socket.gaierror:
        return False

    return True


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
