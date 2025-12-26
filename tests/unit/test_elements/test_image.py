"""
图片转换器单元测试
"""

from unittest.mock import MagicMock, patch

import pytest
from docx import Document

from mddocx.converter.elements.image import ImageConverter


def test_init():
    """测试初始化"""
    converter = ImageConverter()
    assert converter is not None
    assert converter.document is None

    # 测试带基础转换器的初始化
    base_converter = MagicMock()
    converter = ImageConverter(base_converter)
    assert converter.base_converter == base_converter


def test_document_not_set():
    """测试文档未设置的情况"""
    converter = ImageConverter()
    with pytest.raises(ValueError):
        converter.convert(MagicMock())


@patch("docx.text.run.Run.add_picture")
@patch("requests.get")
def test_convert_image(mock_get, mock_add_picture):
    """测试图片转换"""
    # 创建转换器
    converter = ImageConverter()
    converter.set_document(Document())

    # 模拟图片下载
    mock_response = MagicMock()
    mock_response.content = b"fake_image_data"
    mock_response.status_code = 200
    mock_get.return_value = mock_response

    # 创建模拟图片token
    image_token = MagicMock()
    image_token.type = "image"
    image_token.attrs = {"src": "https://example.com/image.png", "title": "测试图片"}
    image_token.content = "测试图片"

    # 转换图片
    paragraph = converter.convert((image_token, image_token))

    # 验证结果
    assert paragraph is not None
    mock_get.assert_called_once_with("https://example.com/image.png", timeout=10)


@patch("docx.text.run.Run.add_picture")
@patch("requests.get")
def test_convert_image_download_error(mock_get, mock_add_picture):
    """测试图片下载失败的情况"""
    # 创建转换器
    converter = ImageConverter()
    converter.set_document(Document())

    # 模拟下载失败
    mock_get.side_effect = Exception("Download failed")

    # 创建模拟图片token
    image_token = MagicMock()
    image_token.type = "image"
    image_token.attrs = {"src": "https://example.com/image.png", "title": "测试图片"}
    image_token.content = "测试图片"

    # 转换应该不会抛出异常，而是返回None或者空段落
    paragraph = converter.convert((image_token, image_token))
    assert paragraph is not None
