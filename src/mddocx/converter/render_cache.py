"""渲染结果缓存（Mermaid / LaTeX 共用）。

按源码 key 缓存渲染出的图片字节，避免同一文档（或同一 WebUI 线程的后续请求）
里重复的网络渲染。条目数与总字节数都有上限，超限按 LRU 淘汰。
"""

from __future__ import annotations

from collections import OrderedDict
from typing import Optional

# 默认上限：64 条 / 32MB（单张图最大 10MB）
DEFAULT_MAX_ENTRIES = 64
DEFAULT_MAX_BYTES = 32 * 1024 * 1024


class RenderCache:
    """按 key 缓存的 LRU 字节缓存。"""

    def __init__(
        self,
        max_entries: int = DEFAULT_MAX_ENTRIES,
        max_bytes: int = DEFAULT_MAX_BYTES,
    ) -> None:
        self._max_entries = max(1, max_entries)
        self._max_bytes = max(1, max_bytes)
        self._entries: "OrderedDict[str, bytes]" = OrderedDict()
        self._total_bytes = 0

    def get(self, key: str) -> Optional[bytes]:
        """取缓存并标记为最近使用；未命中返回 None。"""
        data = self._entries.get(key)
        if data is None:
            return None
        self._entries.move_to_end(key)
        return data

    def put(self, key: str, data: bytes) -> None:
        """写入缓存（空数据忽略），必要时淘汰最久未使用的条目。"""
        if not data:
            return
        if key in self._entries:
            self._total_bytes -= len(self._entries.pop(key))
        self._entries[key] = data
        self._total_bytes += len(data)
        while self._entries and (len(self._entries) > self._max_entries or self._total_bytes > self._max_bytes):
            _, evicted = self._entries.popitem(last=False)
            self._total_bytes -= len(evicted)

    def clear(self) -> None:
        """清空缓存。"""
        self._entries.clear()
        self._total_bytes = 0

    def __len__(self) -> int:
        return len(self._entries)
