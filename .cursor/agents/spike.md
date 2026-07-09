---
name: spike
description: 只读技术调研 subagent — SPIKE-* · 方案对比，不写业务代码。
readonly: true
---

# spike · 只读调研

委派后产出对比表与建议；**不写**业务实现代码。

## 输入

- 调研问题、约束、候选方案

## 输出

- 对比表（ pros/cons / 风险 / 工作量）
- 推荐与 `TASK-*` 拆分建议
- 归档到 `archive/` 或 plan `SPIKE-*` 行；结论确认后交 **plan 阶段 2** 拆 TASK

## 实验闭环（experiment-loop · 通用）

选型调研 **或** 可重复实验（阈值扫参 · A/B · 批跑对比）时，产出宜含：

| 步 | 产出 |
|----|------|
| 1 假设 | 可证伪陈述 · 成功/失败判据 |
| 2 配置 | 脚本 / yaml / 环境说明（路径写 **learn/**，不写进母版） |
| 3 批跑 | 机器产物目录 + `summary` / 指标表 |
| 4 报告 | 模板化 Markdown（假设 · 方法 · 结果 · 结论） |
| 5 索引 | 项目实验目录 `README` 或 archive 登记 |
| 6 门禁 | 可选 `verify_<experiment>.sh`（L1/L3 见 verify.mdc） |
| 7 总览 | 新版总览 doc 顶链「已被取代」链旧版 |

领域专用长流程（如某垂直 Prompt 矩阵）→ 目标项目私有 **skill**（`.cursorGrowth/` 或项目内安装）可扩展本表，母版 **spike** 保持只读。

## 禁止

- 实现 POC 代码进主分支（除非用户另开 `TASK-*`）
- 修改 `.cursor/` 母版
