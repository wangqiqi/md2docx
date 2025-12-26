#!/usr/bin/env python3
"""
Markdown to DOCX WebUI 启动脚本
"""
import sys
import os

# 添加项目根目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from webui.app import app

if __name__ == "__main__":
    print("🚀 启动 Markdown to DOCX WebUI...")
    print("📱 访问地址: http://localhost:5000")
    print("❌ 按 Ctrl+C 停止服务")
    print("-" * 50)

    app.run(
        debug=True,
        host="0.0.0.0",
        port=5000
    )