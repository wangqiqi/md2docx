#!/bin/bash
# PyPI 手动发布脚本

set -e

echo "🚀 手动发布 mddocx 到 PyPI"
echo "=========================="

# 检查必要的工具
command -v python3 >/dev/null 2>&1 || { echo "❌ 需要安装 python3"; exit 1; }
command -v pip >/dev/null 2>&1 || { echo "❌ 需要安装 pip"; exit 1; }

# 安装构建工具
echo "📦 安装构建工具..."
pip install --upgrade pip build twine

# 清理旧的构建产物
echo "🧹 清理旧构建产物..."
rm -rf dist/ build/ *.egg-info/

# 构建包
echo "🔨 构建包..."
python -m build

# 检查包
echo "🔍 检查包..."
twine check dist/*

# 显示包信息
echo "📋 包信息:"
ls -lh dist/

# 提示用户输入 API token
echo ""
echo "⚠️  请确保您有 PyPI API token"
echo "   获取地址: https://pypi.org/manage/account/token/"
echo ""
read -p "请输入您的 PyPI API token (或按 Ctrl+C 取消): " -s PYPI_TOKEN
echo ""

if [ -z "$PYPI_TOKEN" ]; then
    echo "❌ 未提供 API token，取消发布"
    exit 1
fi

# 发布到 PyPI
echo "📤 发布到 PyPI..."
TWINE_USERNAME=__token__ TWINE_PASSWORD="$PYPI_TOKEN" twine upload dist/*

echo ""
echo "✅ 发布成功！"
echo "📦 包地址: https://pypi.org/project/mddocx/"
echo "📚 文档: https://github.com/wangqiqi/md2docx"
