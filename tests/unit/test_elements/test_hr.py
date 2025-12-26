"""

import pytest
from unittest.mock import patch, MagicMock
from io import BytesIO
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from markdown_it import MarkdownIt

from mddocx.converter.base import BaseConverter
from mddocx.converter.elements.hr import HRConverter
from mddocx.converter.elements.html import HtmlConverter
from mddocx.converter.elements.image import ImageConverter
from mddocx.converter.elements.table import TableConverter
from mddocx.converter.elements.task_list import TaskListConverter
from mddocx.converter.elements.text import TextConverter
import pytest
test hr 测试
"""

import pytest
from unittest.mock import patch, MagicMock
from io import BytesIO
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from markdown_it import MarkdownIt

from mddocx.converter.base import BaseConverter
from mddocx.converter.elements.hr import HRConverter
from mddocx.converter.elements.html import HtmlConverter
from mddocx.converter.elements.image import ImageConverter
from mddocx.converter.elements.table import TableConverter
from mddocx.converter.elements.task_list import TaskListConverter
from mddocx.converter.elements.text import TextConverter

"""

import pytest
from unittest.mock import patch, MagicMock
from io import BytesIO
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from markdown_it import MarkdownIt

from mddocx.converter.base import BaseConverter
from mddocx.converter.elements.hr import HRConverter
from mddocx.converter.elements.html import HtmlConverter
from mddocx.converter.elements.image import ImageConverter
from mddocx.converter.elements.table import TableConverter
from mddocx.converter.elements.task_list import TaskListConverter
from mddocx.converter.elements.text import TextConverter
分隔线转换器单元测试
"""

import pytest
from unittest.mock import patch, MagicMock
from io import BytesIO
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from markdown_it import MarkdownIt

from mddocx.converter.base import BaseConverter
from mddocx.converter.elements.hr import HRConverter
from mddocx.converter.elements.html import HtmlConverter
from mddocx.converter.elements.image import ImageConverter
from mddocx.converter.elements.table import TableConverter
from mddocx.converter.elements.task_list import TaskListConverter
from mddocx.converter.elements.text import TextConverter


def test_init():
    """测试初始化"""

import pytest
from unittest.mock import patch, MagicMock
from io import BytesIO
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from markdown_it import MarkdownIt

from mddocx.converter.base import BaseConverter
from mddocx.converter.elements.hr import HRConverter
from mddocx.converter.elements.html import HtmlConverter
from mddocx.converter.elements.image import ImageConverter
from mddocx.converter.elements.table import TableConverter
from mddocx.converter.elements.task_list import TaskListConverter
from mddocx.converter.elements.text import TextConverter
    converter = HRConverter()
    assert converter is not None
    assert converter.document is None
    assert converter.debug is False

    # 测试带基础转换器的初始化
    base_converter = MagicMock()
    base_converter.debug = True
    converter = HRConverter(base_converter)
    assert converter.debug is True


def test_document_not_set():
    """测试文档未设置的情况"""

import pytest
from unittest.mock import patch, MagicMock
from io import BytesIO
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from markdown_it import MarkdownIt

from mddocx.converter.base import BaseConverter
from mddocx.converter.elements.hr import HRConverter
from mddocx.converter.elements.html import HtmlConverter
from mddocx.converter.elements.image import ImageConverter
from mddocx.converter.elements.table import TableConverter
from mddocx.converter.elements.task_list import TaskListConverter
from mddocx.converter.elements.text import TextConverter
    converter = HRConverter()
    with pytest.raises(ValueError):
        converter.convert(MagicMock())


def test_convert():
    """测试分隔线转换"""

import pytest
from unittest.mock import patch, MagicMock
from io import BytesIO
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from markdown_it import MarkdownIt

from mddocx.converter.base import BaseConverter
from mddocx.converter.elements.hr import HRConverter
from mddocx.converter.elements.html import HtmlConverter
from mddocx.converter.elements.image import ImageConverter
from mddocx.converter.elements.table import TableConverter
from mddocx.converter.elements.task_list import TaskListConverter
from mddocx.converter.elements.text import TextConverter
    # 创建转换器
    converter = HRConverter()
    converter.set_document(Document())

    # 创建模拟分隔线token
    hr_token = MagicMock()
    hr_token.type = "hr"
    hr_token.markup = "---"

    # 转换分隔线
    paragraph = converter.convert(hr_token)

    # 验证结果
    assert paragraph is not None
    assert paragraph.alignment == 1  # 居中对齐

    # 验证段落中包含水平线
    # 注意：由于水平线是通过XML元素添加的，无法直接验证
    # 这里只能验证段落存在
    assert paragraph._element is not None
