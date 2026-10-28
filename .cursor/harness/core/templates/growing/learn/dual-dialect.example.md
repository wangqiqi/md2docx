# 双方言数据访问（项目特化 · 示例）

> 开发/测试用 **方言 A**，生产用 **方言 B**（常见：SQLite + PostgreSQL）。  
> 复制到 `.growing/learn/` 并链 `rules/local/dual-dialect.example.mdc`（若采用）。

## 原则

1. **翻译器清单有限** — 清单外的方言习语在 **SQL 源头**收敛，不为单条查询扩正则翻译。
2. **数组/列表参数** — 用 IN 展开占位符，勿传单个绑定到整段数组。
3. **时间窗** — cutoff 在应用层算好再传参；避免 `now() - interval` 等方言专属写法。
4. **测试** — 两方言各有一条语义断言；注意「缺参静默 NULL」类驱动陷阱。

## 落点

| 项 | 路径 |
|----|------|
| 翻译/注册 | `server/lib/db.*`（示例名） |
| 规则 | `.growing/rules/local/dual-dialect.example.mdc` |
| 证据 | CHANGELOG · archive |
