"""块级公式编号与 \\label / \\ref 解析。"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Dict, Optional, Tuple

LABEL_RE = re.compile(r"\\label\{([^}]+)\}")
REF_RE = re.compile(r"\\ref\{([^}]+)\}")


@dataclass
class EquationRegistry:
    """文档内公式编号与标签映射（每次转换重置）。"""

    _labels: Dict[str, int] = field(default_factory=dict)
    _counter: int = 0

    def next_number(self) -> int:
        self._counter += 1
        return self._counter

    def register(self, label: str, number: int) -> None:
        self._labels[label.strip()] = number

    def resolve(self, label: str) -> Optional[int]:
        return self._labels.get(label.strip())

    def format_number(self, number: int) -> str:
        return f"({number})"

    def resolve_ref_text(self, label: str) -> str:
        number = self.resolve(label)
        if number is None:
            return "(?)"
        return self.format_number(number)


def strip_label(latex: str) -> Tuple[str, Optional[str]]:
    """从块级 LaTeX 中剥离 ``\\label{...}``，返回清洗后源码与标签 id。"""
    match = LABEL_RE.search(latex)
    if not match:
        return latex, None
    label_id = match.group(1).strip()
    cleaned = LABEL_RE.sub("", latex).strip()
    return cleaned, label_id or None


def substitute_refs(text: str, registry: EquationRegistry) -> str:
    """将正文中的 ``\\ref{key}`` 替换为式号 ``(N)`` 或 ``(?)``。"""

    def _repl(match: re.Match[str]) -> str:
        return registry.resolve_ref_text(match.group(1))

    return REF_RE.sub(_repl, text)
