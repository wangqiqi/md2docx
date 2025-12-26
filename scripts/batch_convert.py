#!/usr/bin/env python3
"""
批量转换脚本 - 将指定目录下的所有 Markdown 文件转换为 DOCX 文件
支持递归查找、详细日志、命令行参数等多种功能
"""

import argparse
import logging
import os
import sys
import time
from datetime import datetime
from pathlib import Path

# 添加项目根目录到Python路径
script_dir = Path(__file__).parent
project_root = script_dir.parent
sys.path.insert(0, str(project_root))
sys.path.insert(0, str(project_root / "src"))

from mddocx.converter.base import BaseConverter


def setup_logging(log_file, verbose=False):
    """配置日志"""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[logging.FileHandler(log_file), logging.StreamHandler()],
    )
    return logging.getLogger(__name__)


def convert_file(input_file, output_file, debug=False, logger=None):
    """
    转换单个 Markdown 文件为 DOCX 文件

    Args:
        input_file: 输入文件路径
        output_file: 输出文件路径
        debug: 是否启用调试模式
        logger: 日志记录器

    Returns:
        bool: 转换是否成功
    """
    logger.info(f"开始转换: {input_file} -> {output_file}")

    try:
        # 检查文件是否存在
        if not Path(input_file).exists():
            logger.error(f"文件不存在: {input_file}")
            return False

        # 读取输入文件
        with open(input_file, "r", encoding="utf-8") as f:
            content = f.read()

        logger.info(f"文件大小: {len(content)} 字节")

        # 创建转换器
        start_time = time.time()
        converter = BaseConverter(debug=debug)

        # 转换文档
        doc = converter.convert(content)

        # 保存文档
        doc.save(output_file)

        end_time = time.time()
        duration = end_time - start_time
        logger.info(f"转换完成，用时: {duration:.2f}秒")
        return True

    except Exception as e:
        logger.error(f"转换失败: {str(e)}")
        import traceback

        logger.error(traceback.format_exc())
        return False


def find_markdown_files(directory):
    """递归查找目录下的所有Markdown文件"""
    md_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".md"):
                md_files.append(Path(root) / file)
    return md_files


def parse_args():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(
        description="批量转换 Markdown 文件为 DOCX 文件",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用示例:
  # 转换tests/samples目录下的所有文件
  python scripts/batch_convert.py

  # 指定输入输出目录
  python scripts/batch_convert.py --input-dir tests/samples --output-dir output

  # 转换单个文件
  python scripts/batch_convert.py --file tests/samples/test.md --output-file output/test.docx

  # 启用详细日志
  python scripts/batch_convert.py --verbose --log-file conversion.log
        """,
    )

    parser.add_argument("--debug", action="store_true", help="启用调试模式")
    parser.add_argument("--verbose", action="store_true", help="启用详细日志输出")
    parser.add_argument(
        "--input-dir",
        default="tests/samples",
        help="输入目录路径 (默认: tests/samples)",
    )
    parser.add_argument(
        "--output-dir", default="output", help="输出目录路径 (默认: output)"
    )
    parser.add_argument("--file", help="指定单个要转换的Markdown文件路径")
    parser.add_argument(
        "--output-file", help="指定单个输出文件路径（仅在使用--file时有效）"
    )
    parser.add_argument("--log-file", help="指定日志文件路径（默认自动生成）")
    parser.add_argument(
        "--recursive",
        action="store_true",
        default=True,
        help="递归查找子目录中的文件 (默认: True)",
    )
    parser.add_argument("--pattern", default="*.md", help="文件匹配模式 (默认: *.md)")

    return parser.parse_args()


def main():
    """
    批量转换 Markdown 文件为 DOCX 文件
    """
    # 解析命令行参数
    args = parse_args()

    # 配置日志
    if args.log_file:
        log_file = args.log_file
    else:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_file = f"batch_convert_{timestamp}.log"

    logger = setup_logging(log_file, args.verbose)

    # 设置调试模式
    debug = args.debug
    logger.info(f"调试模式: {'启用' if debug else '禁用'}")
    logger.info(f"日志文件: {log_file}")

    # 检查是否指定了单个文件
    if args.file:
        input_file = args.file
        # 如果没有指定输出文件，则使用输入文件名（更改扩展名）
        if args.output_file:
            output_file = args.output_file
        else:
            output_dir = args.output_dir
            Path(output_dir).mkdir(parents=True, exist_ok=True)
            output_file = Path(output_dir) / f"{Path(input_file).stem}.docx"

        logger.info(f"单文件模式: {input_file} -> {output_file}")
        success = convert_file(input_file, output_file, debug=debug, logger=logger)

        if success:
            logger.info("✅ 转换成功")
            return {"success": 1, "failed": 0}
        else:
            logger.error("❌ 转换失败")
            return {"success": 0, "failed": 1}

    # 批量转换模式
    input_dir = args.input_dir
    output_dir = args.output_dir

    logger.info("🔄 批量转换模式")
    logger.info(f"输入目录: {input_dir}")
    logger.info(f"输出目录: {output_dir}")
    logger.info(f"递归查找: {'启用' if args.recursive else '禁用'}")

    # 检查输入目录是否存在
    input_path = Path(input_dir)
    if not input_path.exists():
        logger.error(f"❌ 输入目录不存在: {input_dir}")
        return {"success": 0, "failed": 0}

    # 创建输出目录（如果不存在）
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    # 获取所有 Markdown 文件
    if args.recursive:
        md_files = find_markdown_files(input_path)
    else:
        md_files = list(input_path.glob(args.pattern))

    logger.info(f"📁 找到 {len(md_files)} 个 Markdown 文件")

    if not md_files:
        logger.warning("⚠️ 未找到任何Markdown文件")
        return {"success": 0, "failed": 0}

    # 转换结果统计
    results = {"success": 0, "failed": 0, "files": []}

    # 批量转换
    for md_file in md_files:
        # 构建输出文件路径
        if args.recursive:
            # 对于递归模式，保持相对路径结构
            relative_path = md_file.relative_to(input_path)
            output_file = output_path / relative_path.parent / f"{md_file.stem}.docx"
            output_file.parent.mkdir(parents=True, exist_ok=True)
        else:
            # 对于非递归模式，直接放在输出目录下
            output_file = output_path / f"{md_file.stem}.docx"

        logger.info("=" * 80)
        success = convert_file(
            str(md_file), str(output_file), debug=debug, logger=logger
        )

        if success:
            results["success"] += 1
            status = "✅ 成功"
        else:
            results["failed"] += 1
            status = "❌ 失败"

        results["files"].append(
            {"input": str(md_file), "output": str(output_file), "status": status}
        )

    # 输出统计结果
    logger.info("=" * 80)
    logger.info("📊 转换结果统计")
    logger.info("=" * 80)
    logger.info(f"总计文件: {len(md_files)} 个")
    logger.info(f"成功转换: {results['success']} 个")
    logger.info(f"转换失败: {results['failed']} 个")
    logger.info(f"成功率: {results['success'] / len(md_files) * 100:.2f}%")
    # 输出详细结果
    logger.info("=" * 80)
    logger.info("📋 详细结果:")
    for file_result in results["files"]:
        logger.info(
            f"{file_result['status']} {file_result['input']} -> {file_result['output']}"
        )

    # 输出文件列表
    if results["success"] > 0:
        logger.info("=" * 80)
        logger.info("📁 生成的DOCX文件:")
        for file_result in results["files"]:
            if "成功" in file_result["status"]:
                docx_path = Path(file_result["output"])
                logger.info(f"  • {docx_path.name}")

    logger.info("=" * 80)
    logger.info("🎉 批量转换完成！")

    return results


if __name__ == "__main__":
    main()
