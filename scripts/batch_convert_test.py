"""
批量转换测试脚本 - 将 tests/samples/basic 目录下的所有 Markdown 文件转换为 DOCX 文件
"""
import os
import sys
import time
import logging
import argparse
from pathlib import Path
from datetime import datetime

# 添加项目根目录到 Python 路径
script_dir = os.path.dirname(__file__)
project_root = os.path.dirname(script_dir)  # scripts目录的父目录
sys.path.insert(0, project_root)

# 导入转换器
from src.converter import BaseConverter

def setup_logging(log_file):
    """配置日志"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ]
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
        if not os.path.exists(input_file):
            logger.error(f"文件不存在: {input_file}")
            return False
        
        # 读取输入文件
        with open(input_file, 'r', encoding='utf-8') as f:
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
        logger.info(f"转换完成，耗时: {end_time - start_time:.2f} 秒")
        return True
    
    except Exception as e:
        logger.error(f"转换失败: {str(e)}")
        import traceback
        logger.error(traceback.format_exc())
        return False

def parse_args():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(description='批量转换 Markdown 文件为 DOCX 文件')
    parser.add_argument('--debug', action='store_true', help='启用调试模式')
    parser.add_argument('--input-dir', default='tests/samples/basic', help='输入目录路径')
    parser.add_argument('--output-dir', default='output', help='输出目录路径')
    parser.add_argument('--file', help='指定单个要转换的Markdown文件路径')
    parser.add_argument('--output-file', help='指定单个输出文件路径（仅在使用--file时有效）')
    return parser.parse_args()

def main():
    """
    批量转换 Markdown 文件为 DOCX 文件
    """
    # 解析命令行参数
    args = parse_args()
    
    # 配置日志
    log_file = f"batch_convert_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
    logger = setup_logging(log_file)
    
    # 设置调试模式
    debug = args.debug
    logger.info(f"调试模式: {'启用' if debug else '禁用'}")
    
    # 检查是否指定了单个文件
    if args.file:
        input_file = args.file
        # 如果没有指定输出文件，则使用输入文件名（更改扩展名）
        if args.output_file:
            output_file = args.output_file
        else:
            output_dir = args.output_dir
            os.makedirs(output_dir, exist_ok=True)
            output_file = os.path.join(output_dir, f"{os.path.splitext(os.path.basename(input_file))[0]}.docx")
        
        logger.info(f"单文件模式: {input_file} -> {output_file}")
        success = convert_file(input_file, output_file, debug=debug, logger=logger)
        
        if success:
            logger.info("转换成功")
        else:
            logger.error("转换失败")
        
        return {'success': 1 if success else 0, 'failed': 0 if success else 1}
    
    # 批量转换模式
    input_dir = args.input_dir
    output_dir = args.output_dir
    
    logger.info(f"批量转换模式")
    logger.info(f"输入目录: {input_dir}")
    logger.info(f"输出目录: {output_dir}")
    
    # 创建输出目录（如果不存在）
    os.makedirs(output_dir, exist_ok=True)
    
    # 获取所有 Markdown 文件
    md_files = [f for f in os.listdir(input_dir) if f.endswith('.md')]
    
    logger.info(f"找到 {len(md_files)} 个 Markdown 文件")
    
    # 转换结果统计
    results = {
        'success': 0,
        'failed': 0,
        'files': []
    }
    
    # 批量转换
    for md_file in md_files:
        input_path = os.path.join(input_dir, md_file)
        output_path = os.path.join(output_dir, f"{os.path.splitext(md_file)[0]}.docx")
        
        logger.info(f"=" * 80)
        success = convert_file(input_path, output_path, debug=debug, logger=logger)
        
        if success:
            results['success'] += 1
            status = "成功"
        else:
            results['failed'] += 1
            status = "失败"
        
        results['files'].append({
            'input': input_path,
            'output': output_path,
            'status': status
        })
    
    # 输出统计结果
    logger.info(f"=" * 80)
    logger.info(f"转换完成，总计: {len(md_files)} 个文件")
    logger.info(f"成功: {results['success']} 个文件")
    logger.info(f"失败: {results['failed']} 个文件")
    logger.info(f"成功率: {results['success'] / len(md_files) * 100:.2f}%")
    
    # 输出详细结果
    logger.info(f"=" * 80)
    logger.info("详细结果:")
    for file_result in results['files']:
        logger.info(f"{file_result['input']} -> {file_result['output']}: {file_result['status']}")
    
    return results

if __name__ == "__main__":
    main() 