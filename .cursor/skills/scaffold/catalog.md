# Scaffold catalog

源：`templates/scaffold/manifest.json` · 层级：**standard+**（standard + CI + `.env.example`）

| id | 类别 | 测试 | 闭环 |
|----|------|------|------|
| `react-vite-ts` | frontend | Vitest+RTL · `tests/` | test.sh → verify.sh |
| `vue-vite-ts` | frontend | Vitest · `tests/` | 同上 |
| `nextjs-ts` | frontend | Vitest · App Router | 同上 |
| `go-api` | backend | `tests/integration` + internal | 同上 |
| `rust-axum` | backend | `tests/*.rs` · `app()` | 同上 |
| `python-fastapi` | backend | unit+integration · pytest | 同上 |
| `java-gradle` | backend | Gradle Wrapper · JUnit 5 | 同上 |
| `cpp-cmake` | systems | GoogleTest · `tests/` | 同上 |

## 与 skill / rules 的关系

| 类型 | 路径 | 作用 |
|------|------|------|
| **skill** | `skills/scaffold/SKILL.md` | `/scaffold` 流程：检测 → AskQuestion → dry-run → apply |
| **模板** | `templates/scaffold/<id>/` | 项目骨架文件（非 skill） |
| **rules** | `rules/tech/*.mdc` | 创建后日常编码最佳实践（按 glob 加载） |

## post_apply

创建后 Agent 应提示用户执行 manifest 中的 `post_apply`，再 `./scripts/verify.sh`。

| id | 关键步骤 |
|----|----------|
| react / vue / nextjs | `npm install` → verify（lint+test+build） |
| go-api | 改 `go.mod` 模块路径 → `go mod tidy` → verify |
| rust-axum | `cargo test` → verify |
| python-fastapi | venv → `pip install -e '.[dev]'` → verify |
| java-gradle | `chmod +x gradlew` → verify（或 `bootstrap-gradle-wrapper.sh` 若缺 wrapper） |
| cpp-cmake | verify（cmake build + ctest） |

## 扩展

manifest 现含 **8 栈**（见上表）。用户要 **Spring Boot / Django / 其他未列栈**：AskQuestion 后 Agent 参照 **standard+** 约定手写（README + verify.sh + lint/test），或用户明确要求时再向母版贡献新模板 id。
