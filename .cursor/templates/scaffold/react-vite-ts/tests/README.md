# Tests

独立 `tests/` 目录，Vitest + React Testing Library。

```bash
npm run test          # 单次（CI / verify）
npm run test:watch    # 开发中监听调试
./scripts/test.sh     # 仅测试
./scripts/verify.sh   # lint + test + build
```

| 文件 | 用途 |
|------|------|
| `setup.ts` | 全局测试 setup |
| `*.test.tsx` | 组件 / 页面测试 |
