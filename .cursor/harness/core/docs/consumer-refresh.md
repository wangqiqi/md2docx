# 消费方升级 · 覆盖 `.cursor/`

母版演进后，在**目标 Git 项目**同步 Super Cursor SOP。**SSOT 命令**：仓库根 `install-super-cursor.sh`（不要用零散 `rsync` 漏文件）。

## 前置（母版仓）

```bash
cd /path/to/cursor-ai   # 母版克隆路径
git pull
bash .cursor/template-verify.sh
```

记录母版 commit 或即将发布的 tag，便于消费方 CHANGELOG 对照。

## 覆盖命令

```bash
/path/to/cursor-ai/install-super-cursor.sh /path/to/target-project \
  --profile full \
  --replace
```

| 选项 | 说明 |
|------|------|
| `--replace` | **先删**目标 `.cursor/` 再拷贝，避免残留 `commands/` · `skills/finish` 等旧文件 |
| `--profile full` | hooks + `plan.md` 种子（默认团队配置） |
| `--skills-bundle core` | 可选：23 skills 而非 28（见 `config/skill-bundles.json`） |

已 `install-super-cursor.sh --setup-shell` 后，可在目标目录用：

```bash
install-super-cursor --replace
```

（`$SUPER_CURSOR_HOME` 指向母版根。）

## 不会动什么

| 路径 | 行为 |
|------|------|
| `.growing/` | **保留**；仅缺失时 bootstrap（plan · learn · archive · `rules/local`） |
| 已有 `onekey_start.sh` | **不覆盖**（`growth.onekey_bootstrap`） |
| 业务代码 · `scripts/verify.sh` | 不在 install 包内，不受影响 |

项目特化规则写在 **`.growing/rules/local/`**（安装后链到 `.cursor/rules/local`）。

## 不要覆盖的对象

- **`vendor/` · `3rdparty/` · 子模块内嵌套的 `.cursor/`** — 不是项目主 SOP；单独决策或删除嵌套副本，避免 diff 噪音。
- **母版仓库自身** — 勿对 `cursor-ai` 根跑 `--replace`（安装器会防自毁）。

## 覆盖后自检（目标项目）

| 步骤 | 命令 / 产物 | 说明 |
|------|-------------|------|
| 布局 | `bash .cursor/verify-super-cursor.sh` | hybrid 混合仓自动 SKIP 母版专属项 |
| **栈适配** | `.cursor/bin/scaffold.sh adapt` → `adapt --write` | 写入 `.growing/project-profile.json`（**按需启用**，非瘦安装） |
| profile | `stacks.primary` · `verify.enabled_tiers` | 机器镜像 → `learn/dev-conventions.md` **`SC_PROFILE_SYNC`** 段（含 DAILY/LIBRARY 建议） |
| 平台 | `bash .cursor/bin/platform-check.sh` | 工具链 |
| 业务 | `./scripts/verify.sh` | 见 learn |

详 **整包安装 vs 按需启用** → [tech-stacks.md](tech-stacks.md)。

```bash
cd /path/to/target-project

# 布局与 SOP 自洽（混合仓自动 hybrid）
bash .cursor/verify-super-cursor.sh

# 棕地/升级后：探测主栈并落盘（先预览再 --write）
.cursor/bin/scaffold.sh adapt
.cursor/bin/scaffold.sh adapt --write

# 平台工具
bash .cursor/bin/platform-check.sh

# 业务验收（若有）
./scripts/verify.sh
# 或 npm run verify:changed / verify:core — 见项目 learn/dev-conventions.md
```

| 现象 | 常见原因 |
|------|----------|
| 缺大量文件 vs 母版 | 未 `--replace`，仍是旧安装 |
| `commands/` 仍存在 | 未 `--replace` |
| `rules/local` 不生效 | 检查 `.cursor/rules/local` → `.growing/rules/local` 符号链接 |
| 母版 `cursor-coherence` 要求根 README 技能表 | **仅母版仓库**；消费方不必满足 |

## 可选：团队将 Growth 纳入 git

默认 `.growing/` 在目标项目 **gitignore**。若团队要把 `learn/` · `plan.md` · `rules/local` 纳入版本库，见安装后 `learn/plan-conventions.md` §Growth 与 git。

## 可选备份

```bash
tar -czf ".growing/archive/pre-cursor-$(date +%Y%m%d).tar.gz" -C /path/to/target-project .cursor
```

## 升级后建议

1. 打开 Cursor → 确认 rules/skills 加载无报错。  
2. **`scaffold adapt --write`** → 核对 `project-profile.json` 与 **`learn/dev-conventions.md` 的 `SC_PROFILE_SYNC` 段**（主栈 · tiers · DAILY/LIBRARY）；多栈用 `--primary=a,b`。  
3. 跑一次 `/learn` 增量核对 `dev-conventions.md` **人工段**（verify 命令 · 分支）是否与现网一致。  
4. 有问题：保留 **install 命令 · verify 输出 · hybrid/mother** 结论，回母版排查。

## 交叉引用

- 技术栈与按需启用 → [tech-stacks.md](tech-stacks.md)  
- 安装入门 → `quickstart.md`  
- 迁移步骤摘要 → `migration-catalog.md` §目标项目升级  
- 母版自测 → `bash .cursor/template-verify.sh`
