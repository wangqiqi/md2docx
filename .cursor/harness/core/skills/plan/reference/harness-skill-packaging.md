# Harness · 技能包目录模式（通用 SPIKE 产出）

> 将 **Agent/推理技能** 当作版本化资产（提示词 + 配置 + 可选参考帧），而非硬编码在业务代码。适用于边缘推理、批处理研判、固定管道 LLM — **不是** ReAct/MCP 通用 Agent 框架。

## 决策表

| 能力 | 典型 harness 做法 | 何时采纳 |
|------|-------------------|----------|
| 技能 = 文档资产 | `prompt.md` + 元数据 | ✅ 默认 |
| 声明式配置 | `manifest.json` / `blueprint.json` | ✅ 单步或固定管道 |
| 编译进二进制 | `embed` 默认技能 | ✅ 离线/无外网 |
| 热加载 | 目录 watch / 注册 API | ✅ 运维可换模 |
| 坏配置 fail-loud | schema 校验拒绝加载 | ✅ 必须 |
| 多 Provider HTTP | OpenAI-compat 路由 | 仅当产品允许 |
| 工具循环 / 子 Agent | T-A-O · MCP | ❌ 除非独立 Sprint |

## 目录布局（目标态）

```text
skills/<skill_id>/
  manifest.json    # id · version · description · output_schema
  blueprint.json   # 通道 · 超时 · token 上限（不进 manifest）
  prompt.md        # 系统角色 + rules + negative（Markdown）
  reference_frames/   # 可选 · 回归用
```

## manifest 与 blueprint 分工

| 放 manifest | 放 blueprint |
|-------------|--------------|
| `id` · `name` · `version` · `description` | `max_tokens` · `temperature` · `timeout_ms` |
| `output_schema`（JSON Schema） | `channel` / 优先级 / 重试 |
| `model_hint`（可选） | 推理端点别名 |

## 与 plan / run

- 新能力：`SPIKE-*` 填上表 · 产出 `docs/` 架构节
- 实现 TASK：`Owns` 限 `skills/` 注册与校验，不扩 scope 到通用 Agent 记忆/工具
- 验收：注册非法包 FAIL ·  golden 路径回归脚本

## 交叉引用

- MCP 工具边界 → **mcp** skill  
- 项目 SLA · 侧车协议 → Growth `learn/module-map.md`（不写母版路径）
