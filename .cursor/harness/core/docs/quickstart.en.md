# Quickstart (English)

> Minimal English entry point. Canonical (Chinese) docs: `README.md` · `.cursor/docs/`.
> Back to the English README at the repository root: `README.en.md`.

## 1. Install

（Clone or copy this repository first, then run from its root.）

```bash
./install-super-cursor.sh /path/to/your-project        # --profile full is the default
```

Then open the target project in your editor. Everything below is said to the **agent**.

## 2. First five minutes

```text
/learn    # 1) let the agent learn this repo -> .growing/learn/
/plan     # 2) freeze Goal + Done when, then split into TASK rows with executable acceptance
/run      # 3) implement the ACTIVE task; task-verify then commit
```

Notes that save round-trips:

- `/learn` first. Without it the gate and acceptance columns have nothing to work with.
- Acceptance columns must be **executable commands** (`` `./scripts/test.sh` ``, `` `npm test` `` …).
  Prose acceptance fails on purpose. Truly manual checks: `` `manual: <steps>` ``.
- One `/plan` approval + **one** `/run` is the intended rhythm; the agent keeps going through the
  task list and only stops at decision points.
- Stuck or unsure which command to use → `/master`.

## 3. Where things live

| Path | Meaning |
|------|---------|
| `.cursor/` | the installed workflow (rules · skills · hooks · config) — treat as read-only |
| `.growing/` | your project's knowledge and artifacts (git-ignored): `plan.md` · `learn/` · `archive/` |
| `.cursor/rules/local/` | your team's private rules (symlink to `.growing/rules/local/`) |

## 4. Check the installation

```bash
bash .cursor/verify-super-cursor.sh      # layout + cross-checks
bash .cursor/bin/cursor-coherence.sh     # skills/agents/rules registration
bash .cursor/bin/platform-check.sh       # environment self-check
```

## 5. Going further

| Want to… | Use |
|----------|-----|
| start an empty repository | `/scaffold` (8 stacks: React/Vue/Next · Go/Rust/Java · Python · C++; see `scaffold.sh list`) |
| run a long multi-Sprint epic | `/long` |
| verify before shipping | `/delivery` (7 dimensions) · `/report` (test report) |
| write a user manual | `/manual` |
| release: merge / PR / tag | `/release` (or the `ship` agent for autonomous tagging) |
| review a diff or PR | `review` skill / **review** agent |
| debug a failure | `debug` skill (reproduce → hypothesise → isolate → verify) |

Full routing: `.cursor/skills/master/routes.md` (canonical).
