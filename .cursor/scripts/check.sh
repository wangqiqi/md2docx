#!/bin/bash

# ESLint 代码检查脚本
# 用于检查JavaScript/TypeScript文件的代码质量

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 尝试从插件目录读取配置，如果不存在则使用默认配置
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PLUGIN_DIR/plugins/eslint-integration/plugin.json"

# 如果配置文件不存在，使用默认配置
if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_FILE=""
fi

echo "🔍 ESLint 代码质量检查"
echo "========================"

# 检查ESLint是否安装
if ! command -v eslint >/dev/null 2>&1; then
    echo "❌ ESLint 未安装，请先安装："
    echo "   npm install -g eslint"
    echo "   或 yarn global add eslint"
    exit 1
fi

# 获取配置
if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    AUTO_FIX=$(jq -r '.config.auto_fix // true' "$CONFIG_FILE" 2>/dev/null || echo "true")
else
    AUTO_FIX="true"
fi

# 确定检查文件
if [ $# -gt 0 ]; then
    FILES="$*"
else
    # 查找所有JS/TS文件
    FILES=$(find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | head -20)
fi

if [ -z "$FILES" ]; then
    echo "ℹ️  未找到需要检查的文件"
    exit 0
fi

echo "📁 待检查文件:"
echo "$FILES" | tr ' ' '\n' | sed 's/^/   • /'
echo ""

echo "🔍 正在检查代码质量..."

# 运行ESLint检查
if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    # 使用插件配置
    TEMP_CONFIG=$(mktemp)
    jq -r '.config' "$CONFIG_FILE" > "$TEMP_CONFIG" 2>/dev/null || true
    if [ -s "$TEMP_CONFIG" ]; then
        ESLINT_OUTPUT=$(eslint --config "$TEMP_CONFIG" $FILES 2>&1 || true)
        rm -f "$TEMP_CONFIG"
    else
        ESLINT_OUTPUT=$(eslint $FILES 2>&1 || true)
        rm -f "$TEMP_CONFIG"
    fi
else
    # 使用项目默认配置或ESLint默认配置
    ESLINT_OUTPUT=$(eslint $FILES 2>&1 || true)
fi

# 分析结果
ERROR_COUNT=$(echo "$ESLINT_OUTPUT" | grep -c "error" || echo "0")
WARNING_COUNT=$(echo "$ESLINT_OUTPUT" | grep -c "warning" || echo "0")
FILE_COUNT=$(echo "$FILES" | wc -w)

echo ""
echo "📊 检查结果:"
echo "   📁 检查文件: $FILE_COUNT 个"
echo "   ❌ 错误数量: $ERROR_COUNT 个"
echo "   ⚠️  警告数量: $WARNING_COUNT 个"

if [ "$ERROR_COUNT" -eq 0 ] && [ "$WARNING_COUNT" -eq 0 ]; then
    echo "   ✅ 代码质量检查通过！"
    exit 0
else
    echo ""
    echo "🔧 详细问题列表:"
    echo "$ESLINT_OUTPUT"
    echo ""

    if [ "$AUTO_FIX" = "true" ]; then
        echo "🔧 正在尝试自动修复..."
        if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
            TEMP_CONFIG=$(mktemp)
            jq -r '.config' "$CONFIG_FILE" > "$TEMP_CONFIG" 2>/dev/null || true
            if [ -s "$TEMP_CONFIG" ]; then
                eslint --config "$TEMP_CONFIG" --fix $FILES 2>/dev/null && echo "✅ 自动修复完成" || echo "⚠️  部分问题需要手动修复"
                rm -f "$TEMP_CONFIG"
            else
                eslint --fix $FILES 2>/dev/null && echo "✅ 自动修复完成" || echo "⚠️  部分问题需要手动修复"
            fi
        else
            eslint --fix $FILES 2>/dev/null && echo "✅ 自动修复完成" || echo "⚠️  部分问题需要手动修复"
        fi
    fi

    exit 1
fi
