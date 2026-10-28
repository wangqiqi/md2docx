# Tests

| 层级 | 路径 |
|------|------|
| 集成 | `tests/*.rs`（`#[tokio::test]` + `app()`） |

```bash
./scripts/test.sh
cargo test -v
./scripts/verify.sh
```
