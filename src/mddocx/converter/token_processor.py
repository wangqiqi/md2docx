"""Markdown token 遍历与元素路由（从 BaseConverter 轻量提取）。"""

from typing import Any, List


class TokenProcessor:
    """遍历 markdown-it tokens 并 dispatch 到各 ElementConverter。"""

    def __init__(self, base_converter: Any) -> None:
        self._base = base_converter

    def process(self, tokens: List[Any]) -> None:
        # 用于跟踪已处理的段落，避免重复处理
        processed_paragraphs = set()

        # 转换每个节点
        i = 0
        while i < len(tokens):
            token = tokens[i]
            # 调试信息
            if self._base.debug:
                print(f"Processing token: type={token.type}, tag={token.tag if hasattr(token, 'tag') else ''}")

            # 处理标题
            if token.type == "heading_open":
                converter = self._base.converters.get("heading")
                if converter and i + 1 < len(tokens):
                    content_token = tokens[i + 1]
                    if content_token.type == "inline":
                        converter.convert((token, content_token))
                        i += 2  # 跳过内容标记

            # 处理引用块
            elif token.type == "blockquote_open":
                converter = self._base.converters.get("blockquote")
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
                            if tokens[j].type == "paragraph_open" and j + 1 < content_end:
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
                list_type = "ordered" if token.type == "ordered_list_open" else "bullet"
                level = len(self._base._list_stack) + 1
                self._base._list_stack.append((list_type, level))
                if self._base.debug:
                    print(f"列表开始: {token.type}, 栈={self._base._list_stack}")
                i += 1

            # 处理列表项
            elif token.type == "list_item_open":
                converter = self._base.converters.get("list")
                if converter:
                    # 获取列表类型和级别
                    list_type = self._base._list_stack[-1][0] if self._base._list_stack else "bullet"
                    level = self._base._list_stack[-1][1] if self._base._list_stack else 1

                    if self._base.debug:
                        print(f"处理列表项: 栈={self._base._list_stack}, list_type={list_type}, level={level}")

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
                        if tokens[j].type == "paragraph_open" and j + 1 < len(tokens):
                            content_token = tokens[j + 1]
                            paragraph_indices.append(j)
                            if content_token.type == "inline":
                                break
                        j += 1

                    # 处理空列表项
                    if not content_token:
                        content_token = type("EmptyToken", (), {"type": "inline", "children": []})

                    # 检查是否为任务列表项
                    is_task_list = False
                    if content_token.type == "inline" and hasattr(content_token, "content"):
                        content = content_token.content.strip()
                        if content.startswith("[ ] ") or content.startswith("[x] "):
                            is_task_list = True

                    # 使用任务列表转换器或普通列表转换器
                    if is_task_list and "task_list" in self._base.converters:
                        self._base.converters["task_list"].convert((list_token, content_token))
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
                if self._base.debug:
                    print(
                        f"列表结束前栈: {self._base._list_stack}, token: {token.type}, "
                        f"level: {getattr(token, 'level', 'N/A')}"
                    )
                # 弹出栈中对应的列表
                # markdown-it-py 的 level 从 0 开始，我们的栈 level 从 1 开始
                current_token_level = getattr(token, "level", 0)
                # markdown-it-py level=0 -> 栈 level=1, level=2 -> 栈 level=2
                target_level = (current_token_level // 2) + 1
                # 弹出栈顶 level == target_level 的项
                if self._base._list_stack and self._base._list_stack[-1][1] == target_level:
                    self._base._list_stack.pop()
                if self._base.debug:
                    print(f"列表结束后栈: {self._base._list_stack}")
                i += 1

            # 处理数学公式块
            elif token.type == "math_block":
                converter = self._base.converters.get("math")
                if converter:
                    converter.convert(token)
                i += 1

            # 处理代码块
            elif token.type == "fence":
                lang = (getattr(token, "info", "") or "").strip().lower()
                if lang == "mermaid":
                    converter = self._base.converters.get("mermaid")
                else:
                    converter = self._base.converters.get("code")
                if converter:
                    converter.convert(token)
                i += 1

            # 处理图片
            elif token.type == "image":
                converter = self._base.converters.get("image")
                if converter:
                    converter.convert((token, token))
                i += 1

            # 处理水平线
            elif token.type == "hr":
                converter = self._base.converters.get("hr")
                if converter:
                    converter.convert(token)
                else:
                    self._base.document.add_paragraph("---")
                i += 1

            # 处理表格
            elif token.type == "table_open":
                converter = self._base.converters.get("table")
                if converter:
                    # 查找表格的结束位置
                    table_end = i + 1
                    while table_end < len(tokens) and tokens[table_end].type != "table_close":
                        table_end += 1

                    if table_end < len(tokens):
                        # 提取整个表格的tokens
                        table_tokens = tokens[i : table_end + 1]
                        if self._base.debug:
                            print(f"处理表格tokens: {table_tokens}")
                        converter.convert(tokens[i], table_tokens)
                        i = table_end + 1  # 跳过整个表格
                    else:
                        i += 1
                else:
                    i += 1

            # 处理HTML标签
            elif token.type == "html_block" or token.type == "html_inline":
                converter = self._base.converters.get("html")
                if converter:
                    if self._base.debug:
                        print(f"处理HTML标签: {token.content if hasattr(token, 'content') else ''}")
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
                    converter = self._base.converters.get("text")
                    if converter and i + 1 < len(tokens):
                        content_token = tokens[i + 1]
                        if content_token.type == "inline":
                            # 检查是否为任务列表项
                            is_task_list = False
                            if hasattr(content_token, "content"):
                                content = content_token.content.strip()
                                if content.startswith("[ ] ") or content.startswith("[x] "):
                                    is_task_list = True

                            # 如果是任务列表项，使用任务列表转换器
                            if is_task_list and "task_list" in self._base.converters:
                                # 创建一个虚拟的列表token
                                list_token = type(
                                    "ListToken",
                                    (),
                                    {"type": "bullet_list_open", "content": ""},
                                )
                                self._base.converters["task_list"].convert((list_token, content_token))
                            else:
                                converter.convert((token, content_token))
                            i += 2  # 跳过内容标记
                    else:
                        i += 1
            else:
                i += 1
