#!/usr/bin/env python3
"""
Markdown to DOCX WebUI 启动脚本
"""

from mddocx.webui.app import app
from mddocx.webui.config import get_config


def main():
    """主函数"""
    config = get_config()
    print("🚀 启动 Markdown to DOCX WebUI...")
    print(f"📱 访问地址: http://{config.HOST}:{config.PORT}")
    print("❌ 按 Ctrl+C 停止服务")
    print("-" * 50)

    app.run(debug=config.DEBUG, host=config.HOST, port=config.PORT)


if __name__ == "__main__":
    main()
