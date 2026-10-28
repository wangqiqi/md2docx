"""WebUI 转换器池（复用 ``mddocx.converter.converter_pool``）。"""

from ..converter.converter_pool import get_converter, reset_converter_pool

__all__ = ["get_converter", "reset_converter_pool"]
