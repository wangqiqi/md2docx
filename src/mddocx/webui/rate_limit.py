"""WebUI 简易 per-IP 请求限流（内存窗口）。"""

import time
from collections import defaultdict, deque
from typing import Deque, Dict

MAX_REQUESTS = 30
WINDOW_SECONDS = 60
# 跟踪的客户端上限；超过后清理窗口已过期的条目，避免字典随访问 IP 无限增长
MAX_TRACKED_CLIENTS = 10000

_requests: Dict[str, Deque[float]] = defaultdict(deque)


def _is_stale(window: Deque[float], now: float) -> bool:
    """窗口为空或最后一次请求已滑出窗口。"""
    return not window or window[-1] < now - WINDOW_SECONDS


def _evict_stale(now: float) -> int:
    """删除窗口已过期的客户端条目，返回删除数量。"""
    stale = [client_ip for client_ip, window in _requests.items() if _is_stale(window, now)]
    for client_ip in stale:
        del _requests[client_ip]
    return len(stale)


def is_rate_limited(client_ip: str) -> bool:
    """超过窗口内请求上限返回 True。"""
    now = time.time()
    window = _requests[client_ip]
    while window and window[0] < now - WINDOW_SECONDS:
        window.popleft()
    if len(window) >= MAX_REQUESTS:
        return True
    window.append(now)
    if len(_requests) > MAX_TRACKED_CLIENTS:
        _evict_stale(now)
    return False


def tracked_clients() -> int:
    """当前跟踪的客户端数量（测试 / 监控用）。"""
    return len(_requests)


def reset_rate_limits() -> None:
    """测试用：清空限流状态。"""
    _requests.clear()
