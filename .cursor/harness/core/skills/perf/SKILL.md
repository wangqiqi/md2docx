---
name: perf
description: 性能排查 — 测量优先、瓶颈清单。
---

# perf

## 顺序

1. **测量**：profiler、慢查询日志、LCP/FCP（前端）
2. **假设** → 改一处 → 再测
3. 文档化前后数据

## 常见瓶颈

- N+1 查询；缺索引
- 同步 I/O 在 hot path
- 过大 bundle / 无 code split（见 `rules/tech/nextjs.mdc` SSR 节）

## 输出

- 瓶颈位置 file:line
- 建议与 trade-off；不 premature optimize
