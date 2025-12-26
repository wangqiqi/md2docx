# 使用指南 (Usage Guide)

## 📖 快速入门

### 安装部署
1. 将 `.cursor` 目录复制到您的项目根目录
2. 运行 `./.cursor/cursor-adaptation-setup.sh` 进行初始化
3. 规则将自动生效，开始智能协作

### 基础使用
- 规则会根据文件类型和上下文自动应用
- 可以使用 `@规则名` 手动引用特定规则
- 支持多规则组合使用

## 🎯 规则体系说明

### 核心规则层
- **@constitution**: AI共生宪法，定义最高协作原则
- **@philosophy**: 交流哲学与协作模式，定义具体交互规范
- **@intelligent_evolution**: 智能演进系统，统一协调感知和规则演进
- **@i18n**: 国际化支持系统，自动检测语言偏好并切换沟通
- **@platform_adapter**: 跨平台适配器，统一管理不同OS间的命令和环境
- **@module_manager**: 规则管理系统，管理规则依赖关系和激活控制

### 功能规则层
- **@generator**: 项目规则生成器，自动化生成个性化规则配置
- **@system_info**: 系统信息获取器，自动获取时间、路径和作者信息
- **@templates**: 配置模板框架，自动化生成项目初始化配置
- **@eslint**: ESLint代码质量检查，自动检测和修复JavaScript代码问题

### 演进规则层
- **@evolution-philosophy**: 演进理念和原则指导
- **@evolution-manual**: 手动演进流程管理
- **@evolution-automation**: 自动化演进系统
- **@evolution-governance**: 演进治理和保障

## 💡 使用场景示例

### 代码审查时
```markdown
@constitution @philosophy
```
基于项目宪章和协作规范进行代码审查。

### 项目规划时
```markdown
@intelligent_evolution @generator
```
利用智能感知生成适合当前项目的规则配置。

### 规则演进时
```markdown
@evolution-philosophy @evolution-manual
```
按照演进原则进行有计划的规则优化。

## ⚙️ 高级配置

### 自定义规则
1. 编辑 `.cursor/rules/*/RULE.md` 文件
2. 遵循YAML frontmatter格式
3. 更新版本号并测试

### 插件开发
```bash
# 创建插件
mkdir -p .cursor/plugins/custom/my-plugin
# 添加相关文件并启用
./.cursor/scripts/plugin_manager.sh enable my-plugin
```

## 🔧 故障排除

### 初始化失败
```bash
# 检查环境
./.cursor/scripts/env_check.sh
# 查看权限
ls -la .cursor/cursor-adaptation-setup.sh
```

### 规则不生效
- 检查文件路径是否正确
- 确认规则格式是否符合要求
- 查看控制台错误信息

### 性能问题
```bash
# 重置缓存
rm -rf .cursorGrowth/cache/
# 重新感知
./.cursor/rules/intelligent_evolution/perception.sh
```

## 📚 相关文档

- [智能进化指南](intelligent-evolution-guide.md) - 智能进化系统的详细说明和配置
- [系统信息指南](system-info-guide.md) - 系统信息获取器的使用方法和配置
- [团队规则示例](team-rules-example.md) - 团队协作规范配置示例
- [远程规则导入指南](remote-rules-guide.md) - 如何导入外部规则
- [项目README](../README.md) - 详细的项目介绍和特性说明

---

*此指南持续更新，如有问题请参考最新文档或提交Issue。*
