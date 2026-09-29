"""渲染缓存（LRU）单元测试。"""

from mddocx.converter.render_cache import RenderCache


class TestRenderCache:
    def test_get_put_roundtrip(self):
        cache = RenderCache()
        cache.put("a", b"data-a")
        assert cache.get("a") == b"data-a"

    def test_miss_returns_none(self):
        assert RenderCache().get("missing") is None

    def test_empty_payload_not_cached(self):
        cache = RenderCache()
        cache.put("a", b"")
        assert cache.get("a") is None
        assert len(cache) == 0

    def test_evicts_least_recently_used(self):
        cache = RenderCache(max_entries=2)
        cache.put("a", b"1")
        cache.put("b", b"2")
        # 访问 a 使其变为最近使用，b 成为最久未使用
        assert cache.get("a") == b"1"
        cache.put("c", b"3")

        assert cache.get("a") == b"1"
        assert cache.get("b") is None
        assert cache.get("c") == b"3"

    def test_evicts_when_total_bytes_exceeded(self):
        cache = RenderCache(max_entries=10, max_bytes=10)
        cache.put("a", b"x" * 6)
        cache.put("b", b"y" * 6)

        assert cache.get("a") is None
        assert cache.get("b") == b"y" * 6

    def test_oversized_single_entry_is_dropped(self):
        cache = RenderCache(max_bytes=4)
        cache.put("a", b"x" * 5)
        assert len(cache) == 0

    def test_put_same_key_replaces_size(self):
        cache = RenderCache(max_entries=2, max_bytes=100)
        cache.put("a", b"x" * 10)
        cache.put("a", b"x" * 3)
        assert len(cache) == 1
        assert cache.get("a") == b"x" * 3

    def test_clear(self):
        cache = RenderCache()
        cache.put("a", b"1")
        cache.clear()
        assert cache.get("a") is None
