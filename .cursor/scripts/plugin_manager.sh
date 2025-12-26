#!/bin/bash

# 🔌 Cursor AI Rules - 插件管理系统
# 支持动态加载和管理系统插件

set -e

echo "🔌 Cursor AI Rules - 插件管理系统"
echo "===================================="
echo ""

# 📁 插件目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")/plugins"

# 如果plugins目录不存在，创建它
if [ ! -d "$PLUGIN_ROOT" ]; then
    mkdir -p "$PLUGIN_ROOT"
fi

# 🎯 插件元数据结构
# {
#   "name": "plugin_name",
#   "version": "1.0.0",
#   "description": "插件描述",
#   "type": "rule|tool|integration",
#   "triggers": ["file_save", "pre_commit", "manual"],
#   "dependencies": ["jq", "git"],
#   "config": {...},
#   "enabled": true
# }

# 📋 列出所有插件
list_plugins() {
    echo "📋 已安装插件列表:"
    echo ""

    local plugin_count=0

    # 直接扫描插件根目录
    for plugin_dir in "$PLUGIN_ROOT"/*/; do
        if [ -d "$plugin_dir" ] && [ "$(basename "$plugin_dir")" != "core" ] && [ "$(basename "$plugin_dir")" != "custom" ]; then
            local plugin_name=$(basename "$plugin_dir")
            local config_file="$plugin_dir/plugin.json"

            if [ -f "$config_file" ]; then
                local name=$(jq -r '.name // "'$plugin_name'"' "$config_file" 2>/dev/null || echo "$plugin_name")
                local version=$(jq -r '.version // "未知"' "$config_file" 2>/dev/null || echo "未知")
                local description=$(jq -r '.description // "无描述"' "$config_file" 2>/dev/null || echo "无描述")
                local enabled=$(jq -r '.enabled // true' "$config_file" 2>/dev/null || echo "true")

                local status="✅"
                if [ "$enabled" = "false" ]; then
                    status="⏸️ "
                fi

                echo "   $status $name (v$version) - $description"
                plugin_count=$((plugin_count + 1))
            else
                echo "   📂 $plugin_name (缺少配置文件)"
            fi
        fi
    done

    if [ $plugin_count -eq 0 ]; then
        echo "   ℹ️  暂无已安装插件"
        echo ""
        echo "💡 建议安装插件:"
        echo "   • eslint-integration - ESLint代码质量检查"
        echo "   • prettier-formatter - 代码自动格式化"
        echo "   • security-scanner - 安全漏洞扫描"
        echo ""
    fi
}

# 🔍 查找插件
find_plugin() {
    local plugin_name="$1"

    # 直接在插件根目录下查找
    if [ -d "$PLUGIN_ROOT/$plugin_name" ]; then
        echo "$PLUGIN_ROOT/$plugin_name"
        return 0
    fi

    return 1
}

# ✅ 启用插件
enable_plugin() {
    local plugin_name="$1"
    local plugin_path=$(find_plugin "$plugin_name")

    if [ -z "$plugin_path" ]; then
        echo "❌ 插件 '$plugin_name' 未找到"
        return 1
    fi

    local config_file="$plugin_path/plugin.json"

    if [ ! -f "$config_file" ]; then
        echo "❌ 插件配置文件不存在: $config_file"
        return 1
    fi

    # 更新配置
    jq '.enabled = true' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"

    echo "✅ 插件 '$plugin_name' 已启用"

    # 执行插件的启用钩子
    local enable_script="$plugin_path/enable.sh"
    if [ -f "$enable_script" ]; then
        echo "🔧 执行插件启用脚本..."
        bash "$enable_script"
    fi
}

# ⏸️ 禁用插件
disable_plugin() {
    local plugin_name="$1"
    local plugin_path=$(find_plugin "$plugin_name")

    if [ -z "$plugin_path" ]; then
        echo "❌ 插件 '$plugin_name' 未找到"
        return 1
    fi

    local config_file="$plugin_path/plugin.json"

    if [ ! -f "$config_file" ]; then
        echo "❌ 插件配置文件不存在: $config_file"
        return 1
    fi

    # 更新配置
    jq '.enabled = false' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"

    echo "⏸️  插件 '$plugin_name' 已禁用"

    # 执行插件的禁用钩子
    if [ -f "$plugin_path/disable.sh" ]; then
        echo "🔧 执行插件禁用脚本..."
        bash "$plugin_path/disable.sh"
    fi
}

# 📥 安装插件
install_plugin() {
    local plugin_url="$1"
    local plugin_name=$(basename "$plugin_url" .git)

    echo "📥 正在安装插件: $plugin_name"

    # 确定安装目录
    local install_dir="$PLUGIN_ROOT/$plugin_name"

    if [ -d "$install_dir" ]; then
        echo "⚠️  插件已存在，是否覆盖？(y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "安装已取消"
            return 0
        fi
        rm -rf "$install_dir"
    fi

    # 克隆插件
    if git clone "$plugin_url" "$install_dir" 2>/dev/null; then
        echo "✅ 插件 '$plugin_name' 安装成功"

        # 检查插件配置
        if [ -f "$install_dir/plugin.json" ]; then
            echo "🔧 正在配置插件..."

            # 执行安装脚本
            if [ -f "$install_dir/install.sh" ]; then
                bash "$install_dir/install.sh"
            fi

            # 默认启用插件
            enable_plugin "$plugin_name"
        else
            echo "⚠️  插件缺少配置文件，将保持禁用状态"
        fi
    else
        echo "❌ 插件安装失败"
        return 1
    fi
}

# 📤 卸载插件
uninstall_plugin() {
    local plugin_name="$1"
    local plugin_path=$(find_plugin "$plugin_name")

    if [ -z "$plugin_path" ]; then
        echo "❌ 插件 '$plugin_name' 未找到"
        return 1
    fi

    echo "⚠️  确定要卸载插件 '$plugin_name' 吗？这将删除所有相关数据。(y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "卸载已取消"
        return 0
    fi

    # 执行卸载钩子
    if [ -f "$plugin_path/uninstall.sh" ]; then
        echo "🔧 执行插件卸载脚本..."
        bash "$plugin_path/uninstall.sh"
    fi

    # 删除插件目录
    rm -rf "$plugin_path"
    echo "✅ 插件 '$plugin_name' 已卸载"
}

# 🔄 更新插件
update_plugin() {
    local plugin_name="$1"
    local plugin_path=$(find_plugin "$plugin_name")

    if [ -z "$plugin_path" ]; then
        echo "❌ 插件 '$plugin_name' 未找到"
        return 1
    fi

    echo "🔄 正在更新插件: $plugin_name"

    if [ -d "$plugin_path/.git" ]; then
        cd "$plugin_path"
        if git pull origin main 2>/dev/null || git pull origin master 2>/dev/null; then
            echo "✅ 插件 '$plugin_name' 更新成功"

            # 执行更新钩子
            if [ -f "update.sh" ]; then
                bash "update.sh"
            fi
        else
            echo "❌ 插件更新失败"
            return 1
        fi
        cd - >/dev/null
    else
        echo "⚠️  插件不是从Git安装的，跳过更新"
    fi
}

# 📖 显示帮助
show_help() {
    echo "📖 Cursor AI Rules 插件管理器使用帮助"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  list                    列出所有已安装插件"
    echo "  enable <插件名>         启用指定插件"
    echo "  disable <插件名>        禁用指定插件"
    echo "  install <Git URL>       从Git仓库安装插件"
    echo "  uninstall <插件名>      卸载指定插件"
    echo "  update <插件名>         更新指定插件"
    echo "  help                    显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 list"
    echo "  $0 install https://github.com/user/eslint-plugin.git"
    echo "  $0 enable eslint-integration"
    echo ""
}

# 主函数
main() {
    # 检查jq依赖
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ 需要jq工具支持，请先安装jq"
        echo "   Ubuntu/Debian: sudo apt install jq"
        echo "   macOS: brew install jq"
        exit 1
    fi

    case "${1:-help}" in
        "list")
            list_plugins
            ;;
        "enable")
            if [ -z "$2" ]; then
                echo "❌ 请指定插件名称"
                exit 1
            fi
            enable_plugin "$2"
            ;;
        "disable")
            if [ -z "$2" ]; then
                echo "❌ 请指定插件名称"
                exit 1
            fi
            disable_plugin "$2"
            ;;
        "install")
            if [ -z "$2" ]; then
                echo "❌ 请指定插件Git URL"
                exit 1
            fi
            install_plugin "$2"
            ;;
        "uninstall")
            if [ -z "$2" ]; then
                echo "❌ 请指定插件名称"
                exit 1
            fi
            uninstall_plugin "$2"
            ;;
        "update")
            if [ -z "$2" ]; then
                echo "❌ 请指定插件名称"
                exit 1
            fi
            update_plugin "$2"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 执行主函数
main "$@"
