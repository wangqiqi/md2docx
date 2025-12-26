---
description: "国际化支持系统 - 自动检测用户语言偏好并切换沟通和注释语言"
alwaysApply: true
---

# 🌍 国际化支持系统 (Internationalization Support System)

*版本: v3.0.0 | 最后更新: {{GENERATION_TIME}} | 作者: {{AUTHOR_NAME}} <{{AUTHOR_EMAIL}}>*

## 🎯 核心理念 (Core Philosophy)

国际化支持系统专注于外部交互的语言适配，保持内部规则体系的稳定性：

- **内部规则固定**：所有.cursor规则文件保持原样，无需翻译
- **外部交互适配**：根据用户特征自动切换沟通语言和代码注释语言
- **智能检测**：通过多维度信号自动识别用户语言偏好
- **渐进式适配**：从对话语境到系统级别的全方位语言支持

## 🔍 自动语言检测机制 (Automatic Language Detection)

### 多维度检测信号 (Multi-dimensional Detection Signals)

#### 1. 对话语境检测 (Conversation Context Detection)
```json
{
  "dialogue_patterns": {
    "chinese_indicators": [
      "你好", "请", "谢谢", "这个", "那个", "吗", "呢", "吧", "的", "了"
    ],
    "english_indicators": [
      "hello", "please", "thank you", "this", "that", "?", "can you", "would you"
    ],
    "confidence_threshold": 0.7
  }
}
```

#### 2. IP地址地理位置检测 (IP Geolocation Detection)
```json
{
  "ip_based_detection": {
    "china_regions": ["CN", "HK", "TW", "MO"],
    "english_speaking_regions": ["US", "GB", "CA", "AU", "NZ"],
    "confidence_weight": 0.4
  }
}
```

#### 3. 时区语言关联 (Timezone-Language Correlation)
```json
{
  "timezone_language_map": {
    "Asia/Shanghai": {"primary": "zh-CN", "secondary": "en-US"},
    "Asia/Tokyo": {"primary": "ja-JP", "secondary": "en-US"},
    "America/New_York": {"primary": "en-US", "secondary": "es-US"},
    "Europe/London": {"primary": "en-GB", "secondary": "fr-FR"}
  }
}
```

#### 4. 系统语言环境检测 (System Locale Detection)
```bash
# Linux/macOS
locale | grep LANG
# Windows PowerShell
Get-WinSystemLocale
# 检测结果示例：zh_CN.UTF-8, en_US.UTF-8, ja_JP.UTF-8
```

#### 5. 用户行为模式分析 (User Behavior Pattern Analysis)
```json
{
  "behavior_patterns": {
    "punctuation_preference": {
      "chinese_users": ["，", "。", "！", "？", "："],
      "english_users": [",", ".", "!", "?", ":"]
    },
    "expression_style": {
      "formal_chinese": ["请您", "非常感谢", "能否"],
      "casual_english": ["hey", "thanks", "can you"]
    }
  }
}
```

### 综合语言确定算法 (Comprehensive Language Determination Algorithm)

```python
class LanguageDetector:
    def __init__(self):
        self.signals = {
            'dialogue': 0.4,    # 对话语境权重
            'ip_geo': 0.3,      # IP地理位置权重
            'timezone': 0.2,    # 时区权重
            'system_locale': 0.1 # 系统语言环境权重
        }

    def detect_language(self, context_signals):
        scores = {'zh-CN': 0.0, 'en-US': 0.0, 'ja-JP': 0.0}

        # 对话语境分析
        dialogue_score = self.analyze_dialogue(context_signals['dialogue'])
        scores = self.update_scores(scores, dialogue_score, 'dialogue')

        # IP地理位置分析
        ip_score = self.analyze_ip_location(context_signals['ip'])
        scores = self.update_scores(scores, ip_score, 'ip_geo')

        # 时区分析
        timezone_score = self.analyze_timezone(context_signals['timezone'])
        scores = self.update_scores(scores, timezone_score, 'timezone')

        # 系统语言环境分析
        locale_score = self.analyze_system_locale(context_signals['locale'])
        scores = self.update_scores(scores, locale_score, 'system_locale')

        return max(scores, key=scores.get)
```

## 🗣️ 语言切换应用场景 (Language Switching Application Scenarios)

### 1. 沟通交流语言切换 (Communication Language Switching)

#### 对话响应适配 (Dialogue Response Adaptation)
```json
{
  "response_templates": {
    "zh-CN": {
      "confirmation": "好的，我明白了。让我来帮您处理这个问题。",
      "clarification": "我需要更多信息来更好地帮助您。",
      "error_handling": "抱歉，出现了错误。让我重新处理。"
    },
    "en-US": {
      "confirmation": "Got it. Let me help you with this issue.",
      "clarification": "I need more information to assist you better.",
      "error_handling": "Sorry, an error occurred. Let me handle this again."
    }
  }
}
```

#### 错误信息本地化 (Error Message Localization)
```json
{
  "error_messages": {
    "zh-CN": {
      "file_not_found": "文件未找到：{file_path}",
      "permission_denied": "权限不足，无法访问：{resource}",
      "network_error": "网络连接失败，请检查网络设置"
    },
    "en-US": {
      "file_not_found": "File not found: {file_path}",
      "permission_denied": "Permission denied: {resource}",
      "network_error": "Network connection failed, please check network settings"
    }
  }
}
```

### 2. 代码注释语言切换 (Code Comment Language Switching)

#### 自动注释生成 (Automatic Comment Generation)
```javascript
// 检测到的用户语言：zh-CN
// Generated automatically - 自动生成
function processUserData(data) {
  // 验证输入数据 - Validate input data
  if (!data) return null;

  // 处理用户信息 - Process user information
  const processed = data.map(item => ({
    id: item.id,
    name: item.name,
    // 时间戳转换 - Timestamp conversion
    createdAt: new Date(item.timestamp)
  }));

  return processed;
}
```

#### 模板注释适配 (Template Comment Adaptation)
```json
{
  "comment_templates": {
    "function_header": {
      "zh-CN": "// 函数功能：{description}\n// 参数：{params}\n// 返回值：{return_type}\n// 作者：{author}\n// 时间：{timestamp}",
      "en-US": "// Function: {description}\n// Parameters: {params}\n// Returns: {return_type}\n// Author: {author}\n// Date: {timestamp}"
    },
    "class_header": {
      "zh-CN": "// 类名：{class_name}\n// 功能描述：{description}\n// 作者：{author}\n// 创建时间：{timestamp}",
      "en-US": "// Class: {class_name}\n// Description: {description}\n// Author: {author}\n// Created: {timestamp}"
    }
  }
}
```

## 🔧 跨平台命令适配 (Cross-platform Command Adaptation)

### Linux/macOS 命令 (Linux/macOS Commands)
```bash
# 时间获取
date '+%Y-%m-%d %H:%M:%S %Z'

# Git用户信息
git config --get user.name
git config --get user.email

# 系统语言环境
locale | grep LANG
```

### Windows PowerShell 命令 (Windows PowerShell Commands)
```powershell
# 时间获取
Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"

# Git用户信息
git config --get user.name
git config --get user.email

# 系统语言环境
Get-WinSystemLocale
```

### 统一命令接口 (Unified Command Interface)
```python
class SystemCommandAdapter:
    def __init__(self, platform_detector):
        self.platform = platform_detector.detect_platform()

    def get_current_time(self):
        commands = {
            'linux': "date '+%Y-%m-%d %H:%M:%S %Z'",
            'macos': "date '+%Y-%m-%d %H:%M:%S %Z'",
            'windows': 'powershell -Command "Get-Date -Format \'yyyy-MM-dd HH:mm:ss zzz\'"'
        }
        return self.execute_command(commands[self.platform])

    def get_git_user_info(self):
        # Git命令在各平台通用
        name = self.execute_command("git config --get user.name")
        email = self.execute_command("git config --get user.email")
        return {"name": name, "email": email}
```

## 📊 语言偏好持久化 (Language Preference Persistence)

### 用户配置存储 (User Configuration Storage)
```json
{
  "user_language_profile": {
    "user_id": "unique_identifier",
    "detected_language": "zh-CN",
    "confidence_score": 0.85,
    "detection_sources": {
      "dialogue": 0.4,
      "ip_geo": 0.3,
      "timezone": 0.15
    },
    "last_updated": "2025-12-21T12:06:50+08:00",
    "override_allowed": true,
    "fallback_language": "en-US"
  }
}
```

### 偏好学习和调整 (Preference Learning and Adjustment)
```json
{
  "learning_mechanism": {
    "feedback_collection": {
      "explicit_feedback": "用户主动选择语言",
      "implicit_feedback": "基于用户编辑行为分析",
      "correction_actions": "用户修改自动生成的注释语言"
    },
    "adaptation_rules": {
      "high_confidence_threshold": 0.8,
      "learning_rate": 0.1,
      "minimum_samples": 10
    }
  }
}
```

## 🔄 集成机制 (Integration Mechanism)

### 与现有规则的集成 (Integration with Existing Rules)
- **Philosophy规则**：扩展协作模式，支持多语言交互
- **Generator规则**：在项目规则生成时包含语言偏好配置
- **System Info规则**：统一引用跨平台系统信息获取服务
- **Templates规则**：支持多语言模板选择

### 插件化架构 (Plugin Architecture)
```json
{
  "i18n_plugins": {
    "language_detectors": [
      "dialogue_detector",
      "ip_geolocation_detector",
      "timezone_detector",
      "system_locale_detector"
    ],
    "language_providers": [
      "chinese_provider",
      "english_provider",
      "japanese_provider"
    ],
    "command_adapters": [
      "linux_adapter",
      "macos_adapter",
      "windows_adapter"
    ]
  }
}
```

---

*此国际化支持系统实现了智能语言检测和切换，让.cursor规则体系能够更好地服务全球用户，同时保持内部规则的稳定性和一致性。*
