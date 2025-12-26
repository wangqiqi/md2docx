"""
基础转换器模块，处理 Markdown 到 DOCX 的核心转换逻辑
"""

from typing import Dict, List, Tuple

from docx import Document
from markdown_it import MarkdownIt

from .elements import (
    BlockquoteConverter,
    CodeConverter,
    HeadingConverter,
    HRConverter,
    HtmlConverter,
    ImageConverter,
    LinkConverter,
    ListConverter,
    TableConverter,
    TaskListConverter,
    TextConverter,
)
from .elements.base import ElementConverter


class MD2DocxError(Exception):
    """基础异常类"""

    pass


class ParseError(MD2DocxError):
    """解析错误"""

    pass


class ConvertError(MD2DocxError):
    """转换错误"""

    pass


class BaseConverter:
    """基础转换器，处理文档结构"""

    def __init__(self, debug=False):
        """初始化转换器

        Args:
            debug: 是否显示调试信息
        """
        # 调试模式
        self.debug = debug

        # 启用所有需要的插件
        self.md = (
            MarkdownIt("commonmark", {"breaks": True, "html": True})  # 启用HTML支持
            .enable("strikethrough")
            .enable("emphasis")
            .enable("table")
        )  # 启用表格支持
        self.document = Document()
        self.converters = {}
        self._list_stack: List[Tuple[str, int]] = []  # [(list_type, level), ...]

        # 自动注册所有转换器
        self._register_default_converters()

        # 调试信息
        if self.debug:
            print(f"转换器注册完成: {self.converters.keys()}")

    def _register_default_converters(self):
        """注册默认的转换器"""
        self.register_converter("heading", HeadingConverter(self))
        self.register_converter("text", TextConverter(self))
        self.register_converter("blockquote", BlockquoteConverter(self))
        self.register_converter("list", ListConverter(self))
        self.register_converter("code", CodeConverter(self))
        self.register_converter("link", LinkConverter(self))
        self.register_converter("image", ImageConverter(self))
        self.register_converter("table", TableConverter(self))
        self.register_converter("hr", HRConverter(self))
        self.register_converter("task_list", TaskListConverter(self))
        self.register_converter("html", HtmlConverter(self))  # 注册HTML转换器

    def register_converter(self, element_type: str, converter: ElementConverter):
        """注册一个元素转换器

        Args:
            element_type: 元素类型
            converter: 对应的转换器实例
        """
        converter.set_document(self.document)
        self.converters[element_type] = converter

    def convert(self, md_text: str) -> Document:
        """将 Markdown 文本转换为 DOCX 文档

        Args:
            md_text: Markdown 文本

        Returns:
            Document: 生成的 DOCX 文档

        Raises:
            ParseError: Markdown 解析错误
            ConvertError: 转换过程错误
        """
        try:
            # 解析 Markdown 文本为 AST
            tokens = self.md.parse(md_text)

            # 调试：打印所有标记
            if self.debug:
                print(
                    "-----------------==============================================="
                )
                print(tokens)
                print(
                    "-----------------==============================================="
                )

                for token in tokens:
                    print(
                        f"Token type={token.type}, tag={token.tag if hasattr(token, 'tag') else ''}, content={token.content if hasattr(token, 'content') else ''}"
                    )
                    if hasattr(token, "children") and token.children is not None:
                        for child in token.children:
                            print(
                                f"  Child: type={child.type}, content={child.content if hasattr(child, 'content') else ''}"
                            )

            # 用于跟踪已处理的段落，避免重复处理
            processed_paragraphs = set()

            # 转换每个节点
            i = 0
            while i < len(tokens):
                token = tokens[i]
                # 调试信息
                if self.debug:
                    print(
                        f"Processing token: type={token.type}, tag={token.tag if hasattr(token, 'tag') else ''}"
                    )

                # 处理标题
                if token.type == "heading_open":
                    converter = self.converters.get("heading")
                    if converter and i + 1 < len(tokens):
                        content_token = tokens[i + 1]
                        if content_token.type == "inline":
                            converter.convert((token, content_token))
                            i += 2  # 跳过内容标记

                # 处理引用块
                elif token.type == "blockquote_open":
                    converter = self.converters.get("blockquote")
                    if converter:
                        # 查找引用块的内容
                        content_start = i + 1
                        content_end = content_start
                        nesting_level = 1

                        while content_end < len(tokens):
                            if tokens[content_end].type == "blockquote_open":
                                nesting_level += 1
                            elif tokens[content_end].type == "blockquote_close":
                                nesting_level -= 1
                                if nesting_level == 0:
                                    break
                            content_end += 1

                        if content_end < len(tokens):
                            # 处理引用块内的内容
                            j = content_start
                            empty_quote = True
                            while j < content_end:
                                if (
                                    tokens[j].type == "paragraph_open"
                                    and j + 1 < content_end
                                ):
                                    content_token = tokens[j + 1]
                                    if content_token.type == "inline":
                                        # 获取当前引用块的层级
                                        current_level = 0
                                        k = j
                                        while k >= 0:
                                            if tokens[k].type == "blockquote_open":
                                                current_level += 1
                                            k -= 1
                                        # 使用正确的引用块标记
                                        quote_token = tokens[i]
                                        quote_token.markup = ">" * current_level
                                        converter.convert((quote_token, content_token))
                                        empty_quote = False
                                        j += 2
                                        continue
                                j += 1

                            # 处理空引用块
                            if empty_quote:
                                converter.convert((tokens[i], None))

                            i = content_end  # 跳到引用块结束标记

                # 处理列表
                elif token.type in ("bullet_list_open", "ordered_list_open"):
                    # 更新列表栈
                    list_type = (
                        "ordered" if token.type == "ordered_list_open" else "bullet"
                    )
                    level = len(self._list_stack) + 1
                    self._list_stack.append((list_type, level))
                    if self.debug:
                        print(f"列表开始: {token.type}, 栈={self._list_stack}")
                    i += 1

                # 处理列表项
                elif token.type == "list_item_open":
                    converter = self.converters.get("list")
                    if converter:
                        # 获取列表类型和级别
                        list_type = (
                            self._list_stack[-1][0] if self._list_stack else "bullet"
                        )
                        level = self._list_stack[-1][1] if self._list_stack else 1

                        if self.debug:
                            print(
                                f"处理列表项: 栈={self._list_stack}, list_type={list_type}, level={level}"
                            )

                        # 创建列表token
                        list_token = type(
                            "ListToken",
                            (),
                            {
                                "type": f"{list_type}_list_open",
                                "content": "  " * (level - 1),
                            },
                        )

                        # 查找列表项内容 - 简化逻辑，遇到嵌套列表时停止
                        content_token = None
                        j = i + 1
                        paragraph_indices = []

                        while j < len(tokens) and tokens[j].type not in (
                            "list_item_close",
                            "ordered_list_open",
                            "bullet_list_open",
                        ):
                            if tokens[j].type == "paragraph_open" and j + 1 < len(
                                tokens
                            ):
                                content_token = tokens[j + 1]
                                paragraph_indices.append(j)
                                if content_token.type == "inline":
                                    break
                            j += 1

                        # 处理空列表项
                        if not content_token:
                            content_token = type(
                                "EmptyToken", (), {"type": "inline", "children": []}
                            )

                        # 检查是否为任务列表项
                        is_task_list = False
                        if content_token.type == "inline" and hasattr(
                            content_token, "content"
                        ):
                            content = content_token.content.strip()
                            if content.startswith("[ ] ") or content.startswith("[x] "):
                                is_task_list = True

                        # 使用任务列表转换器或普通列表转换器
                        if is_task_list and "task_list" in self.converters:
                            self.converters["task_list"].convert(
                                (list_token, content_token)
                            )
                            # 记录已处理的段落，避免重复处理
                            for paragraph_index in paragraph_indices:
                                processed_paragraphs.add(paragraph_index)
                        else:
                            converter.convert((list_token, content_token))

                        # 跳过已处理的段落
                        for paragraph_index in paragraph_indices:
                            processed_paragraphs.add(paragraph_index)

                        # 移动到下一个token
                        i = j
                    else:
                        i += 1

                # 处理列表结束
                elif token.type in ("bullet_list_close", "ordered_list_close"):
                    if self.debug:
                        print(
                            f"列表结束前栈: {self._list_stack}, token: {token.type}, level: {getattr(token, 'level', 'N/A')}"
                        )
                    # 弹出栈中对应的列表
                    # markdown-it-py 的 level 从 0 开始，我们的栈 level 从 1 开始
                    current_token_level = getattr(token, "level", 0)
                    # markdown-it-py level=0 -> 栈 level=1, level=2 -> 栈 level=2
                    target_level = (current_token_level // 2) + 1
                    # 弹出栈顶 level == target_level 的项
                    if self._list_stack and self._list_stack[-1][1] == target_level:
                        self._list_stack.pop()
                    if self.debug:
                        print(f"列表结束后栈: {self._list_stack}")
                    i += 1

                # 处理代码块
                elif token.type == "fence":
                    converter = self.converters.get("code")
                    if converter:
                        converter.convert(token)
                    i += 1

                # 处理图片
                elif token.type == "image":
                    converter = self.converters.get("image")
                    if converter:
                        converter.convert((token, token))
                    i += 1

                # 处理水平线
                elif token.type == "hr":
                    converter = self.converters.get("hr")
                    if converter:
                        converter.convert(token)
                    else:
                        self.document.add_paragraph("---")
                    i += 1

                # 处理表格
                elif token.type == "table_open":
                    converter = self.converters.get("table")
                    if converter:
                        # 查找表格的结束位置
                        table_end = i + 1
                        while (
                            table_end < len(tokens)
                            and tokens[table_end].type != "table_close"
                        ):
                            table_end += 1

                        if table_end < len(tokens):
                            # 提取整个表格的tokens
                            table_tokens = tokens[i : table_end + 1]
                            if self.debug:
                                print(f"处理表格tokens: {table_tokens}")
                            converter.convert(tokens[i], table_tokens)
                            i = table_end + 1  # 跳过整个表格
                        else:
                            i += 1
                    else:
                        i += 1

                # 处理HTML标签
                elif token.type == "html_block" or token.type == "html_inline":
                    converter = self.converters.get("html")
                    if converter:
                        if self.debug:
                            print(
                                f"处理HTML标签: {token.content if hasattr(token, 'content') else ''}"
                            )
                        converter.convert(token)
                    i += 1

                # 处理段落
                elif token.type == "paragraph_open":
                    # 检查是否已经处理过这个段落
                    if i in processed_paragraphs:
                        # 跳过已处理的段落
                        i += 2  # 跳过段落开始和内容标记
                        while i < len(tokens) and tokens[i].type != "paragraph_close":
                            i += 1
                        i += 1  # 跳过段落结束标记
                    else:
                        converter = self.converters.get("text")
                        if converter and i + 1 < len(tokens):
                            content_token = tokens[i + 1]
                            if content_token.type == "inline":
                                # 检查是否为任务列表项
                                is_task_list = False
                                if hasattr(content_token, "content"):
                                    content = content_token.content.strip()
                                    if content.startswith("[ ] ") or content.startswith(
                                        "[x] "
                                    ):
                                        is_task_list = True

                                # 如果是任务列表项，使用任务列表转换器
                                if is_task_list and "task_list" in self.converters:
                                    # 创建一个虚拟的列表token
                                    list_token = type(
                                        "ListToken",
                                        (),
                                        {"type": "bullet_list_open", "content": ""},
                                    )
                                    self.converters["task_list"].convert(
                                        (list_token, content_token)
                                    )
                                else:
                                    converter.convert((token, content_token))
                                i += 2  # 跳过内容标记
                        else:
                            i += 1
                else:
                    i += 1

            return self.document

        except Exception as e:
            if isinstance(e, MD2DocxError):
                raise
            raise ConvertError(f"转换失败: {str(e)}")
