"""
WebUI 基础功能测试
"""

import os
import tempfile

import pytest

from mddocx.webui.app import allowed_file, app
from mddocx.webui.config import get_config


class TestConfig:
    """配置测试"""

    def setup_method(self):
        """测试前设置"""
        from mddocx.webui.config import get_config

        self.get_config = get_config

    def test_development_config(self):
        """测试开发环境配置"""
        config = self.get_config("development")
        assert config.DEBUG is True
        assert config.MAX_CONTENT_LENGTH == 16 * 1024 * 1024

    def test_production_config_requires_secret_key(self):
        """测试生产环境需要SECRET_KEY"""
        # 移除环境变量
        old_key = os.environ.get("SECRET_KEY")
        old_env = os.environ.get("FLASK_ENV")

        try:
            if "SECRET_KEY" in os.environ:
                del os.environ["SECRET_KEY"]
            os.environ["FLASK_ENV"] = "production"

            with pytest.raises(ValueError, match="生产环境必须设置 SECRET_KEY"):
                config = get_config()
                # 访问SECRET_KEY属性来触发验证
                _ = config.SECRET_KEY
        finally:
            # 恢复环境变量
            if old_key:
                os.environ["SECRET_KEY"] = old_key
            if old_env:
                os.environ["FLASK_ENV"] = old_env
            elif "FLASK_ENV" in os.environ:
                del os.environ["FLASK_ENV"]


class TestFileValidation:
    """文件验证测试"""

    def setup_method(self):
        """测试前设置"""
        from mddocx.webui.app import allowed_file

        self.allowed_file = allowed_file

    def test_allowed_file_extensions(self):
        """测试允许的文件扩展名"""
        # 允许的文件
        assert self.allowed_file("test.md") is True
        assert self.allowed_file("test.markdown") is True
        assert self.allowed_file("test.txt") is True

        # 不允许的文件
        assert allowed_file("test.docx") is False
        assert allowed_file("test.pdf") is False
        assert allowed_file("test") is False  # 没有扩展名

    def test_allowed_file_with_content_check(self):
        """测试带内容验证的文件检查"""
        # 创建临时文本文件
        with tempfile.NamedTemporaryFile(mode="w", suffix=".md", delete=False) as f:
            f.write("# Test Markdown")
            temp_file_path = f.name

        try:
            with open(temp_file_path, "rb") as f:
                assert allowed_file("test.md", f) is True
        finally:
            os.unlink(temp_file_path)

        # 测试扩展名验证（简化测试）
        assert self.allowed_file("test.pdf") is False


class TestAppRoutes:
    """应用路由测试"""

    def setup_method(self):
        """测试前准备"""
        app.config["TESTING"] = True
        app.config["WTF_CSRF_ENABLED"] = False
        self.client = app.test_client()

    def test_index_page(self):
        """测试首页"""
        response = self.client.get("/")
        assert response.status_code == 200
        assert b"Markdown to DOCX" in response.data

    def test_preview_endpoint(self):
        """测试预览端点"""
        # 测试空内容
        response = self.client.post("/preview", data={"markdown": ""})
        assert response.status_code == 200
        assert "请输入Markdown内容".encode("utf-8") in response.data

        # 测试正常内容
        response = self.client.post(
            "/preview", data={"markdown": "# Test\nHello World"}
        )
        assert response.status_code == 200
        assert b"Test" in response.data

    def test_preview_renders_dollarmath(self):
        """预览与转换器一致，支持 LaTeX dollarmath"""
        response = self.client.post(
            "/preview", data={"markdown": "Energy $E=mc^2$"}
        )
        assert response.status_code == 200
        assert b'math inline' in response.data
        assert b"E=mc^2" in response.data

    def test_convert_endpoint_validation(self):
        """测试转换端点验证"""
        # 测试空内容
        response = self.client.post("/convert", data={}, follow_redirects=True)
        assert response.status_code == 200  # 跟随重定向后的状态
        assert b"[E_CONTENT_EMPTY]" in response.data
        assert "Markdown".encode("utf-8") in response.data

        # 测试正常内容（这里不会实际生成文件，只是测试路由）
        response = self.client.post("/convert", data={"markdown": "# Test"})
        # 由于实际转换需要文件系统权限，这里主要测试路由是否工作
        assert response.status_code in [200, 302]  # 可能成功或重定向

    def test_error_handling(self):
        """测试错误处理"""
        # 测试无效的Markdown内容
        response = self.client.post(
            "/preview", data={"markdown": "# Test\n\n```invalid\nunclosed code block"}
        )
        # 即使有解析错误，也应该返回响应
        assert response.status_code == 200

    def test_file_upload_validation(self):
        """测试文件上传验证"""
        # 测试无效文件类型
        from io import BytesIO

        invalid_file = BytesIO(b"invalid content")
        invalid_file.filename = "test.exe"

        response = self.client.post(
            "/convert",
            data={"file": (invalid_file, "test.exe")},
            content_type="multipart/form-data",
        )
        assert response.status_code in [200, 302]

    def test_rate_limit_returns_429(self):
        """超过限流阈值应返回 429 与 E_RATE_LIMIT"""
        from mddocx.webui.rate_limit import reset_rate_limits

        reset_rate_limits()
        for _ in range(30):
            self.client.post("/preview", data={"markdown": "# ok"})
        response = self.client.post("/preview", data={"markdown": "# blocked"})
        assert response.status_code == 200
        assert b"[E_RATE_LIMIT]" in response.data
        reset_rate_limits()

    def test_large_content_handling(self):
        """测试大内容处理"""
        # 生成较大的Markdown内容
        large_content = "# Large Test\n\n" + "Test paragraph\n\n" * 1000

        response = self.client.post("/preview", data={"markdown": large_content})
        assert response.status_code == 200
        # 确保响应不为空
        assert len(response.data) > 0

    def test_special_characters(self):
        """测试特殊字符处理"""
        special_md = """# 特殊字符测试

## 中文内容
这是一个中文测试文档。

## Emoji
🚀 🌟 ✨

## 数学符号
α + β = γ
∑ ∫ √

## 引用
> "To be or not to be, that is the question."
> -- Shakespeare
"""

        response = self.client.post("/preview", data={"markdown": special_md})
        assert response.status_code == 200
        assert "特殊字符测试".encode("utf-8") in response.data

    def test_multiple_converts_do_not_accumulate(self):
        """测试连续转换不会累积历史内容"""
        from io import BytesIO

        from docx import Document

        response1 = self.client.post(
            "/convert", data={"markdown": "# 第一次\n\n唯一第一段。"}
        )
        assert response1.status_code == 200
        doc1 = Document(BytesIO(response1.data))
        text1 = "\n".join(p.text for p in doc1.paragraphs)
        assert "第一次" in text1
        assert "第二次" not in text1

        response2 = self.client.post(
            "/convert", data={"markdown": "# 第二次\n\n唯一第二段。"}
        )
        assert response2.status_code == 200
        doc2 = Document(BytesIO(response2.data))
        text2 = "\n".join(p.text for p in doc2.paragraphs)
        assert "第二次" in text2
        assert "第一次" not in text2

    def test_preview_sanitizes_script_tags(self):
        """测试预览接口消毒恶意脚本"""
        malicious = '<script>alert("xss")</script>\n\n# Hello'
        response = self.client.post("/preview", data={"markdown": malicious})
        assert response.status_code == 200
        assert b"<script>" not in response.data
        assert b"Hello" in response.data

    def test_empty_and_whitespace_content(self):
        """测试空内容和空白内容"""
        # 完全空内容
        response = self.client.post("/preview", data={"markdown": ""})
        assert response.status_code == 200

        # 只有空白字符
        response = self.client.post("/preview", data={"markdown": "   \n\t  "})
        assert response.status_code == 200

        # 只有换行符
        response = self.client.post("/preview", data={"markdown": "\n\n\n"})
        assert response.status_code == 200


if __name__ == "__main__":
    pytest.main([__file__])
