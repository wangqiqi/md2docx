"""
测试配置文件
"""

import sys
from pathlib import Path

import pytest

# 添加 src 目录到 Python 路径
TESTS_DIR = Path(__file__).parent
PROJECT_ROOT = TESTS_DIR.parent
SRC_PATH = PROJECT_ROOT / "src"
sys.path.insert(0, str(SRC_PATH))

from mddocx.converter.base import BaseConverter


@pytest.fixture
def base_converter():
    """创建基础转换器实例"""
    return BaseConverter()


@pytest.fixture
def converter(base_converter):
    """创建完整功能的转换器实例（与生产环境一致）"""
    return base_converter


@pytest.fixture
def samples_dir():
    """获取基础测试样例目录（向后兼容）"""
    return TESTS_DIR / "samples" / "basic"


@pytest.fixture
def samples_basic(samples_dir):
    """基础语法样例目录"""
    return samples_dir


@pytest.fixture
def samples_advanced():
    """高级语法样例目录"""
    return TESTS_DIR / "samples" / "advanced"


@pytest.fixture
def samples_root():
    """样例根目录（含 test.md）"""
    return TESTS_DIR / "samples"
