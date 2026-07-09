"""
基础转换器模块，处理 Markdown 到 DOCX 的核心转换逻辑
"""

import logging
import time
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from docx import Document
from docx.document import Document as DocxDocument
from markdown_it import MarkdownIt
from mdit_py_plugins.dollarmath import dollarmath_plugin

from .chunking import split_markdown_sections
from .elements import (
    BlockquoteConverter,
    CodeConverter,
    HeadingConverter,
    HRConverter,
    HtmlConverter,
    ImageConverter,
    LinkConverter,
    ListConverter,
    MathConverter,
    MermaidConverter,
    TableConverter,
    TaskListConverter,
    TextConverter,
)
from .elements.base import ElementConverter
from .equation_labels import EquationRegistry
from .security import (
    CHUNKED_THRESHOLD,
    MarkdownTooLargeError,
    markdown_utf8_byte_size,
    stream_file_byte_size,
    validate_markdown_size,
)
from .token_processor import TokenProcessor

logger = logging.getLogger(__name__)


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

    def __init__(self, debug: bool = False) -> None:
        """初始化转换器

        Args:
            debug: 是否显示调试信息
        """
        # 调试模式
        self.debug = debug

        # 启用所有需要的插件
        self.md = (
            MarkdownIt("commonmark", {"breaks": True, "html": True})
            .enable("strikethrough")
            .enable("emphasis")
            .enable("table")
            .use(dollarmath_plugin)
        )
        self.document = Document()
        self.converters: Dict[str, Any] = {}
        self._list_stack: List[Tuple[str, int]] = []  # [(list_type, level), ...]
        self._equation_registry = EquationRegistry()

        # 自动注册所有转换器
        self._register_default_converters()

        # 调试信息
        if self.debug:
            print(f"转换器注册完成: {self.converters.keys()}")

    def _reset_state(self) -> None:
        """重置文档与内部状态，使实例可安全复用"""
        self.document = Document()
        self._list_stack = []
        self._equation_registry = EquationRegistry()
        for converter in self.converters.values():
            if hasattr(converter, "_last_was_code"):
                converter._last_was_code = False
            if hasattr(converter, "_image_cache"):
                converter._image_cache = {}
            if hasattr(converter, "set_document"):
                converter.set_document(self.document)

    def _register_default_converters(self) -> None:
        """注册默认的转换器"""
        self.register_converter("heading", HeadingConverter(self))
        self.register_converter("text", TextConverter(self))
        self.register_converter("blockquote", BlockquoteConverter(self))
        self.register_converter("list", ListConverter(self))
        self.register_converter("code", CodeConverter(self))
        self.register_converter("mermaid", MermaidConverter(self))
        self.register_converter("math", MathConverter(self))
        self.register_converter("link", LinkConverter(self))
        self.register_converter("image", ImageConverter(self))
        self.register_converter("table", TableConverter(self))
        self.register_converter("hr", HRConverter(self))
        self.register_converter("task_list", TaskListConverter(self))
        self.register_converter("html", HtmlConverter(self))  # 注册HTML转换器
        self._configure_image_allowed_dirs()

    def _configure_image_allowed_dirs(self) -> None:
        """配置测试样例等额外允许的本地图片目录"""
        image_converter = self.converters.get("image")
        if not image_converter or not hasattr(image_converter, "set_extra_allowed_dirs"):
            return
        project_root = Path(__file__).resolve().parents[3]
        samples_basic = project_root / "tests" / "samples" / "basic"
        if samples_basic.is_dir():
            image_converter.set_extra_allowed_dirs({samples_basic})

    def register_converter(self, element_type: str, converter: ElementConverter) -> None:
        """注册一个元素转换器

        Args:
            element_type: 元素类型
            converter: 对应的转换器实例
        """
        converter.set_document(self.document)
        self.converters[element_type] = converter

    def convert(
        self,
        md_text: str,
        base_path: Optional[str] = None,
        chunked: Optional[bool] = None,
    ) -> DocxDocument:
        """将 Markdown 文本转换为 DOCX 文档

        Args:
            md_text: Markdown 文本
            base_path: Markdown 源文件路径，用于校验本地图片相对路径
            chunked: 是否分块转换；None 时在体积 ≥ CHUNKED_THRESHOLD 时自动启用

        Returns:
            Document: 生成的 DOCX 文档

        Raises:
            ParseError: Markdown 解析错误
            ConvertError: 转换过程错误
            MarkdownTooLargeError: 内容超过 MAX_MARKDOWN_BYTES
        """
        start = time.perf_counter()
        input_bytes = markdown_utf8_byte_size(md_text) if isinstance(md_text, str) else 0
        use_chunked = chunked
        try:
            validate_markdown_size(md_text)
            use_chunked = chunked if chunked is not None else input_bytes >= CHUNKED_THRESHOLD
            if use_chunked:
                return self._convert_chunked(md_text, base_path)
            return self._convert_tokens(md_text, base_path)
        finally:
            duration_ms = (time.perf_counter() - start) * 1000
            logger.info(
                "convert_done duration_ms=%.1f input_bytes=%d chunked=%s",
                duration_ms,
                input_bytes,
                use_chunked,
            )

    def convert_file(
        self,
        path: Path,
        chunked: Optional[bool] = None,
    ) -> DocxDocument:
        """从文件路径转换 Markdown（流式校验体积后读取）。

        Args:
            path: Markdown 文件路径
            chunked: 是否分块；None 时按体积极限自动决定

        Raises:
            FileNotFoundError: 文件不存在
            MarkdownTooLargeError: 文件超过 MAX_MARKDOWN_BYTES
        """
        file_path = Path(path)
        if not file_path.is_file():
            raise FileNotFoundError(f"输入文件不存在: {file_path}")

        stream_file_byte_size(file_path)
        content = file_path.read_text(encoding="utf-8")
        return self.convert(content, base_path=str(file_path.resolve()), chunked=chunked)

    def _setup_base_path(self, base_path: Optional[str]) -> None:
        if not base_path:
            return
        image_converter = self.converters.get("image")
        if image_converter and hasattr(image_converter, "set_base_dir"):
            image_converter.set_base_dir(Path(base_path).parent)

    def _convert_chunked(self, md_text: str, base_path: Optional[str] = None) -> DocxDocument:
        """按一级标题分块 parse + process，追加到同一 Document。"""
        try:
            self._reset_state()
            self._setup_base_path(base_path)

            if not isinstance(md_text, str):
                raise ConvertError(f"输入参数类型错误，期望 str，得到 {type(md_text).__name__}")
            if not md_text.strip():
                return self.document

            sections = split_markdown_sections(md_text)
            if not sections:
                return self.document

            processor = TokenProcessor(self)
            for section in sections:
                tokens = self.md.parse(section)
                if self.debug:
                    print(f"分块转换: section_bytes={markdown_utf8_byte_size(section)}")
                processor.process(tokens)
            return self.document

        except MarkdownTooLargeError:
            raise
        except (TypeError, ValueError) as e:
            raise ParseError(f"Markdown解析失败: {str(e)}") from e
        except MD2DocxError:
            raise
        except (KeyboardInterrupt, SystemExit):
            raise
        except Exception as e:
            raise ConvertError(f"转换过程发生错误 ({type(e).__name__}): {e}") from e

    def _convert_tokens(self, md_text: str, base_path: Optional[str] = None) -> DocxDocument:
        try:
            self._reset_state()
            self._setup_base_path(base_path)
            if not isinstance(md_text, str):
                raise ConvertError(f"输入参数类型错误，期望 str，得到 {type(md_text).__name__}")

            if not md_text.strip():
                # 空文档也创建基本的DOCX结构
                return self.document

            # 解析 Markdown 文本为 AST
            tokens = self.md.parse(md_text)

            # 调试：打印所有标记
            if self.debug:
                print("-----------------===============================================")
                print(tokens)
                print("-----------------===============================================")

                for token in tokens:
                    print(
                        f"Token type={token.type}, "
                        f"tag={token.tag if hasattr(token, 'tag') else ''}, "
                        f"content={token.content if hasattr(token, 'content') else ''}"
                    )
                    if hasattr(token, "children") and token.children is not None:
                        for child in token.children:
                            print(
                                f"  Child: type={child.type}, "
                                f"content={child.content if hasattr(child, 'content') else ''}"
                            )

            TokenProcessor(self).process(tokens)
            return self.document

        except (TypeError, ValueError) as e:
            raise ParseError(f"Markdown解析失败: {str(e)}") from e
        except MD2DocxError:
            raise
        except (KeyboardInterrupt, SystemExit):
            raise
        except Exception as e:
            raise ConvertError(f"转换过程发生错误 ({type(e).__name__}): {e}") from e
