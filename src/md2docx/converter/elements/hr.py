"""
分隔线转换器模块
"""

from docx.enum.text import WD_PARAGRAPH_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Pt, RGBColor

from .base import ElementConverter


class HRConverter(ElementConverter):
    """分隔线转换器，处理Markdown中的水平分隔线"""

    def __init__(self, base_converter=None):
        """初始化分隔线转换器

        Args:
            base_converter: 基础转换器实例
        """
        super().__init__(base_converter)
        self.debug = False
        if base_converter:
            self.debug = base_converter.debug

    def convert(self, token):
        """转换分隔线token为DOCX水平线

        Args:
            token: 分隔线token

        Returns:
            docx.paragraph: 包含水平线的段落
        """
        if not self.document:
            raise ValueError("Document not set for HRConverter")

        if self.debug:
            print(f"处理分隔线: {token}")

        # 创建一个空段落
        paragraph = self.document.add_paragraph()
        paragraph.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER

        # 添加水平线
        self._add_horizontal_line(paragraph)

        return paragraph

    def _add_horizontal_line(self, paragraph):
        """向段落添加水平线

        Args:
            paragraph: 要添加水平线的段落
        """
        # 创建一个运行对象
        run = paragraph.add_run()

        # 创建分隔线元素
        pPr = paragraph._element.get_or_add_pPr()
        pBdr = OxmlElement("w:pBdr")
        pPr.append(pBdr)

        # 添加底部边框作为水平线
        bottom = OxmlElement("w:bottom")
        bottom.set(qn("w:val"), "single")
        bottom.set(qn("w:sz"), "6")  # 线条粗细
        bottom.set(qn("w:space"), "1")  # 间距
        bottom.set(qn("w:color"), "000000")  # 黑色
        pBdr.append(bottom)
