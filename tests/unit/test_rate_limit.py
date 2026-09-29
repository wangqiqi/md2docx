"""WebUI 限流窗口与客户端清理测试。"""

import pytest

from mddocx.webui import rate_limit


class _FakeClock:
    """只替换 rate_limit 模块内的 time.time，避免影响全局。"""

    def __init__(self, now: float = 1000.0) -> None:
        self.now = now

    def time(self) -> float:
        return self.now


@pytest.fixture
def clock(monkeypatch):
    fake = _FakeClock()
    monkeypatch.setattr(rate_limit, "time", fake)
    rate_limit.reset_rate_limits()
    yield fake
    rate_limit.reset_rate_limits()


class TestRateLimitWindow:
    def test_allows_up_to_limit_then_blocks(self, clock):
        client = "203.0.113.7"
        for _ in range(rate_limit.MAX_REQUESTS):
            assert rate_limit.is_rate_limited(client) is False

        assert rate_limit.is_rate_limited(client) is True

    def test_window_slides_and_frees_quota(self, clock):
        client = "203.0.113.7"
        for _ in range(rate_limit.MAX_REQUESTS):
            rate_limit.is_rate_limited(client)
        assert rate_limit.is_rate_limited(client) is True

        clock.now += rate_limit.WINDOW_SECONDS + 1

        assert rate_limit.is_rate_limited(client) is False

    def test_clients_are_independent(self, clock):
        for _ in range(rate_limit.MAX_REQUESTS):
            rate_limit.is_rate_limited("198.51.100.1")

        assert rate_limit.is_rate_limited("198.51.100.2") is False


class TestClientEviction:
    def test_stale_clients_evicted_when_over_cap(self, clock, monkeypatch):
        monkeypatch.setattr(rate_limit, "MAX_TRACKED_CLIENTS", 3)

        for index in range(3):
            assert rate_limit.is_rate_limited(f"10.0.0.{index}") is False
        assert rate_limit.tracked_clients() == 3

        # 让已跟踪的客户端窗口全部过期
        clock.now += rate_limit.WINDOW_SECONDS + 1

        assert rate_limit.is_rate_limited("10.0.0.99") is False

        assert rate_limit.tracked_clients() == 1

    def test_active_clients_are_kept(self, clock, monkeypatch):
        monkeypatch.setattr(rate_limit, "MAX_TRACKED_CLIENTS", 3)

        for index in range(3):
            rate_limit.is_rate_limited(f"10.0.0.{index}")

        # 未过期：清理不应误删活跃客户端
        assert rate_limit.is_rate_limited("10.0.0.99") is False
        assert rate_limit.tracked_clients() == 4

    def test_rate_limited_client_is_not_evicted_while_active(self, clock, monkeypatch):
        monkeypatch.setattr(rate_limit, "MAX_TRACKED_CLIENTS", 1)
        client = "10.0.0.5"
        for _ in range(rate_limit.MAX_REQUESTS):
            rate_limit.is_rate_limited(client)

        assert rate_limit.is_rate_limited(client) is True
        assert rate_limit.tracked_clients() == 1
