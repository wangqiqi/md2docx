# C++ + CMake

C++20、`include/`+`src/` 分层、独立 `tests/`（GoogleTest）、`scripts/test.sh` 闭环。

## 快速开始

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
./build/app
```

## 测试

详见 [tests/README.md](tests/README.md)。

```bash
./scripts/test.sh
./scripts/verify.sh
```

## 目录

| 路径 | 用途 |
|------|------|
| `include/app/` | 公共头文件 |
| `src/` | 实现 + `main` |
| `tests/` | GoogleTest 用例 |
| `scripts/test.sh` | 仅测试 |
| `scripts/verify.sh` | plan/run 验收 |
