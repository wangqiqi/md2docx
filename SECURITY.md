# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| Latest release on [GitHub Releases](https://github.com/wangqiqi/md2docx/releases) | ✅ |
| Older tags | ❌ (upgrade recommended) |

## Reporting a vulnerability

Please **do not** open a public issue for security-sensitive reports.

1. Email **zhou24388@163.com** with subject `md2docx security`.
2. Include reproduction steps, affected version, and impact.
3. We aim to acknowledge within **7 days** and coordinate a fix release.

## Dependency hygiene

- **Python**: CI runs [`pip-audit`](https://pypi.org/project/pip-audit/) after installing `pip install -e .[dev,mcp]` on a clean runner (see `.github/workflows/ci.yml`).
- **Local check**: `bash scripts/check_pip_audit.sh`
- **Updates**: [Dependabot](https://docs.github.com/en/code-security/dependabot) opens weekly PRs for `pip`, GitHub Actions, and npm (VitePress docs).

Before tagging a release, maintainers should run `bash scripts/check_pip_audit.sh` and `pytest -q` (see `docs/guide/development.md`).
