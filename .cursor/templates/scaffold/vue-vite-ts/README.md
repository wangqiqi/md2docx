# Vue 3 + Vite + TypeScript

含 ESLint、Vitest、Composition API 与 `scripts/verify.sh` 验收链。

## 快速开始

```bash
npm install
npm run dev
```

## 测试

独立目录 [tests/](tests/README.md)。

```bash
npm run test:watch
./scripts/test.sh
./scripts/verify.sh
```

## 脚本

| 命令 | 用途 |
|------|------|
| `npm run dev` | 开发服务器 |
| `npm run lint` | ESLint + vue plugin |
| `npm run test` | Vitest 单次 |
| `npm run test:watch` | Vitest 监听 |
| `npm run build` | 生产构建 |
