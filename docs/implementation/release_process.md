# 🚀 发布流程实施指南 (Release Process Implementation Guide)

*版本: v1.0.0 | 最后更新: 2025-12-26 | 作者: AI Assistant*

## 🎯 概述

本文档详细记录了项目中的PyPI包发布实施过程、具体配置步骤和问题解决方案。

## 📋 PyPI发布完整流程

### 1. 🔧 发布准备阶段

#### Trusted Publisher配置
- [ ] 访问 [PyPI Publishing Settings](https://pypi.org/manage/project/mddocx/settings/publishing/)
- [ ] 点击 **"Add"** 添加新的pending publisher
- [ ] 填写配置信息：
  ```
  PyPI Project Name: mddocx
  Owner: wangqiqi
  Repository name: md2docx
  Workflow name: publish.yml
  Environment name: (留空)
  ```
- [ ] 配置完成后会出现在"Pending publishers"列表中
- [ ] **注意**: 如果项目不存在，第一次发布会自动创建项目

#### Trusted Publisher故障排查
**常见错误**: `invalid-publisher: valid token, but no corresponding publisher`
**解决方案**:
1. 确认PyPI配置完全匹配
2. 等待5-10分钟生效
3. 检查workflow文件名是否正确
4. 使用手动发布作为备用方案

#### 本地验证
- [ ] 构建包：`python -m build`
- [ ] 检查包：`twine check dist/*`
- [ ] 测试安装：`pip install dist/mddocx-0.4.3-py3-none-any.whl`

### 2. 🚀 发布执行阶段

#### 自动发布（推荐）
```bash
# 推送版本标签，自动触发发布
git tag -a v0.4.3 -m "Release version 0.4.3"
git push origin v0.4.3
```

#### 手动发布（备用）
```bash
# 如自动发布失败，使用脚本
./scripts/publish_to_pypi.sh
```

### 3. ✅ 发布验证阶段

#### PyPI可用性检查
- [ ] 访问 [PyPI项目页面](https://pypi.org/project/mddocx/)
- [ ] 确认版本 `0.4.3` 已发布
- [ ] 检查包文件完整性

#### 安装测试
```bash
# 清除缓存后安装
pip install --no-cache-dir --index-url https://pypi.org/simple/ mddocx==0.4.3

# 验证安装
python -c "import mddocx; print(f'✅ 版本: {mddocx.__version__}')"

# 运行基本功能测试
python -c "from mddocx import BaseConverter; print('✅ 导入成功')"
```

## ⚠️ 常见问题与解决方案

### Trusted Publisher配置失败
```
错误: The publisher is not configured for this project
```
**解决方案**：
1. 确认PyPI项目所有权
2. 检查GitHub仓库名称拼写
3. 等待PyPI配置生效（可能需要几分钟）

### 包发布延迟
```
包在PyPI搜索中不可见
```
**解决方案**：
1. 等待10-30分钟让索引同步
2. 直接使用PyPI官方源安装：
   ```bash
   pip install --index-url https://pypi.org/simple/ mddocx
   ```

### 权限问题
```
错误: 403 Forbidden
```
**解决方案**：
1. 验证PyPI API token权限
2. 检查Trusted Publisher配置
3. 确认GitHub Actions有正确的权限

## 📊 发布监控

### GitHub Actions监控
- 访问: https://github.com/wangqiqi/md2docx/actions/workflows/publish.yml
- 查看发布工作流执行状态
- 检查详细日志了解失败原因

### PyPI状态监控
- 项目页面: https://pypi.org/project/mddocx/
- 下载统计: https://pypi.org/project/mddocx/#files
- 依赖检查: https://pypi.org/project/mddocx/#dependencies

## 🔄 发布后的维护

### 版本管理
- [ ] 更新CHANGELOG.md记录发布内容
- [ ] 创建GitHub Release说明
- [ ] 更新文档中的版本信息

### 监控与支持
- [ ] 监控PyPI下载统计
- [ ] 处理用户反馈和问题报告
- [ ] 准备下一个版本的改进计划

## 📚 相关链接

- [通用发布管理规范](../rules/release_management.md) - 通用原则和规则
- [PyPI官方文档](https://pypi.org/help/)
- [Trusted Publisher指南](https://docs.pypi.org/trusted-publishers/)
