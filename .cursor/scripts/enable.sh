#!/bin/bash

# ESLint 插件启用脚本

echo "🔌 启用 ESLint 代码质量检查插件..."

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查依赖
echo "📦 检查依赖..."
if ! command -v node >/dev/null 2>&1; then
    echo "❌ 需要 Node.js 支持"
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo "❌ 需要 npm 包管理器"
    exit 1
fi

# 检查ESLint是否已安装
if ! command -v eslint >/dev/null 2>&1; then
    echo "📥 正在安装 ESLint..."
    if npm install -g eslint 2>/dev/null; then
        echo "✅ ESLint 安装成功"
    else
        echo "❌ ESLint 安装失败，请手动安装：npm install -g eslint"
        exit 1
    fi
fi

# 创建项目级ESLint配置（如果不存在）
if [ ! -f ".eslintrc.js" ] && [ ! -f ".eslintrc.json" ]; then
    echo "📝 创建项目 ESLint 配置..."
    cat > ".eslintrc.json" << 'EOF'
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": ["eslint:recommended"],
  "parserOptions": {
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "rules": {
    "semi": ["error", "always"],
    "quotes": ["error", "single"],
    "no-unused-vars": "warn",
    "no-console": "off"
  }
}
EOF
    echo "✅ 项目配置已创建: .eslintrc.json"
fi

# 设置脚本执行权限
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "${SCRIPT_DIR}/check.sh"

echo "✅ ESLint 插件启用完成！"
echo ""
echo "💡 现在您可以："
echo "   • 文件保存时自动检查代码质量"
echo "   • 运行: ./.cursor/scripts/check.sh 进行手动检查"
echo "   • 提交前自动运行代码质量检查"
