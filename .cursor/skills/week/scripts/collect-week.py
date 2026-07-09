#!/usr/bin/env python3
"""Collect CHANGELOG entries from a workspace for the current reporting week."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from datetime import date, datetime, timedelta
from pathlib import Path

# ASCII hyphen, en-dash (U+2013), em-dash (U+2014)
DATE_SEP = "[-\u2013\u2014]"
VERSION_HEADING = re.compile(
    "^##\\s+\\[(?!Unreleased\\])[^\\]]+\\]\\s*"
    + DATE_SEP
    + r"\s*(\d{4}-\d{2}-\d{2})\s*$",
    re.IGNORECASE,
)
SKIP_DIRS = {"3rdparty", "node_modules", ".git", ".venv", "venv", "vendor", "dist", "build", "target"}


@dataclass
class WeekWindow:
    year: int
    week_number: int
    start: date
    end: date
    mode: str

    @property
    def label(self) -> str:
        return f"第{self.week_number}周"

    @property
    def range_text(self) -> str:
        return f"{self.start.isoformat()} ～ {self.end.isoformat()}"


@dataclass
class ChangelogEntry:
    repo: str
    path: str
    version: str
    release_date: str
    body: str


def year_week_number(d: date) -> int:
    """年内第 N 周：包含 1 月 1 日的那一周为第 1 周（周一至周日）。"""
    jan1 = date(d.year, 1, 1)
    week1_monday = jan1 - timedelta(days=jan1.weekday())
    target_monday = d - timedelta(days=d.weekday())
    return (target_monday - week1_monday).days // 7 + 1


def reporting_window(today: date | None = None) -> WeekWindow:
    today = today or date.today()
    monday = today - timedelta(days=today.weekday())
    if today.weekday() <= 3:
        start, end, mode = monday, today, "partial"
    else:
        start, end, mode = monday, monday + timedelta(days=6), "full"
    return WeekWindow(
        year=today.year,
        week_number=year_week_number(today),
        start=start,
        end=end,
        mode=mode,
    )


def should_skip(path: Path) -> bool:
    return any(part in SKIP_DIRS for part in path.parts)


def discover_changelogs(workspace: Path) -> list[Path]:
    found: list[Path] = []
    for path in workspace.rglob("CHANGELOG.md"):
        if should_skip(path):
            continue
        found.append(path)
    return sorted(found)


def parse_release_date(line: str) -> date | None:
    match = VERSION_HEADING.match(line.strip())
    if not match:
        return None
    return datetime.strptime(match.group(1), "%Y-%m-%d").date()


def extract_version(line: str) -> str:
    match = re.match(r"^##\s+\[([^\]]+)\]", line.strip())
    return match.group(1) if match else line.strip()


def parse_changelog(path: Path, start: date, end: date, repo: str) -> list[ChangelogEntry]:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    entries: list[ChangelogEntry] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        release = parse_release_date(line)
        if release is None:
            i += 1
            continue
        if release < start or release > end:
            i += 1
            continue
        version = extract_version(line)
        body_lines = []
        i += 1
        while i < len(lines):
            next_line = lines[i]
            if VERSION_HEADING.match(next_line.strip()) or re.match(
                r"^##\s+\[Unreleased\]", next_line.strip(), re.IGNORECASE
            ):
                break
            body_lines.append(next_line)
            i += 1
        body = "\n".join(body_lines).strip()
        entries.append(
            ChangelogEntry(
                repo=repo,
                path=str(path),
                version=version,
                release_date=release.isoformat(),
                body=body,
            )
        )
    return entries


def repo_name(path: Path, workspace: Path) -> str:
    try:
        rel = path.parent.relative_to(workspace)
    except ValueError:
        return path.parent.name
    return str(rel) if str(rel) != "." else path.parent.name


def render_raw(entries: list[ChangelogEntry], window: WeekWindow) -> str:
    lines = [
        f"# CHANGELOG 原始摘录 · {window.label}（{window.range_text}）",
        "",
        f"- 统计模式：{'周中进展（周一至今天）' if window.mode == 'partial' else '整周复盘（周一至周日）'}",
        f"- 条目数：{len(entries)}",
        "",
    ]
    if not entries:
        lines.append("_本周日期范围内未找到 CHANGELOG 版本条目。_")
        return "\n".join(lines)

    by_repo: dict[str, list[ChangelogEntry]] = {}
    for entry in entries:
        by_repo.setdefault(entry.repo, []).append(entry)

    for repo in sorted(by_repo):
        lines.extend([f"## {repo}", ""])
        for entry in sorted(by_repo[repo], key=lambda e: e.release_date, reverse=True):
            lines.extend(
                [
                    f"### [{entry.version}] - {entry.release_date}",
                    "",
                    entry.body or "_（无正文）_",
                    "",
                ]
            )
    return "\n".join(lines).rstrip() + "\n"


class ShortHelpFormatter(argparse.HelpFormatter):
    def __init__(self, prog: str) -> None:
        super().__init__(prog, max_help_position=32, width=100)


def default_workspace() -> Path:
    candidate = Path.home() / "workspace"
    return candidate if candidate.is_dir() else Path.cwd()


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=ShortHelpFormatter,
    )
    parser.add_argument(
        "--workspace",
        type=Path,
        default=None,
        help="[可选] 工作区根目录（默认 ~/workspace，不存在则用当前目录）",
    )
    parser.add_argument(
        "--today",
        type=str,
        default="",
        help="[可选] 覆盖今天日期 YYYY-MM-DD（测试用）",
    )
    parser.add_argument(
        "--format",
        choices=("json", "raw", "meta"),
        default="raw",
        help="[可选] 输出格式",
    )
    args = parser.parse_args()

    today = (
        datetime.strptime(args.today, "%Y-%m-%d").date()
        if args.today
        else date.today()
    )
    window = reporting_window(today)
    workspace = (args.workspace or default_workspace()).expanduser().resolve()

    if not workspace.is_dir():
        print(f"workspace not found: {workspace}", file=sys.stderr)
        return 1

    entries: list[ChangelogEntry] = []
    for changelog in discover_changelogs(workspace):
        entries.extend(
            parse_changelog(
                changelog,
                window.start,
                window.end,
                repo_name(changelog, workspace),
            )
        )
    entries.sort(key=lambda e: (e.release_date, e.repo), reverse=True)

    if args.format == "meta":
        payload = {**asdict(window), "workspace": str(workspace)}
        print(json.dumps(payload, default=str, ensure_ascii=False, indent=2))
    elif args.format == "json":
        payload = {
            "window": asdict(window),
            "workspace": str(workspace),
            "entries": [asdict(e) for e in entries],
        }
        print(json.dumps(payload, ensure_ascii=False, indent=2, default=str))
    else:
        print(render_raw(entries, window))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
