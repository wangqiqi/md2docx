"""
CLI模块单元测试
"""

import os
import tempfile
from unittest.mock import patch

import pytest

from mddocx.cli import convert_file, main


class TestCLI:
    """CLI模块测试"""

    def test_convert_file_success(self):
        """测试文件转换成功情况"""
        # 创建临时文件
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".md", delete=False, encoding="utf-8"
        ) as md_file:
            md_file.write("# 测试标题\n\n这是一个测试段落。")
            md_path = md_file.name

        with tempfile.NamedTemporaryFile(suffix=".docx", delete=False) as docx_file:
            docx_path = docx_file.name

        try:
            # 测试转换
            convert_file(md_path, docx_path, debug=False)

            # 验证输出文件存在
            assert os.path.exists(docx_path)
            assert os.path.getsize(docx_path) > 0

        finally:
            # 清理文件
            for path in [md_path, docx_path]:
                if os.path.exists(path):
                    os.unlink(path)

    def test_convert_file_input_not_exists(self):
        """测试输入文件不存在的情况"""
        with tempfile.NamedTemporaryFile(suffix=".docx", delete=False) as docx_file:
            docx_path = docx_file.name

        try:
            # 测试不存在的输入文件
            with pytest.raises(FileNotFoundError):
                convert_file("/nonexistent/file.md", docx_path, debug=False)

        finally:
            if os.path.exists(docx_path):
                os.unlink(docx_path)

    def test_convert_file_output_directory_not_exists(self):
        """测试输出目录不存在的情况"""
        # 创建临时文件
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".md", delete=False, encoding="utf-8"
        ) as md_file:
            md_file.write("# 测试标题")
            md_path = md_file.name

        # 使用不存在的目录
        nonexistent_dir = "/nonexistent/directory"
        docx_path = os.path.join(nonexistent_dir, "output.docx")

        try:
            # 测试不存在的输出目录
            with pytest.raises(FileNotFoundError):
                convert_file(md_path, docx_path, debug=False)

        finally:
            if os.path.exists(md_path):
                os.unlink(md_path)

    @patch("mddocx.cli.convert_file")
    @patch("pathlib.Path.exists", return_value=True)
    def test_main_convert_command(self, mock_exists, mock_convert):
        """测试主函数转换命令"""
        test_args = ["md2docx", "input.md", "output.docx"]

        with patch("sys.argv", test_args):
            main()

        # 验证convert_file被调用
        mock_convert.assert_called_once_with("input.md", "output.docx", False)

    @patch("mddocx.cli.convert_file")
    @patch("pathlib.Path.exists", return_value=True)
    def test_main_convert_command_with_debug(self, mock_exists, mock_convert):
        """测试主函数转换命令带调试选项"""
        test_args = ["md2docx", "--debug", "input.md", "output.docx"]

        with patch("sys.argv", test_args):
            main()

        # 验证convert_file被调用且debug=True
        mock_convert.assert_called_once_with("input.md", "output.docx", True)

    @patch("sys.stdout")
    def test_main_no_args(self, mock_stdout):
        """测试主函数无参数情况"""
        test_args = ["md2docx"]

        with patch("sys.argv", test_args):
            with pytest.raises(SystemExit):
                main()

    @patch("sys.stdout")
    def test_main_insufficient_args(self, mock_stdout):
        """测试主函数参数不足情况"""
        test_args = ["md2docx", "input.md"]

        with patch("sys.argv", test_args):
            with pytest.raises(SystemExit):
                main()

    @patch("sys.stdout")
    def test_main_help(self, mock_stdout):
        """测试主函数帮助信息"""
        test_args = ["md2docx", "--help"]

        with patch("sys.argv", test_args):
            with pytest.raises(SystemExit):
                main()

    @patch("sys.stdout")
    def test_main_version(self, mock_stdout):
        """测试主函数版本信息"""
        test_args = ["md2docx", "--version"]

        with patch("sys.argv", test_args):
            with pytest.raises(SystemExit):
                main()

    def test_convert_file_output_file_exists(self):
        """测试输出文件已存在的情况"""
        # 创建临时文件
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".md", delete=False, encoding="utf-8"
        ) as md_file:
            md_file.write("# 测试标题")
            md_path = md_file.name

        # 创建已存在的输出文件
        with tempfile.NamedTemporaryFile(suffix=".docx", delete=False) as existing_docx:
            docx_path = existing_docx.name
            existing_docx.write(b"dummy content")

        try:
            # 测试转换到已存在的文件
            convert_file(md_path, docx_path, debug=False)

            # 验证文件仍然存在且内容被更新
            assert os.path.exists(docx_path)
            assert os.path.getsize(docx_path) > 0

        finally:
            for path in [md_path, docx_path]:
                if os.path.exists(path):
                    os.unlink(path)
