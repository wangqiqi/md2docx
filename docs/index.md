---
layout: home

hero:
  name: md2docx
  text: Markdown 转 DOCX
  tagline: 支持丰富 Markdown 语法 · CLI · WebUI · 本地处理保护隐私
  actions:
    - theme: brand
      text: 快速开始
      link: /guide/development
    - theme: alt
      text: 架构设计
      link: /guide/architecture
    - theme: alt
      text: GitHub
      link: https://github.com/wangqiqi/md2docx

features:
  - title: 完整语法支持
    details: 标题、列表、表格、代码块、Mermaid、LaTeX、任务列表与可选 HTML 块。
  - title: 命令行与 WebUI
    details: mddocx CLI 批量转换；Flask Web 界面支持预览、批量 ZIP 下载。
  - title: 质量保障
    details: 300+ pytest 用例、GitHub Actions 多版本 CI、ConvertMetrics 性能基线。
  - title: 开源可扩展
    details: MIT 许可，PyPI 发布，MCP 集成可选，欢迎贡献。
---

## 安装

```bash
pip install mddocx
```

## 快速转换

```bash
mddocx input.md -o output.docx
```

更多用法见 [开发指南](/guide/development)。
