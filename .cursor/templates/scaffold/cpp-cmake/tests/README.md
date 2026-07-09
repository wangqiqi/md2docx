# Tests

独立 `tests/` 目录，GoogleTest（CMake FetchContent）。

```bash
./scripts/test.sh       # 构建并跑单元测试
./scripts/verify.sh     # 同 test + 主程序构建
ctest --test-dir build --output-on-failure -V
```

| 文件 | 用途 |
|------|------|
| `*_test.cpp` | GoogleTest 用例 |
