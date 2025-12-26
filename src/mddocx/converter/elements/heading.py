"""
标题转换器模块，处理 h1-h6 标题的转换
"""

from typing import Any, Dict, Tuple

from docx.shared import Pt

from .base import ElementConverter


class HeadingConverter(ElementConverter):
    """处理 h1-h6 标题的转换器"""

    # 标题样式配置
    HEADING_STYLES: Dict[int, Dict[str, Any]] = {
        1: {"name": "Heading 1", "size": 24, "bold": True},
        2: {"name": "Heading 2", "size": 20, "bold": True},
        3: {"name": "Heading 3", "size": 16, "bold": True},
        4: {"name": "Heading 4", "size": 14, "bold": True},
        5: {"name": "Heading 5", "size": 12, "bold": True},
        6: {"name": "Heading 6", "size": 12, "bold": False},
    }

    def __init__(self, base_converter=None):
        super().__init__(base_converter)

    def convert(self, tokens: Tuple[Any, Any]) -> None:
        """转换标题元素

        Args:
            tokens: (开始标记, 内容标记) 的元组
        """
        if not self.document:
            raise ValueError("Document not set")

        heading_token, content_token = tokens

        # 获取标题级别
        level = int(heading_token.tag[1])  # h1 -> 1, h2 -> 2, etc.

        if level not in self.HEADING_STYLES:
            raise ValueError(f"不支持的标题级别: {level}")

        # 获取标题文本
        text = content_token.content

        # 添加标题段落
        paragraph = self.document.add_paragraph()
        paragraph.style = self.document.styles[self.HEADING_STYLES[level]["name"]]
        run = paragraph.add_run(text)

        # 应用样式
        font = run.font
        style = self.HEADING_STYLES[level]
        font.size = Pt(style["size"])
        font.bold = style["bold"]
