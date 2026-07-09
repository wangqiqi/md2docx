# Tests

Java 标准测试根目录 `src/test/java/`（Gradle 约定）。

| 包 | 用途 |
|----|------|
| `com.example.unit` | 单元测试 |
| `com.example.integration` | 集成 / 冒烟测试 |

```bash
./scripts/test.sh                    # 仅测试
./gradlew test --tests '*.unit.*'    # 单元
./gradlew test --tests '*.integration.*'
./scripts/verify.sh
```
