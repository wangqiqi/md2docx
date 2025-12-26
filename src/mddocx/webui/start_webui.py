#!/usr/bin/env python3
"""
Markdown to DOCX WebUI 启动脚本
"""
import os
import sys

# 添加项目根目录到Python路径
project_root = os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
)
sys.path.insert(0, project_root)


def main():
    """主函数"""
    print("🚀 启动 Markdown to DOCX WebUI...")
    print("📱 访问地址: http://localhost:5000")
    print("❌ 按 Ctrl+C 停止服务")
    print("-" * 50)

    # 动态导入，避免模块级导入问题
    from mddocx.webui.app import app

    app.run(debug=True, host="0.0.0.0", port=5000)


if __name__ == "__main__":
    main()
