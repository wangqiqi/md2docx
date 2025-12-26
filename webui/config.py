"""
WebUI 配置管理
"""
import os
from pathlib import Path

class Config:
    """基础配置类"""

    # Flask配置
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-secret-key-change-in-production")
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB

    # 应用配置
    UPLOAD_FOLDER = os.environ.get("UPLOAD_FOLDER", "/tmp")

    # 文件处理配置
    ALLOWED_EXTENSIONS = {'md', 'markdown', 'txt'}
    ALLOWED_MIME_TYPES = {
        'text/plain',
        'text/markdown',
        'text/x-markdown'
    }

    # 内容限制
    MAX_TEXT_CONTENT_SIZE = 5 * 1024 * 1024  # 5MB
    MAX_PREVIEW_CONTENT_SIZE = 2 * 1024 * 1024  # 2MB

    # 服务器配置
    HOST = os.environ.get("HOST", "0.0.0.0")
    PORT = int(os.environ.get("PORT", 5000))
    DEBUG = os.environ.get("FLASK_DEBUG", "False").lower() == "true"

class DevelopmentConfig(Config):
    """开发环境配置"""
    DEBUG = True
    SECRET_KEY = "dev-secret-key-change-in-production"

class ProductionConfig(Config):
    """生产环境配置"""
    DEBUG = False

    # 在生产环境中需要设置环境变量
    @property
    def SECRET_KEY(self):
        key = os.environ.get("SECRET_KEY")
        if not key:
            raise ValueError("生产环境必须设置 SECRET_KEY 环境变量")
        return key

# 配置映射
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}

def get_config(config_name=None):
    """获取配置类"""
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'default')

    return config.get(config_name, config['default'])()
