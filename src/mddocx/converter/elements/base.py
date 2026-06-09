"""
基础元素转换器模块
"""

from typing import Any, Optional

from docx.document import Document as DocxDocument


class ElementConverter:
    """元素转换器基类"""

    def __init__(self, base_converter: Optional[Any] = None) -> None:
        """初始化元素转换器

        Args:
            base_converter: 基础转换器实例
        """
        self.document: Optional[DocxDocument] = None
        self.base_converter = base_converter

    def set_document(self, document: DocxDocument) -> None:
        """设置文档实例

        Args:
            document: DOCX 文档实例
        """
        self.document = document

    @property
    def doc(self) -> DocxDocument:
        """已设置的 DOCX 文档（未 set 时抛 ValueError）"""
        if self.document is None:
            raise ValueError("Document not set")
        return self.document

    def _debug_enabled(self) -> bool:
        bc = self.base_converter
        return bool(getattr(bc, "debug", False)) if bc is not None else False

    def convert(self, element: Any) -> Any:
        """转换元素（需要子类实现）

        Args:
            element: 要转换的元素

        Raises:
            NotImplementedError: 子类必须实现此方法
        """
        raise NotImplementedError("子类必须实现 convert 方法")
