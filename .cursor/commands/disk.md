---
description: 【工具】磁盘快照 — 采集占用并对比上次快照
---

加载 skill **disk**：

1. 跑 `skills/disk/scripts/collect-disk.py snapshot`
2. 写入 `.cursorGrowth/disk-snapshots/`（本地、不提交）
3. 与上次快照对比变动并报告

路径配置见 skill 与 `templates/cursorGrowth/disk-paths.example.json`。
