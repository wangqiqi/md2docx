# 附注 tag 时间戳发版（项目特化 · 示例）

> 非 SemVer 团队可用 **日期+时分** tag；与 **release** skill · `config/release.json` 并存时以 config 为准。

## 约定（示例）

| 项 | 值 |
|----|-----|
| tag 格式 | `YYYY.MM.DD.HHMM`（本地 4 位时分，无秒） |
| CHANGELOG 节标题 | `## [TAG] - YYYY-MM-DD` 与 tag **同名** |
| commit | `release TAG: …` 在 tag 确定后 |

## 顺序

1. 内容 commit  
2. `TAG=$(date +%Y.%m.%d.%H%M)` → `git tag -a "$TAG" -m "…"`  
3. CHANGELOG 顶栏新增对应节 → 跟 commit 对齐后 push  

历史误用格式：**不删不重打远端 tag**；新 tag 仅新格式。
