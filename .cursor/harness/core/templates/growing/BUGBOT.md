# Bugbot 审查规则（复制到 `.cursor/BUGBOT.md`）

> **不是** project rules（`.mdc`）— Bugbot **不读取** `.cursor/rules/`。  
> **不是** 本地 `REV-*` — 合并前结构化回顾仍用 **review** skill / **review** agent。

## 复制路径

```bash
mkdir -p .cursor/config
cp .cursor/templates/growing/BUGBOT.md .cursor/BUGBOT.md
cp .cursor/templates/growing/config/bugbot.yaml.example .cursor/config/bugbot.yaml
# 编辑后 commit 到默认分支（Bugbot 读 base 分支上的配置）
```

## 本仓 PR 审查重点

1. **安全** — 无密钥/PII 入日志；auth 写路径有校验（见 **security** skill 要点）。
2. **API** — 公开契约与文档/OpenAPI 一致；破坏性变更须在 CHANGELOG 标明。
3. **测试** — 行为变更应有可执行验收（`scripts/verify*.sh` / 单测），勿仅「目测通过」。
4. **Super Cursor 消费方** — 若改 `.cursor/`：须 `verify-super-cursor` / `cursor-coherence` 绿；项目特化只进 `.growing/`。

## 忽略 / 降噪

- 纯文案、注释、CHANGELOG 措辞类 nit — 除非误导用户或错误 API 名。
- 生成代码目录（若 `.gitignore` 已排除）— 不评。

## 与 Dashboard

Dashboard 连接仓库后，`.cursor/config/bugbot.yaml` 可收紧触发频率与 Autofix；字段见模板 `bugbot.yaml.example`。
