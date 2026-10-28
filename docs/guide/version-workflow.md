# 📦 版本管理工作流程 (Version Management Workflow)

*最后更新: 2026-10-28*

## 🎯 概述

版本**唯一真源**为 `pyproject.toml` → `[project].version`。运行时 `mddocx.__version__` 从 pyproject（源码树）或 wheel metadata（已安装）读取，**勿**在 `__init__.py` 硬编码。

## 📋 门面同步清单

| 文件 | 动作 |
|------|------|
| `pyproject.toml` | bump `[project].version` |
| `README.md` | version badge 与 releases 链接 |
| `CHANGELOG.md` | 折叠 `[Unreleased]` → `## [x.y.z] - 日期` |
| `docs/` 门户 | 首页 · 发布/测试/CI 指南中的版本与流程说明 |
| git tag | `v{x.y.z}` annotated，打在含 CHANGELOG 的 commit 上 |

校验：

```bash
bash scripts/verify_release_alignment.sh
EXPECT_TAG=v0.5.74 bash scripts/verify_release_alignment.sh  # 打 tag 时
```

## ✅ 发布前检查（推荐顺序）

1. **`bash scripts/verify_quality.sh`** — 与 CI `quality` job 同序（约 1 分钟）
2. **`bash scripts/verify_release_candidate.sh`** — pytest · 构建 · 隔离安装（发版前可选但推荐）
3. 更新 CHANGELOG / README / docs 后再次 `verify_release_alignment.sh`

### 代码质量（verify_quality 已包含）

- flake8 · black · mypy（converter + standalone）· isort · ConvertMetrics

## 🏷️ 发布

```bash
git tag -a v0.5.74 -m "Release 0.5.74: …"
git push origin master
git push origin v0.5.74   # 触发 publish.yml → PyPI
```

推送 `docs/**` 到 `master` 会触发 GitHub Pages（VitePress 门户）。

## 📚 相关

- [发布流程](/guide/release)
- [CHANGELOG 格式](https://keepachangelog.com/)
- [语义化版本](https://semver.org/)
