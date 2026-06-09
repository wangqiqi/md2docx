"""WebUI 简易 per-IP 请求限流（内存窗口）。"""

import time
from collections import defaultdict, deque
from typing import Deque, Dict

MAX_REQUESTS = 30
WINDOW_SECONDS = 60

_requests: Dict[str, Deque[float]] = defaultdict(deque)


def is_rate_limited(client_ip: str) -> bool:
    """超过窗口内请求上限返回 True。"""
    now = time.time()
    window = _requests[client_ip]
    while window and window[0] < now - WINDOW_SECONDS:
        window.popleft()
    if len(window) >= MAX_REQUESTS:
        return True
    window.append(now)
    return False


def reset_rate_limits() -> None:
    """测试用：清空限流状态。"""
    _requests.clear()
