# 全栈 mixed verify 叶拆分（通用）

> 单仓内 **前端 + 后端** 共用 `scripts/verify/` 时，部分验收脚本同时 grep 两端或跑混合 pytest — 称为 **mixed 叶**。本页描述如何 **物理拆分** 而不改断言语义。栈无关；路径用 `frontend/` · `backend/` 角色名。

真源分层仍见 **verify.mdc** · **verify-growth.md**。

## 何时拆分

| 信号 | 动作 |
|------|------|
| 单叶同时 `source` FE 与 BE 目录 | 标为 **mixed**，计划拆 `*_fe.sh` + `*_be.sh` |
| 纯 FE / 纯 BE 叶 | 迁入 `frontend/scripts/verify/<domain>/` 或 `backend/scripts/verify/<domain>/` |
| 全栈编排（E2E 起停服务） | 保留根 `scripts/verify/` 聚合脚本，子叶只断言 |

**Out of scope（卫生 Sprint）**：不改 HTTP 路由、响应 JSON 字段含义 — 仅移动脚本与 manifest 登记。

## 清单（manifest）

维护一份 **grey zone** 或 `mixed.manifest`（git 跟踪），列仍待拆或已拆的叶名。配套：

```bash
bash scripts/verify/check_mixed_manifest.sh   # 项目自建；母版仅模式
```

## 命名与落点

| 原叶 `verify_foo.sh` | FE | BE |
|----------------------|----|----|
| mixed | `frontend/scripts/verify/<domain>/verify_foo_fe.sh` | `backend/scripts/verify/<domain>/verify_foo_be.sh` |
| fe_only | `frontend/.../verify_foo.sh` | — |
| be_only | — | `backend/.../verify_foo.sh` |

- **ROOT**：自各域目录到仓库根，统一用 `../../../..`（4 级）或项目 `scripts/lib/_env.sh` 导出 `ROOT`。
- **共享库**：继续 `source` 根 `scripts/lib/`（环境 · pytest 包装 · 构建辅助）。
- **拆分纪律**：从 mixed 叶 **剪切** FE/BE 段到两个新文件；**禁止**改 grep/pytest 断言语义。

## Suite `resolve_leaf`（三路）

域 suite 按优先级解析叶路径：

```bash
BE_LEAVES="${ROOT}/backend/scripts/verify/<domain>"
FE_LEAVES="${ROOT}/frontend/scripts/verify/<domain>"
LEGACY_LEAVES="${ROOT}/scripts/verify/leaves/<domain>"

resolve_leaf() {
  local leaf="$1"
  if [[ -f "${BE_LEAVES}/${leaf}" ]]; then
    echo "${BE_LEAVES}/${leaf}"
  elif [[ -f "${FE_LEAVES}/${leaf}" ]]; then
    echo "${FE_LEAVES}/${leaf}"
  elif [[ -f "${LEGACY_LEAVES}/${leaf}" ]]; then
    echo "${LEGACY_LEAVES}/${leaf}"
  else
    echo "FAIL: missing leaf: ${leaf}" >&2
    exit 1
  fi
}
```

拆分后 suite 列表改为 `verify_foo_fe.sh` · `verify_foo_be.sh`（或 `run_leaf` 两次）。

## Deprecation shim（过渡期）

旧路径保留薄转发，避免外部 CI 断链：

```bash
#!/usr/bin/env bash
# DEPRECATED — use frontend/.../verify_foo_fe.sh + backend/.../verify_foo_be.sh
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
exec bash "${ROOT}/scripts/lib/run_verify_nested.sh" \
  "${ROOT}/frontend/scripts/verify/<domain>/verify_foo_fe.sh" \
  "${ROOT}/backend/scripts/verify/<domain>/verify_foo_be.sh"
```

清 shim 前：`grep -r` 无引用 · manifest 已删 mixed 行。

## manifest.tsv 登记

- 新 FE 纯叶 → 项目 `fe_pure.manifest`（或 tier 行）
- 新 BE 纯叶 → `be_pure.manifest`
- 已拆 mixed → 从 grey 清单 **删除** 对应行

## Agent 增量

`changed-map.json` 的 `prefixRules` 在动 `frontend/` 时挂 FE 叶、动 `backend/` 时挂 BE 叶；mixed 未拆完前可同时挂根 `scripts/verify/` 域 slice。

## 交叉引用

- verify-layers 脚手架：`scaffold apply-bundle verify-layers` · `README-verify-layers.md`
- 项目域表 → Growth `learn/plan-conventions.md` §域表
