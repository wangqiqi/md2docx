"""
任务列表转换器模块
"""

import re

from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches

from .base import ElementConverter
from .list import ListConverter


def insert_word_checkbox(paragraph, checked: bool = False) -> bool:
    """向段落插入 Word 2010+ checkbox 内容控件。成功返回 True。"""
    try:
        sdt = OxmlElement("w:sdt")
        sdt_pr = OxmlElement("w:sdtPr")

        checkbox = OxmlElement("w14:checkbox")
        checked_el = OxmlElement("w14:checked")
        checked_el.set(qn("w14:val"), "1" if checked else "0")
        checkbox.append(checked_el)

        checked_state = OxmlElement("w14:checkedState")
        checked_state.set(qn("w14:val"), "2612")
        checked_state.set(qn("w14:font"), "Segoe UI Symbol")
        checkbox.append(checked_state)

        unchecked_state = OxmlElement("w14:uncheckedState")
        unchecked_state.set(qn("w14:val"), "2610")
        unchecked_state.set(qn("w14:font"), "Segoe UI Symbol")
        checkbox.append(unchecked_state)

        sdt_pr.append(checkbox)
        sdt.append(sdt_pr)

        sdt_content = OxmlElement("w:sdtContent")
        run = OxmlElement("w:r")
        sdt_content.append(run)
        sdt.append(sdt_content)

        paragraph._p.insert(0, sdt)
        return True
    except Exception:
        return False


class TaskListConverter(ElementConverter):
    """任务列表转换器，处理Markdown中的任务列表（TODO列表）"""

    def __init__(self, base_converter=None):
        """初始化任务列表转换器

        Args:
            base_converter: 基础转换器实例
        """
        super().__init__(base_converter)
        self.debug = False
        self.list_converter = None
        if base_converter:
            self.debug = base_converter.debug
            # 获取列表转换器，用于处理基本列表结构
            if "list" in base_converter.converters:
                self.list_converter = base_converter.converters["list"]
            else:
                self.list_converter = ListConverter(base_converter)

    def convert(self, tokens):
        """转换任务列表token为DOCX带符号的列表

        Args:
            tokens: 任务列表token元组 (list_token, content_token)

        Returns:
            docx.paragraph: 创建的段落对象
        """
        if not self.document:
            raise ValueError("Document not set for TaskListConverter")

        if self.debug:
            print(f"处理任务列表: {tokens}")

        # 解析token
        list_token, content_token = tokens

        # 检查是否为任务列表项
        is_checked = False
        task_text = ""

        # 清理任务标记的正则表达式
        task_pattern = re.compile(r"^\s*\[([ x])\]\s*")

        if hasattr(content_token, "content"):
            content = content_token.content
            # 使用正则表达式检查和移除任务标记
            try:
                match = task_pattern.match(content)
                if match:
                    is_checked = match.group(1) == "x"
                    task_text = task_pattern.sub("", content)
                else:
                    task_text = content
            except TypeError:
                # 处理 content 不是字符串的情况
                task_text = str(content) if content is not None else ""
        elif hasattr(content_token, "children"):
            for child in content_token.children:
                if hasattr(child, "type") and child.type == "checkbox_input":
                    is_checked = (
                        child.attrs.get("checked", False)
                        if hasattr(child, "attrs")
                        else False
                    )
                elif hasattr(child, "content"):
                    # 使用正则表达式移除内容中的任务标记
                    try:
                        child_content = child.content
                        match = task_pattern.match(child_content)
                        if match:
                            child_content = task_pattern.sub("", child_content)
                        task_text += child_content
                    except TypeError:
                        # 处理 child.content 不是字符串的情况
                        task_text += (
                            str(child.content) if child.content is not None else ""
                        )

        paragraph = self.document.add_paragraph()

        if not insert_word_checkbox(paragraph, is_checked):
            checkbox_symbol = "☐ " if not is_checked else "☑ "
            paragraph.add_run(checkbox_symbol + task_text)
        else:
            if task_text.strip():
                paragraph.add_run(" " + task_text.strip())

        # 获取列表层级（从 list_token 中推断）
        level = 1
        if hasattr(list_token, "content"):
            indent = len(list_token.content)
            level = (indent // 2) + 1

        indent_inches = 0.25 * (level - 1)
        paragraph.paragraph_format.left_indent = Inches(indent_inches)
        paragraph.paragraph_format.first_line_indent = Inches(-0.25)

        return paragraph

    def _add_checkbox(self, paragraph, is_checked=False):
        """向段落添加复选框（兼容旧测试接口）。"""
        if paragraph is None:
            if self.debug:
                print("警告: 尝试向None段落添加复选框")
            return

        if insert_word_checkbox(paragraph, is_checked):
            return

        if not paragraph.runs:
            run = paragraph.add_run()
        else:
            run = paragraph.runs[0]

        if is_checked:
            run.text = "√ " + run.text
        else:
            run.text = "× " + run.text
