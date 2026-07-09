"""转换可观测性指标（程序可读出口）。"""

from dataclasses import dataclass


@dataclass(frozen=True)
class ConvertMetrics:
    """单次 convert / convert_file 的指标快照。

    字段与结构化日志 ``convert_done`` 对齐：
    - duration_ms: 墙钟耗时（毫秒）
    - input_bytes: Markdown UTF-8 字节数
    - chunked: 是否走分块转换路径
    """

    duration_ms: float
    input_bytes: int
    chunked: bool
