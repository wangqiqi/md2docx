# Tests

独立 `tests/` 目录，pytest + FastAPI TestClient。

| 层级 | 路径 |
|------|------|
| 公共 fixture | `conftest.py` |
| 单元 | `unit/` |
| 集成 | `integration/` |

```bash
./scripts/test.sh              # 仅测试
pytest -v tests/unit           # 单元
pytest -v tests/integration    # 集成
./scripts/verify.sh            # ruff + mypy + 全量测试
```
