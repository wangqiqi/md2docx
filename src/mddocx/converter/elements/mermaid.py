"""
Mermaid 流程图转换器
"""

import base64
import json
from io import BytesIO
from typing import Optional

import requests
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Inches, Pt, RGBColor

from ..security import MAX_IMAGE_BYTES, is_allowed_mermaid_ink_url
from .base import ElementConverter

SUPPORTED_DIAGRAM_PREFIXES = ("graph ", "flowchart ")


def _is_valid_image_payload(data: bytes) -> bool:
    if len(data) < 8:
        return False
    if data.startswith(b"\x89PNG\r\n\x1a\n") or data.startswith(b"\xff\xd8\xff"):
        return True
    return len(data) >= 100


def is_supported_mermaid_diagram(source: str) -> bool:
    """首版仅支持 graph / flowchart 基础流程图"""
    if not source or not source.strip():
        return False
    first = source.strip().split("\n", 1)[0].strip().lower()
    return first.startswith(SUPPORTED_DIAGRAM_PREFIXES)


def build_mermaid_ink_url(diagram: str, image_type: str = "png") -> str:
    """构造 mermaid.ink 渲染 URL"""
    state = {
        "code": diagram.strip(),
        "mermaid": json.dumps({"theme": "default"}),
    }
    payload = json.dumps(state, separators=(",", ":"))
    encoded = base64.urlsafe_b64encode(payload.encode("utf-8")).decode("ascii")
    return f"https://mermaid.ink/img/{encoded}?type={image_type}"


class MermaidConverter(ElementConverter):
    """将 Mermaid graph/flowchart 渲染为图片并嵌入 DOCX"""

    def convert(self, token) -> None:
        if not self.document:
            raise ValueError("Document not set")

        source = token.content if hasattr(token, "content") else ""

        if not is_supported_mermaid_diagram(source):
            self._fallback_as_code(token, source, unsupported=True)
            return

        image_data = self._fetch_diagram_image(source)
        if image_data:
            try:
                self._embed_image(image_data)
                return
            except Exception:
                pass
        self._fallback_as_code(token, source)

    def _fetch_diagram_image(self, diagram: str) -> Optional[bytes]:
        url = build_mermaid_ink_url(diagram)
        if not is_allowed_mermaid_ink_url(url):
            return None
        try:
            response = requests.get(url, timeout=15, stream=True)
            if response.status_code != 200:
                return None
            content_type = response.headers.get("Content-Type", "")
            if content_type and "image" not in content_type:
                return None
            chunks = []
            total = 0
            for chunk in response.iter_content(chunk_size=8192):
                total += len(chunk)
                if total > MAX_IMAGE_BYTES:
                    return None
                chunks.append(chunk)
            data = b"".join(chunks)
            return data if _is_valid_image_payload(data) else None
        except Exception:
            return None

    def _embed_image(self, image_data: bytes) -> None:
        paragraph = self.doc.add_paragraph()
        paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = paragraph.add_run()
        run.add_picture(BytesIO(image_data), width=Inches(5.5))

        caption = self.doc.add_paragraph()
        caption.alignment = WD_ALIGN_PARAGRAPH.CENTER
        cap_run = caption.add_run("Mermaid 流程图")
        cap_run.italic = True
        cap_run.font.size = Pt(9)
        cap_run.font.color.rgb = RGBColor(102, 102, 102)

    def _fallback_as_code(
        self, token, source: str, unsupported: bool = False
    ) -> None:
        note = (
            "（不支持的 Mermaid 类型，已保留源码）"
            if unsupported
            else "（Mermaid 渲染失败，已保留源码）"
        )
        note_para = self.doc.add_paragraph()
        note_run = note_para.add_run(note)
        note_run.italic = True
        note_run.font.size = Pt(9)
        note_run.font.color.rgb = RGBColor(128, 128, 128)

        code_converter = None
        if self.base_converter:
            code_converter = self.base_converter.converters.get("code")
        if code_converter:
            code_converter.set_document(self.doc)
            code_converter.convert(token)
        else:
            paragraph = self.doc.add_paragraph()
            try:
                paragraph.style = "Code"
            except KeyError:
                pass
            paragraph.add_run(source)
