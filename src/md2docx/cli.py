"""
命令行工具
"""

import argparse
import sys
import time
from pathlib import Path

from . import __version__
from .converter import BaseConverter


def convert_file(input_file: str, output_file: str, debug: bool = False) -> None:
    """转换文件

    Args:
        input_file: 输入的 Markdown 文件路径
        output_file: 输出的 DOCX 文件路径
        debug: 是否显示调试信息
    """
    # 读取输入文件
    with open(input_file, "r", encoding="utf-8") as f:
        content = f.read()

    # 初始化转换器并执行转换
    converter = BaseConverter(debug=debug)
    doc = converter.convert(content)

    # 检查输出文件是否被占用，如果是则添加时间戳后缀
    output_path = Path(output_file)
    final_output_file = output_file
    attempt = 0

    while attempt < 5:  # 最多尝试5次
        try:
            # 尝试保存文件
            doc.save(final_output_file)
            print(f"转换完成: {final_output_file}")
            return
        except PermissionError:
            # 文件被占用，添加时间戳后缀
            timestamp = int(time.time())
            new_filename = f"{output_path.stem}_{timestamp}{output_path.suffix}"
            final_output_file = str(output_path.parent / new_filename)
            print(f"文件 {output_file} 被占用，尝试保存为: {final_output_file}")
            attempt += 1
        except Exception as e:
            # 其他错误，直接抛出
            raise e

    # 如果多次尝试后仍然失败
    raise PermissionError(
        f"无法保存文件，请关闭可能正在使用该文件的应用程序: {output_file}"
    )


def get_help_texts(lang="zh"):
    """获取指定语言的帮助文本"""

    texts = {
        "zh": {
            "description": """\
Markdown to DOCX 转换工具 v{0}

一个功能强大的 Markdown 转 DOCX 文档转换工具，支持丰富的 Markdown 语法。

支持的功能:
  • 标准 Markdown 语法 (标题、列表、链接、图片等)
  • 表格转换和对齐
  • 代码块和语法高亮
  • 任务列表 (TODO)
  • 引用块 (支持嵌套)
  • HTML 标签支持
  • 数学公式和流程图

项目主页: https://github.com/wangqiqi/md2docx
文档: https://github.com/wangqiqi/md2docx#readme
问题反馈: https://github.com/wangqiqi/md2docx/issues

使用示例:
  md2docx README.md output.docx
  md2docx --debug document.md report.docx
            """.format(
                __version__
            ),
            "input_help": "输入的 Markdown 文件路径",
            "output_help": "输出的 DOCX 文件路径",
            "debug_help": "显示调试信息和详细的转换过程",
            "version_help": "显示版本信息",
            "lang_help": "选择帮助信息的语言 (zh/en, 默认: zh)",
        },
        "en": {
            "description": """\
Markdown to DOCX Converter v{0}

A powerful Markdown to DOCX document conversion tool that supports rich Markdown syntax.

Supported features:
  • Standard Markdown syntax (headings, lists, links, images, etc.)
  • Table conversion and alignment
  • Code blocks with syntax highlighting
  • Task lists (TODO)
  • Blockquotes (nested support)
  • HTML tag support
  • Mathematical formulas and flowcharts

Homepage: https://github.com/wangqiqi/md2docx
Documentation: https://github.com/wangqiqi/md2docx#readme
Bug reports: https://github.com/wangqiqi/md2docx/issues

Usage examples:
  md2docx README.md output.docx
  md2docx --debug document.md report.docx
            """.format(
                __version__
            ),
            "input_help": "Path to input Markdown file",
            "output_help": "Path to output DOCX file",
            "debug_help": "Show debug information and detailed conversion process",
            "version_help": "Show version information",
            "lang_help": "Choose language for help information (zh/en, default: zh)",
        },
    }

    return texts.get(lang, texts["zh"])


def main():
    """主函数"""

    # 创建主解析器（先用英文创建，然后根据参数重新设置）
    parser = argparse.ArgumentParser(
        prog="md2docx",
        description="Markdown to DOCX Converter",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        add_help=False,  # 暂时禁用自动帮助
    )

    # 添加语言参数（需要在其他参数之前）
    parser.add_argument(
        "--lang",
        choices=["zh", "en"],
        default="zh",
        help="Choose language for help information (zh/en, default: zh)",
    )

    # 解析语言参数
    args, remaining = parser.parse_known_args()

    # 获取对应语言的文本
    texts = get_help_texts(args.lang)

    # 重新创建解析器，使用正确的语言
    parser = argparse.ArgumentParser(
        prog="md2docx",
        description=texts["description"],
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    # 重新添加语言参数
    parser.add_argument(
        "--lang",
        choices=["zh", "en"],
        default="zh",
        help=texts["lang_help"],
    )

    # 添加位置参数
    parser.add_argument("input", help=texts["input_help"])
    parser.add_argument("output", help=texts["output_help"])

    # 添加可选参数
    parser.add_argument(
        "--debug",
        action="store_true",
        help=texts["debug_help"],
    )

    # 添加版本信息
    parser.add_argument(
        "--version",
        "-V",
        action="version",
        version="md2docx v{0}".format(__version__),
        help=texts["version_help"],
    )

    # 重新解析所有参数
    args = parser.parse_args(remaining)

    args = parser.parse_args()

    if not Path(args.input).exists():
        print(f"错误: 输入文件不存在: {args.input}")
        sys.exit(1)

    try:
        convert_file(args.input, args.output, args.debug)
    except Exception as e:
        print(f"错误: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
