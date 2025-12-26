---
description: "项目规则生成器 - 自动化生成个性化项目规则配置"
globs: ["*.ts", "*.tsx", "*.js", "*.jsx", "*.py", "*.java", "*.go"]
alwaysApply: false
---

# 🎯 项目规则生成器 (Project Rules Generator)

*版本: v3.0.0 | 最后更新: 2025-12-26 09:14:38 CST | 作者: jw.zhou <zhou24388@163.com>*

## 启动对话模板 (Initialization Dialog Template)

**AI助手**: 你好！我是AI共生助手，我将根据你的项目情况为你生成个性化的协作规则。

为了为你生成最适合的规则，请告诉我以下信息：

### 📋 项目基本信息
1. **项目名称**: ________________________
   (用于标识和命名相关配置)

2. **项目类型**:
   - [ ] Web应用 (前端/全栈)
   - [ ] 移动应用 (iOS/Android/跨平台)
   - [ ] 后端服务 (API/微服务)
   - [ ] 工具库/SDK
   - [ ] 数据科学/AI项目
   - [ ] 文档管理/知识库项目
   - [ ] 工作日志/团队协作项目
   - [ ] 其他: ________________

3. **主要技术栈**:
   - 前端: React/Vue/Angular/Svelte/其他
   - 后端: Node.js/Python/Java/Go/Rust/其他
   - 数据库: PostgreSQL/MySQL/MongoDB/Redis/其他
   - 部署: Docker/K8s/AWS/GCP/Vercel/其他

### 👥 团队与流程信息
4. **团队规模**:
   - [ ] 个人项目
   - [ ] 小团队 (2-5人)
   - [ ] 中型团队 (6-20人)
   - [ ] 大型团队 (20+人)

5. **开发阶段**:
   - [ ] 概念验证/原型开发
   - [ ] 早期产品开发
   - [ ] 成熟产品迭代
   - [ ] 维护与支持阶段

### 🎯 质量与安全要求
6. **质量标准**:
   - [ ] 基础质量 (语法正确、基本功能)
   - [ ] 标准质量 (测试覆盖、代码审查)
   - [ ] 高质量 (性能优化、安全审计)
   - [ ] 企业级 (合规、文档完整)

7. **安全等级**:
   - [ ] 基础安全 (基本输入验证)
   - [ ] 标准安全 (认证、HTTPS)
   - [ ] 高安全 (加密、审计、安全测试)

8. **特殊需求**: ________________________
   (国际化、性能指标、第三方集成等)

### 📝 文档项目专项配置 (Document Project Specific)

9. **文档类型** (如适用):
   - [ ] 技术文档/代码文档
   - [ ] 工作日志/周报月报
   - [ ] 知识库/FAQ系统
   - [ ] 产品文档/PRD
   - [ ] 团队协作文档

10. **文档规范要求** (如适用):
    - [ ] 统一的命名规范
    - [ ] 标准化的模板格式
    - [ ] 定期更新机制
    - [ ] 版本控制要求
    - [ ] 审核流程

---

## 生成结果标识 (Generation Result Identification)

基于以上信息，我将生成：

```
项目: [项目名称]
规则版本: v3.0.0 (初始化版本)
生成时间: [时间戳]
技术栈适配: [主要技术栈]
质量标准: [选择的标准]
安全等级: [选择的等级]
```

## 规则演进机制 (Rules Evolution Mechanism)

### 版本标识系统
- **v1.0**: 基于项目信息初始生成
- **v1.1+**: 开发过程中迭代优化
- **重大变更**: 技术栈调整时升级到v2.0

### 演进触发条件
- **定期演进**: 每完成一个开发阶段进行回顾
- **事件触发**: 发现规则冲突或效率问题时
- **需求变化**: 项目需求或技术栈发生重大变化时

### 演进对话模板
**AI助手**: 我注意到这个项目已经开发了3个月，是时候回顾和优化我们的协作规则了。

请告诉我：
1. 哪些规则特别有效？
2. 哪些地方需要调整？
3. 项目有哪些新的需求或挑战？

基于你的反馈，我将为你优化规则配置...

---

## 对话流程设计 (Dialog Flow Design)

### 第一阶段：信息收集 (Information Gathering)
1. **友好开场**: 介绍自己和目的
2. **逐步引导**: 一个问题一个问题地收集信息
3. **提供选项**: 每个问题都给出常见选项
4. **允许自定义**: 支持自由输入

### 第二阶段：信息验证 (Information Validation)
1. **信息回顾**: 总结收集到的信息
2. **确认准确性**: 请用户确认信息是否正确
3. **补充缺失**: 发现遗漏时主动询问
4. **调整选项**: 根据用户反馈调整

### 第三阶段：规则生成 (Rules Generation)
1. **生成标识**: 显示版本和时间戳
2. **应用模板**: 基于收集的信息应用规则模板
3. **个性化调整**: 根据项目特点调整规则
4. **质量保证**: 内部一致性检查

### 第四阶段：部署确认 (Deployment Confirmation)
1. **预览规则**: 展示生成的规则概要
2. **解释依据**: 说明为什么这样配置
3. **获取同意**: 确认用户同意应用这些规则
4. **记录日志**: 保存生成记录用于后续优化

---

## 模板变量系统 (Template Variables System)

### 核心变量 (Core Variables)
- `{{PROJECT_NAME}}`: 项目名称
- `{{PROJECT_TYPE}}`: 项目类型
- `{{TECH_STACK}}`: 技术栈
- `{{TEAM_SIZE}}`: 团队规模
- `{{DEV_STAGE}}`: 开发阶段
- `{{QUALITY_LEVEL}}`: 质量标准
- `{{SECURITY_LEVEL}}`: 安全等级
- `{{RULES_VERSION}}`: 规则版本
- `2025-12-26 09:14:38 CST`: 生成时间（本地时区）
- `jw.zhou`: Git用户姓名
- `zhou24388@163.com`: Git用户邮箱
- `{{PROJECT_ROOT}}`: 项目根目录路径
- `{{WORK_DIR}}`: 当前工作目录

### 动态变量替换 (Dynamic Variable Replacement)
这些变量在规则应用时会被自动替换为当前用户的环境信息：

#### 跨平台命令 (Cross-platform Commands)
```typescript
// 通过@platform_adapter统一执行
const adapter = PlatformAdapterFactory.create();

const timestamp = await adapter.executeCommand('get_timestamp');
const authorName = await adapter.executeCommand('get_user_name');
const authorEmail = await adapter.executeCommand('get_user_email');
const projectRoot = await adapter.executeCommand('get_project_root');
const workDir = await adapter.executeCommand('get_work_dir');
```

实际的平台特定命令由 `@platform_adapter` 规则自动选择和执行。

**自动适配机制**：
- 下载规则后，第一次使用时会自动扫描并替换所有硬编码信息
- 支持 `cursor-adaptation-setup.sh` 脚本进行初始化配置
- 规则文件中的示例值会被替换为实际用户信息

### 条件逻辑 (Conditional Logic)
```json
{
  "collaboration_mode": "{{TEAM_SIZE == 'personal' ? 'autonomous' : 'confirmatory'}}",
  "code_review_required": "{{QUALITY_LEVEL >= 'standard'}}",
  "security_scanning": "{{SECURITY_LEVEL >= 'standard'}}"
}
```

### 自定义扩展 (Custom Extensions)
支持用户定义额外的变量和逻辑，用于特殊项目需求。

---

## 质量保证机制 (Quality Assurance)

### 环境信息获取 (Environment Information Gathering)
- **本地时间**: 必须使用系统本地时区时间，而非AI模型时间
  - 通过 `@platform_adapter` 获取准确的平台特定时间戳
  - 格式示例: `2025-12-21 12:06:50 CST`
- **Git用户信息**: 必须使用用户的git配置信息
  - 通过 `@platform_adapter` 统一获取Git用户信息
  - 示例: `jw.zhou <zhou24388@163.com>`
- **系统平台检测**: 由 `@platform_adapter` 自动检测并适配不同操作系统

### 输入验证 (Input Validation)
- **必填检查**: 确保关键信息都已提供
- **格式验证**: 检查邮箱、URL等格式正确性
- **一致性检查**: 验证前后选择的一致性

### 输出验证 (Output Validation)
- **规则完整性**: 确保生成的规则覆盖所有方面
- **逻辑一致性**: 检查规则之间没有冲突
- **适用性评估**: 验证规则适合项目特点

### 错误处理 (Error Handling)
- **优雅降级**: 信息不完整时提供合理默认值
- **用户指导**: 发现问题时提供改进建议
- **重试机制**: 支持重新开始对话流程

---

## 📝 文档生成标准 (Documentation Generation Standards)

### 时间戳规范 (Timestamp Standards)
- **必须使用本地时间**: 禁止使用AI模型内置时间戳
- **格式统一**: `YYYY-MM-DD HH:MM:SS TZ` (如: 2025-12-21 12:06:50 CST)
- **时区信息**: 包含时区标识符
- **获取命令**: 通过 `@platform_adapter` 统一获取跨平台时间戳

### 作者信息规范 (Author Information Standards)
- **使用Git配置**: 必须从 `git config` 获取用户信息
- **姓名获取**: `git config --get user.name`
- **邮箱获取**: `git config --get user.email`
- **格式规范**: `姓名 <邮箱>` (如: jw.zhou <zhou24388@163.com>)
- **禁止使用**: AI团队、机器人、通用标识

### 文档元数据 (Document Metadata)
```markdown
*版本: v3.0.0 | 最后更新: 2025-12-26 09:14:38 CST | 作者: jw.zhou <zhou24388@163.com>*
```

### 代码注释标准 (Code Comment Standards)
```javascript
// Created: 2025-12-21 12:06:50 CST
// Author: jw.zhou <zhou24388@163.com>
// Description: 功能描述
```

### 验证机制 (Validation Mechanism)
- **时间验证**: 每次生成前必须获取最新本地时间
- **作者验证**: 每次生成前必须检查git配置
- **一致性检查**: 文档内所有时间戳必须一致
- **准确性确认**: 生成后必须验证信息的准确性

---

*此生成器确保基于AI共生宪法的个性化项目规则生成，为每个项目提供最适合的协作配置。*
