# Python FastAPI

`src/` 布局、pytest、ruff、mypy 与 `scripts/verify.sh` 验收链。

## 快速开始

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -e '.[dev]'
serve          # 或: uvicorn app.main:app --reload
curl http://localhost:8000/health
```

## 测试

独立目录 [tests/](tests/README.md)：`unit/` + `integration/` + `conftest.py`。

```bash
./scripts/test.sh
./scripts/verify.sh
```

## 工具

| 命令 | 用途 |
|------|------|
| `pytest -v tests/unit` | 单元测试 |
| `pytest -v tests/integration` | 集成测试 |
| `ruff check src tests` | Lint |
| `mypy src` | 类型检查 |
