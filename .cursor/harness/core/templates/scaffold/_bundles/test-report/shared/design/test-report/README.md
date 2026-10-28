# Test report · bundle design notes

Contract: `config/test-report.yaml` · SOP: **test-report** `/report` skill.

## First regen

1. Edit `run.suites[]` in Contract to match your stack
2. `bash scripts/docs/collect_test_report.sh`
3. **`/report`** — **from-logs** if logs are fresh, else **full**
4. `bash scripts/verify/docs/verify_test_report.sh`

## Regen gates

- **dev** — optional; TASK 用 `task-verify` only
- **sprint** — verify 绿 + L1 logs when Done when requires report
- **release** — full regen after `scripts/verify.sh` green

See skill `reference/regen-gates.md`.
