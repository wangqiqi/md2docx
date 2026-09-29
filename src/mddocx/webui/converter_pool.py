"""WebUI 转换器复用池。

``BaseConverter`` 的构造要建 MarkdownIt 解析器与 13 个元素转换器（实测 ~6ms），
而它的 ``_reset_state`` 已支持逐次转换复用。转换器自身持有可变状态，不能跨线程
共享，因此用线程局部实例：同一线程的后续请求直接复用，不同线程互不干扰。
"""

import threading

from ..converter import BaseConverter

_local = threading.local()


def get_converter() -> BaseConverter:
    """返回当前线程复用的 BaseConverter 实例。"""
    converter = getattr(_local, "converter", None)
    if converter is None:
        converter = BaseConverter()
        _local.converter = converter
    return converter


def reset_converter_pool() -> None:
    """测试用：丢弃当前线程缓存的转换器。"""
    _local.converter = None
