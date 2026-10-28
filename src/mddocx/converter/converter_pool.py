"""进程内转换器复用池。

``BaseConverter`` 构造约数毫秒；``_reset_state`` 已支持逐次转换复用。
转换器含可变状态，不能跨线程共享，故用 thread-local：同线程后续请求复用。
``debug=True`` 时每次返回新实例，便于 CLI 调试输出。
"""

from __future__ import annotations

import threading

from .base import BaseConverter

_local = threading.local()


def get_converter(*, debug: bool = False) -> BaseConverter:
    """返回可复用的 BaseConverter（debug 模式不复用）。"""
    if debug:
        return BaseConverter(debug=True)
    converter = getattr(_local, "converter", None)
    if converter is None:
        converter = BaseConverter()
        _local.converter = converter
    return converter


def reset_converter_pool() -> None:
    """测试用：丢弃当前线程缓存的转换器。"""
    _local.converter = None
