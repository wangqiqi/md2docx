"""
基础元素转换器模块
"""

from typing import Any, Optional

from docx import Document


class ElementConverter:
    """元素转换器基类"""

    def __init__(self, base_converter: Optional[Any] = None) -> None:
        """初始化元素转换器

        Args:
            base_converter: 基础转换器实例
        """
        self.document: Optional[Document] = None
        self.base_converter = base_converter

    def set_document(self, document: Document) -> None:
        """设置文档实例

        Args:
            document: DOCX 文档实例
        """
        self.document = document

    def convert(self, element: Any) -> Any:
        """转换元素（需要子类实现）

        Args:
            element: 要转换的元素

        Raises:
            NotImplementedError: 子类必须实现此方法
        """
        raise NotImplementedError("子类必须实现 convert 方法")
