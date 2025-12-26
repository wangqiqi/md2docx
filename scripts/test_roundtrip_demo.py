#!/usr/bin/env python3
"""
闭环测试演示脚本
展示如何使用 markitdown 进行 MD → DOCX → MD 的闭环验证
"""

import os
import sys

from markitdown import MarkItDown

# 添加项目根目录到 Python 路径
script_dir = os.path.dirname(__file__)
project_root = os.path.dirname(script_dir)
sys.path.insert(0, project_root)
sys.path.insert(0, os.path.join(project_root, "src"))

from mddocx.converter.base import BaseConverter


def test_roundtrip():
    """简单的闭环测试示例"""

    # 测试内容
    test_md = """# 测试文档

这是一个简单的测试文档。

## 列表测试

- 项目 1
- 项目 2
  - 子项目 2.1
  - 子项目 2.2

## 代码测试

这是 `行内代码` 示例。

```
代码块
print("Hello World")
```
"""

    print("🔄 开始闭环测试...")
    print("=" * 50)

    # 1. MD → DOCX
    print("1. Markdown → DOCX")
    converter = BaseConverter()
    docx_path = "/tmp/test_roundtrip.docx"
    doc = converter.convert(test_md)
    doc.save(docx_path)
    print(f"✅ DOCX 文件已生成: {docx_path}")

    # 2. DOCX → MD
    print("\n2. DOCX → Markdown")
    markitdown = MarkItDown()
    result = markitdown.convert(docx_path)
    converted_md = result.text_content
    print("✅ 转换完成")

    # 3. 对比结果
    print("\n3. 对比结果")
    print("原始 MD 长度:", len(test_md))
    print("转换 MD 长度:", len(converted_md))
    print("\n转换后的内容预览:")
    print("-" * 30)
    print(converted_md[:200] + "..." if len(converted_md) > 200 else converted_md)

    # 清理临时文件
    if os.path.exists(docx_path):
        os.remove(docx_path)

    print("\n🎉 闭环测试完成！")
    return True


if __name__ == "__main__":
    test_roundtrip()
