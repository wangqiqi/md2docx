"""
Markdown to DOCX 转换工具

一个功能强大的Markdown转DOCX文档转换工具。
"""

from __future__ import annotations

from pathlib import Path


def _read_version() -> str:
    """运行时版本：源码树读 pyproject.toml，已安装包读 distribution metadata。"""
    root = Path(__file__).resolve().parents[2]
    pyproject = root / "pyproject.toml"
    if pyproject.is_file():
        try:
            import tomllib

            data = tomllib.loads(pyproject.read_text(encoding="utf-8"))
            if data.get("project", {}).get("name") == "mddocx":
                return str(data["project"]["version"])
        except Exception:
            pass

    try:
        from importlib.metadata import version

        return version("mddocx")
    except Exception:
        return "0.0.0+unknown"


__version__ = _read_version()
__author__ = "jw.zhou"
__email__ = "zhou24388@163.com"
