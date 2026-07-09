---
name: security
description: 合并前安全审查 — auth、密钥、PII。
---

# security · 审查清单

输出格式：**严重度**（Critical / High / Medium / Low）· **位置**（文件:行）· **问题** · **修复建议**

## 密钥与凭证

- [ ] 无硬编码 API key、token、密码、私钥
- [ ] `.env` / credentials 在 `.gitignore` 且未 staged
- [ ] 日志与错误信息不泄露密钥或完整 connection string
- [ ] CI/脚本用 secret 注入，非明文

## 鉴权与授权

- [ ] 写/删/管理路径有 auth 检查（非仅 UI 隐藏）
- [ ] 资源 ID 来自 URL/body 时校验归属（防 IDOR）
- [ ] 默认 deny；admin 路径单独守卫
- [ ] Session/JWT 过期与吊销策略合理

## 输入与输出

- [ ] 用户输入校验（类型、长度、enum、SQL/命令注入面）
- [ ] 文件上传：类型/大小限制；存储路径不可遍历
- [ ] 响应不含多余 PII；错误信息不暴露栈/内部路径

## 依赖与配置

- [ ] 无已知高危依赖 — 跑 **audit**（`npm audit` · `pip audit` · `cargo audit` · Dependabot alerts）
- [ ] 依赖升级 PR 注明 breaking 与回滚路径
- [ ] CORS、CSP、安全 header 符合部署环境
- [ ] Debug/verbose 模式生产默认关闭

## 与 rules 的分工

- SDLC 习惯 → `rules/execution/security-sdlc.mdc`

- 提交/分支 → **git** skill · `rules/execution/commit.mdc`
- API 契约 → **api** skill · `rules/execution/api.mdc`
- 打版前必跑 → **release** skill 清单含 security 项
