"""
命令行工具
"""

import argparse
import os
import sys
import time
from pathlib import Path

from docx import Document

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


def main():
    """主函数"""
    parser = argparse.ArgumentParser(description="将 Markdown 文件转换为 DOCX 文件")
    parser.add_argument("input", help="输入的 Markdown 文件路径")
    parser.add_argument("output", help="输出的 DOCX 文件路径")
    parser.add_argument("--debug", action="store_true", help="显示调试信息")

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
