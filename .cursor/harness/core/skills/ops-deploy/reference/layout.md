# 部署目录布局（通用）

## 推荐（单仓全栈）

```text
repo/
├── docker-compose.yml      # 编排真源（默认根目录）
├── .env.example            # 非密钥模板；!.env.example in gitignore 例外
├── .gitignore              # .env .env.local 忽略
├── deploy/                 # 可选：nginx · systemd · k8s 片段
│   ├── nginx.conf.example
│   └── README.md           # 索引：哪些文件上线时用
├── scripts/
│   ├── README.md           # 矩阵 SSOT
│   ├── test.sh             # 开发入口
│   ├── verify.sh           # L2 聚合入口（可转发 verify/tier/）
│   ├── lib/                # 公因子（env 加载 · curl 封装）
│   ├── verify/
│   │   ├── tier/           # L0/L2/L3 orchestrator
│   │   └── domain/         # L1 verify_*.sh
│   ├── ops/                # bootstrap · seed · 运维工具
│   └── dev/                # stub · SPIKE · fixture
└── docs/deploy/            # 运维叙事（可选，与 deploy/ 互链）
```

## 禁止

| 反模式 | 改法 |
|--------|------|
| `compose/` + 根 `docker-compose.yml` 双真源 | 删冗余，保留一处 |
| nginx 在根目录、docs、deploy 各一份 | 选一真源 + 索引 |
| `.env.example` 与 README 端口不一致 | 一次 grep 对齐 |
| compose 内写死密钥 | `${VAR}` + `.env.example` 文档 |

## 与文档分工

| 内容 | 位置 |
|------|------|
| 怎么跑起来 | 根 `README.md` |
| 调参 / 生产注意 | `docs/deploy/` 或 `deploy/README.md` |
| 版本差异 | `CHANGELOG.md` |
| scripts 分级纪律 | **plan** `reference/growth-layout.md` |
