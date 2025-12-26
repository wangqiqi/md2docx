#!/bin/bash

# 🔍 Cursor AI Rules - 环境完整性检查器
# 确保系统依赖和环境配置正确

set -e

echo "🔍 Cursor AI Rules - 环境完整性检查器"
echo "========================================"
echo ""

# ✅ 检查结果统计
CHECKS_TOTAL=0
CHECKS_PASSED=0
ISSUES_FOUND=0

# 🎯 通用检查函数
check_command() {
    local cmd="$1"
    local description="$2"
    local required="${3:-true}"

    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "   ✅ $description: 已安装"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        if [ "$required" = true ]; then
            echo "   ❌ $description: 未安装 (必需)"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        else
            echo "   ⚠️  $description: 未安装 (可选)"
        fi
        return 1
    fi
}

# 📁 检查目录结构
check_directory_structure() {
    echo "📁 检查目录结构..."

    local required_dirs=(".cursor" ".cursor/rules" ".cursor/scripts")
    local all_dirs_exist=true

    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "   ❌ 缺少目录: $dir"
            all_dirs_exist=false
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    done

    if [ "$all_dirs_exist" = true ]; then
        echo "   ✅ 核心目录结构完整"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    fi

    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    echo ""
}

# 🛠️ 检查系统依赖
check_system_dependencies() {
    echo "🛠️ 检查系统依赖..."

    # 必需命令
    check_command "bash" "Bash shell"
    check_command "find" "find 命令"
    check_command "grep" "grep 命令"
    check_command "sed" "sed 命令"

    # 推荐但可选的命令
    check_command "jq" "jq JSON处理器" false
    check_command "git" "Git版本控制" false
    check_command "curl" "curl网络工具" false

    echo ""
}

# 📊 检查脚本权限
check_script_permissions() {
    echo "📊 检查脚本权限..."

    local scripts=(
        ".cursor/cursor-adaptation-setup.sh"
        ".cursor/rules/intelligent_evolution/perception.sh"
    )

    local all_executable=true

    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                echo "   ✅ $script: 可执行"
            else
                echo "   ❌ $script: 权限不足"
                all_executable=false
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
        else
            echo "   ⚠️  $script: 文件不存在"
        fi
    done

    if [ "$all_executable" = true ]; then
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    fi

    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    echo ""
}

# 💾 检查磁盘空间
check_disk_space() {
    echo "💾 检查磁盘空间..."

    # 获取当前目录的可用空间 (KB)
    local available_space=$(df . | tail -1 | awk '{print $4}')

    if [ "$available_space" -gt 1000 ]; then  # 至少1MB
        echo "   ✅ 可用磁盘空间: $((available_space / 1024))MB"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo "   ❌ 磁盘空间不足: $available_space KB (建议至少1MB)"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi

    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    echo ""
}

# 🎯 检查智能进化系统
check_growth_system() {
    echo "🎯 检查智能进化系统..."

    if [ -d ".cursorGrowth" ]; then
        echo "   ✅ .cursorGrowth目录存在"

        if [ -f ".cursorGrowth/growth_meta.json" ]; then
            echo "   ✅ 元数据文件存在"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            echo "   ⚠️  元数据文件缺失"
        fi

        local data_files=$(find .cursorGrowth/data -name "*.json" 2>/dev/null | wc -l)
        echo "   ℹ️  感知数据文件: $data_files 个"

    else
        echo "   ℹ️  .cursorGrowth目录不存在 (首次运行时自动创建)"
    fi

    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    echo ""
}

# 📋 生成检查报告
generate_report() {
    echo "📋 环境检查报告"
    echo "================"

    local success_rate=$((CHECKS_PASSED * 100 / CHECKS_TOTAL))

    echo "📊 检查统计:"
    echo "   总检查项: $CHECKS_TOTAL"
    echo "   通过项目: $CHECKS_PASSED"
    echo "   发现问题: $ISSUES_FOUND"
    echo "   成功率: ${success_rate}%"
    echo ""

    if [ $ISSUES_FOUND -eq 0 ]; then
        echo "🎉 恭喜！环境检查全部通过"
        echo "   您的系统已准备好使用 Cursor AI Rules"
    else
        echo "⚠️  发现 $ISSUES_FOUND 个问题需要解决:"
        echo ""
        echo "💡 建议解决方案:"

        if ! command -v jq >/dev/null 2>&1; then
            echo "   • 安装jq: Ubuntu/Debian -> sudo apt install jq"
            echo "             macOS -> brew install jq"
            echo "             或访问: https://stedolan.github.io/jq/"
        fi

        if ! command -v git >/dev/null 2>&1; then
            echo "   • 安装Git: https://git-scm.com/downloads"
        fi

        echo ""
        echo "🔧 自动修复命令:"
        echo "   chmod +x .cursor/cursor-adaptation-setup.sh"
        echo "   chmod +x .cursor/rules/intelligent_evolution/perception.sh"
    fi

    echo ""
}

# 主函数
main() {
    # 检查是否在项目根目录
    if [ ! -f ".cursor/scripts/env_check.sh" ]; then
        echo "❌ 请在项目根目录运行此脚本"
        exit 1
    fi

    check_directory_structure
    check_system_dependencies
    check_script_permissions
    check_disk_space
    check_growth_system
    generate_report
}

# 执行主函数
main "$@"
