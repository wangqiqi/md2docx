import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'zh-CN',
  title: 'md2docx',
  description: '功能强大的 Markdown 转 DOCX 文档转换工具',
  base: '/md2docx/',
  cleanUrls: true,
  themeConfig: {
    nav: [
      { text: '首页', link: '/' },
      { text: '指南', link: '/guide/architecture' },
      {
        text: 'GitHub',
        link: 'https://github.com/wangqiqi/md2docx',
      },
      { text: 'PyPI', link: 'https://pypi.org/project/mddocx/' },
    ],
    sidebar: [
      {
        text: '指南',
        items: [
          { text: '架构设计', link: '/guide/architecture' },
          { text: '开发指南', link: '/guide/development' },
          { text: '测试指南', link: '/guide/testing' },
          { text: 'API 与部署', link: '/guide/api-deployment' },
          { text: 'CI/CD 配置', link: '/guide/ci-cd' },
          { text: '发布流程', link: '/guide/release' },
          { text: '版本工作流', link: '/guide/version-workflow' },
        ],
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/wangqiqi/md2docx' },
    ],
    footer: {
      message: 'MIT Licensed',
      copyright: 'Copyright © md2docx contributors',
    },
    search: {
      provider: 'local',
      options: {
        locales: {
          root: {
            translations: {
              button: {
                buttonText: '搜索文档',
                buttonAriaLabel: '搜索文档',
              },
              modal: {
                displayDetails: '显示详细列表',
                resetButtonTitle: '清除查询条件',
                backButtonTitle: '关闭搜索',
                noResultsText: '无法找到相关结果',
                footer: {
                  selectText: '选择',
                  navigateText: '切换',
                  closeText: '关闭',
                },
              },
            },
          },
        },
      },
    },
  },
})
