# Java + Gradle (Kotlin DSL)

`src/main/java` · JUnit 5 · JDK `HttpServer` `/health`（无 Spring）· `scripts/test.sh` / `scripts/verify.sh`。

## 快速开始

```bash
# 若无 gradlew：gradle wrapper（需本机 Gradle 或 SDKMAN）
./gradlew run
curl http://localhost:8080/health
```

## 测试

```bash
./scripts/test.sh       # 开发中：JUnit（./gradlew test）
./scripts/verify.sh     # 发版前：测试 + build
```

## 目录

| 路径 | 用途 |
|------|------|
| `src/main/java/` | 应用代码 |
| `src/test/java/` | JUnit 5 |
| `scripts/test.sh` | 仅测试 |
| `scripts/verify.sh` | plan/run 全量验收 |
