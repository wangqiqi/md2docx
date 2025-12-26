"""
WebUI 基础功能测试
"""
import pytest
import tempfile
import os
from pathlib import Path

# 添加项目根目录到路径
project_root = Path(__file__).parent.parent.parent
import sys
sys.path.insert(0, str(project_root))

from webui.app import app, allowed_file
from webui.config import get_config


class TestConfig:
    """配置测试"""

    def test_development_config(self):
        """测试开发环境配置"""
        config = get_config('development')
        assert config.DEBUG is True
        assert config.MAX_CONTENT_LENGTH == 16 * 1024 * 1024

    def test_production_config_requires_secret_key(self):
        """测试生产环境需要SECRET_KEY"""
        # 移除环境变量
        old_key = os.environ.get('SECRET_KEY')
        old_env = os.environ.get('FLASK_ENV')

        try:
            if 'SECRET_KEY' in os.environ:
                del os.environ['SECRET_KEY']
            os.environ['FLASK_ENV'] = 'production'

            with pytest.raises(ValueError, match="生产环境必须设置 SECRET_KEY"):
                config = get_config()
                # 访问SECRET_KEY属性来触发验证
                _ = config.SECRET_KEY
        finally:
            # 恢复环境变量
            if old_key:
                os.environ['SECRET_KEY'] = old_key
            if old_env:
                os.environ['FLASK_ENV'] = old_env
            elif 'FLASK_ENV' in os.environ:
                del os.environ['FLASK_ENV']


class TestFileValidation:
    """文件验证测试"""

    def test_allowed_file_extensions(self):
        """测试允许的文件扩展名"""
        config = get_config()

        # 允许的文件
        assert allowed_file("test.md") is True
        assert allowed_file("test.markdown") is True
        assert allowed_file("test.txt") is True

        # 不允许的文件
        assert allowed_file("test.docx") is False
        assert allowed_file("test.pdf") is False
        assert allowed_file("test") is False  # 没有扩展名

    def test_allowed_file_with_content_check(self):
        """测试带内容验证的文件检查"""
        # 创建临时文本文件
        with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as f:
            f.write("# Test Markdown")
            temp_file_path = f.name

        try:
            with open(temp_file_path, 'rb') as f:
                assert allowed_file("test.md", f) is True
        finally:
            os.unlink(temp_file_path)

        # 测试扩展名验证（简化测试）
        assert allowed_file("test.pdf") is False


class TestAppRoutes:
    """应用路由测试"""

    def setup_method(self):
        """测试前准备"""
        app.config['TESTING'] = True
        self.client = app.test_client()

    def test_index_page(self):
        """测试首页"""
        response = self.client.get('/')
        assert response.status_code == 200
        assert b'Markdown to DOCX' in response.data

    def test_preview_endpoint(self):
        """测试预览端点"""
        # 测试空内容
        response = self.client.post('/preview', data={'markdown': ''})
        assert response.status_code == 200
        assert '请输入Markdown内容'.encode('utf-8') in response.data

        # 测试正常内容
        response = self.client.post('/preview', data={'markdown': '# Test\nHello World'})
        assert response.status_code == 200
        assert b'Test' in response.data

    def test_convert_endpoint_validation(self):
        """测试转换端点验证"""
        # 测试空内容
        response = self.client.post('/convert', data={}, follow_redirects=True)
        assert response.status_code == 200  # 跟随重定向后的状态
        assert '请输入Markdown内容'.encode('utf-8') in response.data

        # 测试正常内容（这里不会实际生成文件，只是测试路由）
        response = self.client.post('/convert', data={'markdown': '# Test'})
        # 由于实际转换需要文件系统权限，这里主要测试路由是否工作
        assert response.status_code in [200, 302]  # 可能成功或重定向


if __name__ == '__main__':
    pytest.main([__file__])
