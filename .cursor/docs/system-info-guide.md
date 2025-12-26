# 系统信息获取器 (System Information Manager)

## 概述

系统信息获取器是一个通用的.cursor规则，用于自动获取和替换文档中的时间、项目路径和作者信息。这个规则设计为完全可迁移，可以在任何项目中使用，无需修改任何个人隐私信息。

## 功能特性

- ✅ **自动时间获取**: 获取当前系统本地时间
- ✅ **项目路径检测**: 自动识别Git仓库或工作目录
- ✅ **作者信息获取**: 从Git配置获取用户信息
- ✅ **变量自动替换**: 支持模板变量自动替换
- ✅ **跨平台兼容**: 支持Linux、macOS、Windows
- ✅ **隐私保护**: 不存储或泄露个人隐私信息

## 安装使用

### 1. 复制规则到目标项目

```bash
# 方法1: 从现有规则仓库复制
cp -r /path/to/rules-repo/.cursor/rules/system_info .cursor/rules/

# 方法2: 手动创建
mkdir -p .cursor/rules/system_info
cp RULE.md .cursor/rules/system_info/
```

### 2. 立即开始使用

规则激活后，在任何支持的文件类型中都可以使用以下变量：

```markdown
# 文档模板
*版本: v3.0.0 | 最后更新: {{GENERATION_TIME}} | 作者: {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}>*

项目根目录: {{PROJECT_ROOT}}
工作目录: {{WORK_DIR}}
```

## 支持的变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `{{GENERATION_TIME}}` | 当前系统时间 | `2025-12-23 09:38:58 CST` |
| `{{AUTHOR_NAME}}` | Git用户名 | `your.name` |
| `{{AUTHOR_EMAIL}}` | Git用户邮箱 | `user@example.com` |
| `{{PROJECT_ROOT}}` | 项目根目录 | `/home/user/project` |
| `{{WORK_DIR}}` | 当前工作目录 | `/home/user/project/src` |

## 自定义配置

创建 `.env.cursor` 文件进行自定义配置：

```bash
# 时间格式配置
TIME_FORMAT="%Y-%m-%d %H:%M:%S %Z"
TIMEZONE="Asia/Shanghai"

# 默认作者信息（当Git不可用时）
DEFAULT_AUTHOR_NAME="项目维护者"
DEFAULT_AUTHOR_EMAIL="maintainer@project.com"

# 项目路径配置
PROJECT_TYPE="git"  # git|workspace|custom
CUSTOM_ROOT_PATH="/path/to/project"
```

## 测试验证

运行测试脚本验证功能：

系统信息获取器会自动通过 `cursor-adaptation-setup.sh` 进行变量替换，无需手动测试。

## 文件结构

```
.cursor/rules/system_info/
├── RULE.md         # 规则定义和使用说明
# 系统信息获取器通过适配脚本自动工作，无需额外配置文件
└── README.md       # 本文件
```

## 兼容性

- **操作系统**: Linux, macOS, Windows
- **Shell**: Bash, Zsh, Fish
- **Git版本**: 2.0+
- **文件类型**: .md, .mdc, .txt, .json, .yaml, .yml

## 故障排除

### 时间获取失败
```bash
# 检查系统时间
date

# 检查时区设置
date '+%Z %z'
```

### Git信息获取失败
```bash
# 检查Git配置
git config --list | grep user

# 设置Git用户信息
git config --global user.name "您的姓名"
git config --global user.email "your.email@example.com"
```

### 路径检测失败
```bash
# 检查是否为Git仓库
git rev-parse --show-toplevel 2>/dev/null || echo "不是Git仓库"
```

## 许可证

本规则遵循.cursor规则系统的许可证。
