"""
测试配置文件
"""

import sys
from pathlib import Path

import pytest
from docx import Document

# 添加 src 目录到 Python 路径
TESTS_DIR = Path(__file__).parent
PROJECT_ROOT = TESTS_DIR.parent
SRC_PATH = PROJECT_ROOT / "src"
sys.path.insert(0, str(SRC_PATH))

# 基础导入
from mddocx.converter.base import BaseConverter
from mddocx.converter.elements import (
    BlockquoteConverter,
    CodeConverter,
    HeadingConverter,
    ListConverter,
    TextConverter,
)
from mddocx.converter.elements.html import HTML2DOCX_AVAILABLE


@pytest.fixture
def base_converter():
    """创建基础转换器实例"""
    return BaseConverter()


@pytest.fixture
def converter():
    """创建配置好的转换器实例"""
    conv = BaseConverter()
    conv.document = Document()

    # 注册所有转换器
    conv.register_converter("heading", HeadingConverter())
    conv.register_converter("paragraph", TextConverter())
    conv.register_converter("blockquote", BlockquoteConverter())
    conv.register_converter("list", ListConverter())
    conv.register_converter("code", CodeConverter())

    return conv


@pytest.fixture
def samples_dir():
    """获取测试样例目录"""
    return TESTS_DIR / "samples" / "basic"
