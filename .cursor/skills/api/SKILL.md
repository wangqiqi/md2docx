---
name: api
description: REST/OpenAPI 设计审查。
---

# api · 审查清单

契约变更须同 PR 更新 server + client + mocks（见 `rules/execution/api.mdc`）。

## URL 与资源

- [ ] 资源名词复数、小写、kebab-case（`/users` 非 `/getUsers`）
- [ ] 嵌套 ≤2 层；深嵌套改 query 或独立资源
- [ ] 版本策略一致（`/v1/` 或 header，全项目统一）
- [ ] 幂等写操作（PUT/DELETE）语义正确

## 请求与响应

- [ ] 稳定 error code / error type（非仅自由文本 message）
- [ ] HTTP 状态码语义正确（401 vs 403、404 vs 410）
- [ ] 分页一种风格（cursor **或** offset，不混用）
- [ ] 日期/时间 ISO-8601；枚举与 OpenAPI schema 一致

## 安全与校验

- [ ] 写路径 auth + 输入校验
- [ ] 敏感字段不在 GET list 中过度暴露
- [ ] Rate limit / 体量限制对公开端点有考虑

## 契约同步

- [ ] OpenAPI/spec 与实现同 PR 更新
- [ ] Client types / API wrapper 已跟进
- [ ] Mock/fixture enum 与 server 校验一致
- [ ] Breaking change 在 CHANGELOG 标明

## 反模式（标 High）

- 仅改后端字段名不更新 client
- 200 + `{ "error": "..." }` 代替 4xx
- 示例与 schema 不一致

## API 测试

- [ ]  happy path + 401/403/404/422 覆盖
- [ ]  contract test 或 consumer-driven test 若项目已有
- [ ]  pagination 边界（空页、末页、非法 cursor）
- [ ]  跑项目 test / `curl` 示例与 OpenAPI 一致

## 垂直切片（跨层交付）

全栈新 API 域时，在上方审查清单之外按序自检（层序见 `rules/execution/vibe.mdc` §垂直切片）：

- [ ] 契约已定再动 persistence / service
- [ ] server 与 client types / mocks **同 PR**
- [ ] 测试：happy path + 主要 4xx；域脚本 L1 绿（`rules/feedback/verify.mdc`）
- [ ] 公开行为变更已更 docs / CHANGELOG
