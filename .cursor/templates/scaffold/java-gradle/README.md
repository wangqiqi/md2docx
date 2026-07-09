# Java + Gradle

Gradle Kotlin DSL、Java 21 toolchain、JUnit 5 与 `scripts/verify.sh`。

## 快速开始

```bash
./gradlew test
./gradlew run   # 若后续添加 application 插件
```

## 测试

标准测试根 [src/test/java/](src/test/README.md)：`unit/` + `integration/` 分包。

```bash
./scripts/test.sh
./scripts/verify.sh
```

## 约定

- 将 `com.example` 替换为你的包名
- 内置 Gradle Wrapper（`./gradlew` + `gradle/wrapper/`），开箱可 `./gradlew test`
