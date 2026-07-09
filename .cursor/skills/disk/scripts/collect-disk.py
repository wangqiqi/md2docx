#!/usr/bin/env python3
"""Collect structured disk usage snapshots; compare changes over time."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SKILL_DIR = Path(__file__).resolve().parent.parent
DEFAULT_CONFIG = SKILL_DIR / "config" / "default-paths.json"
DEFAULT_SNAPSHOT_DIR = Path(".cursorGrowth/disk-snapshots")
TIMESTAMP_RE = re.compile(r"^\d{4}-\d{2}-\d{2}_\d{6}\.json$")
GROWTH_OVERRIDE = Path(".cursorGrowth/disk-paths.json")


def resolve_path(raw: str, home: Path, project_dir: Path, relative: bool = False) -> Path:
    if relative or raw.startswith("./"):
        base = project_dir
        rel = raw[2:] if raw.startswith("./") else raw
        return (base / rel).resolve()
    if raw == "~":
        return home
    if raw.startswith("~/"):
        return (home / raw[2:]).resolve()
    return Path(raw).resolve()


def du_bytes(path: Path) -> int | None:
    if not path.exists():
        return None
    try:
        out = subprocess.run(
            ["du", "-sb", str(path)],
            capture_output=True,
            text=True,
            check=True,
            timeout=120,
        )
        return int(out.stdout.split()[0])
    except (subprocess.CalledProcessError, ValueError, subprocess.TimeoutExpired):
        return None


def df_root(mount: str = "/") -> dict[str, int] | None:
    try:
        out = subprocess.run(
            ["df", "-B1", mount, "--output=size,used,avail"],
            capture_output=True,
            text=True,
            check=True,
        )
        lines = [ln.strip() for ln in out.stdout.strip().splitlines() if ln.strip()]
        if len(lines) < 2:
            return None
        size, used, avail = map(int, lines[-1].split())
        return {"total_bytes": size, "used_bytes": used, "avail_bytes": avail}
    except (subprocess.CalledProcessError, ValueError):
        return None


def load_path_config(config_path: Path) -> list[dict[str, Any]]:
    data = json.loads(config_path.read_text(encoding="utf-8"))
    paths = data.get("paths")
    if not isinstance(paths, list) or not paths:
        raise ValueError(f"invalid paths config: {config_path}")
    return paths


def find_config(explicit: str | None, project_dir: Path) -> Path:
    if explicit:
        return Path(explicit).expanduser().resolve()
    for candidate in (
        project_dir / GROWTH_OVERRIDE,
        Path.cwd() / GROWTH_OVERRIDE,
    ):
        if candidate.is_file():
            return candidate
    return DEFAULT_CONFIG


def collect(home: Path, project_dir: Path, config_path: Path) -> dict[str, Any]:
    path_specs = load_path_config(config_path)
    entries: dict[str, Any] = {}
    for spec in path_specs:
        key = spec["key"]
        label = spec.get("label", key)
        raw_path = spec["path"]
        kind = spec.get("kind", "directory")
        is_relative = bool(spec.get("relative")) or str(raw_path).startswith("./")
        resolved = resolve_path(str(raw_path), home, project_dir, relative=is_relative)

        if kind == "filesystem" or raw_path == "/":
            root = df_root(str(raw_path))
            if root:
                entries[key] = {"label": label, "path": str(resolved), **root}
            else:
                entries[key] = {"label": label, "path": str(resolved), "bytes": None, "exists": False}
            continue

        if resolved.is_file():
            nbytes = resolved.stat().st_size if resolved.exists() else None
        else:
            nbytes = du_bytes(resolved)

        entries[key] = {
            "label": label,
            "path": str(resolved),
            "bytes": nbytes,
            "exists": resolved.exists(),
        }

    return {
        "meta": {
            "timestamp": datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds"),
            "config": str(config_path),
            "home": str(home),
            "project_dir": str(project_dir),
        },
        "entries": entries,
    }


def format_bytes(n: int | None) -> str:
    if n is None:
        return "N/A"
    if n < 1024:
        return f"{n} B"
    for unit, div in (("KB", 1024), ("MB", 1024**2), ("GB", 1024**3), ("TB", 1024**4)):
        if n < div * 1024 or unit == "TB":
            return f"{n / div:.2f} {unit}"
    return f"{n} B"


def display_path(path: str, home: Path) -> str:
    home_s = str(home)
    if path.startswith(home_s):
        return "~" + path[len(home_s) :]
    return path


def delta_bytes(before: int | None, after: int | None) -> int | None:
    if before is None or after is None:
        return None
    return after - before


def list_snapshots(snapshot_dir: Path) -> list[Path]:
    if not snapshot_dir.is_dir():
        return []
    files = [p for p in snapshot_dir.iterdir() if TIMESTAMP_RE.match(p.name)]
    return sorted(files, key=lambda p: p.name)


def write_snapshot(data: dict[str, Any], snapshot_dir: Path) -> Path:
    snapshot_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    out = snapshot_dir / f"{ts}.json"
    out.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    latest = snapshot_dir / "latest.json"
    if latest.exists() or latest.is_symlink():
        latest.unlink()
    latest.symlink_to(out.name)
    return out


def load_snapshot(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def compare_snapshots(old: dict[str, Any], new: dict[str, Any]) -> list[dict[str, Any]]:
    old_entries = old.get("entries", {})
    new_entries = new.get("entries", {})
    keys = sorted(set(old_entries) | set(new_entries))
    rows: list[dict[str, Any]] = []
    for key in keys:
        o = old_entries.get(key, {})
        n = new_entries.get(key, {})
        label = n.get("label") or o.get("label") or key
        ob = o.get("bytes") if "bytes" in o else o.get("used_bytes")
        nb = n.get("bytes") if "bytes" in n else n.get("used_bytes")
        delta = delta_bytes(ob, nb)
        rows.append(
            {
                "key": key,
                "label": label,
                "before_bytes": ob,
                "after_bytes": nb,
                "delta_bytes": delta,
            }
        )
    rows.sort(key=lambda r: abs(r["delta_bytes"] or 0), reverse=True)
    return rows


def render_report(snapshot: dict[str, Any]) -> str:
    meta = snapshot["meta"]
    home = Path(meta.get("home", Path.home()))
    lines = [
        f"# 磁盘快照 · {meta['timestamp']}",
        "",
        f"> 项目 `{display_path(meta.get('project_dir', '.'), home)}` · 配置 `{meta.get('config', '')}`",
        "",
        "| 类别 | 路径 | 占用 |",
        "|------|------|------|",
    ]
    for _key, entry in snapshot["entries"].items():
        if entry.get("used_bytes") is not None:
            used = entry.get("used_bytes")
            avail = entry.get("avail_bytes")
            total = entry.get("total_bytes")
            size = f"已用 {format_bytes(used)} / 可用 {format_bytes(avail)} / 共 {format_bytes(total)}"
        else:
            size = format_bytes(entry.get("bytes"))
        path = display_path(entry.get("path", ""), home)
        label = entry.get("label", _key)
        lines.append(f"| {label} | `{path}` | {size} |")
    lines.append("")
    return "\n".join(lines)


def render_diff(old: dict[str, Any], new: dict[str, Any], rows: list[dict[str, Any]]) -> str:
    ots = old["meta"]["timestamp"]
    nts = new["meta"]["timestamp"]
    lines = [
        "# 磁盘变动对比",
        "",
        f"> 前：`{ots}`",
        f"> 后：`{nts}`",
        "",
        "| 类别 | 之前 | 之后 | 变动 |",
        "|------|------|------|------|",
    ]
    for row in rows:
        delta = row["delta_bytes"]
        if delta is None:
            change = "—"
        elif delta == 0:
            change = "±0"
        elif delta > 0:
            change = f"**+{format_bytes(delta)}** ↑"
        else:
            change = f"**{format_bytes(delta)}** ↓"
        lines.append(
            f"| {row['label']} | {format_bytes(row['before_bytes'])} | "
            f"{format_bytes(row['after_bytes'])} | {change} |"
        )
    significant = [r for r in rows if r["delta_bytes"] not in (None, 0)]
    lines.extend(["", "## 显著变动"])
    if not significant:
        lines.append("- 无显著变动")
    else:
        for row in significant[:10]:
            d = row["delta_bytes"]
            arrow = "增大" if d and d > 0 else "减小"
            lines.append(f"- **{row['label']}** {arrow} {format_bytes(abs(d or 0))}")
    lines.append("")
    return "\n".join(lines)


class ShortHelpFormatter(argparse.HelpFormatter):
    def __init__(self, prog: str) -> None:
        super().__init__(prog, max_help_position=32, width=100)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="采集结构化磁盘占用快照，并与历史对比。",
        formatter_class=ShortHelpFormatter,
    )
    parser.add_argument(
        "command",
        nargs="?",
        choices=["snapshot", "diff", "list", "report"],
        default="snapshot",
        help="[可选] snapshot · diff · list · report",
    )
    parser.add_argument("--home", default=os.path.expanduser("~"), help="[可选] HOME 目录")
    parser.add_argument("--project-dir", default=".", help="[可选] 相对路径基准目录")
    parser.add_argument("--config", default="", help="[可选] 路径配置文件")
    parser.add_argument(
        "--snapshot-dir",
        default=str(DEFAULT_SNAPSHOT_DIR),
        help="[可选] 快照目录（默认 .cursorGrowth/disk-snapshots/）",
    )
    parser.add_argument("--format", choices=["json", "meta", "report", "diff"], help="[可选] 输出格式")
    parser.add_argument("--before", help="[可选] diff 较早快照")
    parser.add_argument("--after", help="[可选] diff 较晚快照")
    return parser.parse_args(argv)


def resolve_snapshot_dir(raw: str, project_dir: Path) -> Path:
    p = Path(raw)
    if p.is_absolute():
        return p
    return (project_dir / p).resolve()


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    home = Path(args.home).expanduser().resolve()
    project_dir = Path(args.project_dir).expanduser().resolve()
    snapshot_dir = resolve_snapshot_dir(args.snapshot_dir, project_dir)
    config_path = find_config(args.config or None, project_dir)
    cmd = args.command
    fmt = args.format

    if cmd == "snapshot":
        data = collect(home, project_dir, config_path)
        out = write_snapshot(data, snapshot_dir)
        if fmt == "json":
            print(json.dumps(data, ensure_ascii=False, indent=2))
        elif fmt == "meta":
            print(json.dumps({"path": str(out), "timestamp": data["meta"]["timestamp"]}, ensure_ascii=False))
        elif fmt == "report":
            print(render_report(data))
        else:
            print(f"快照已写入: {out}")
            print(f"最新链接: {snapshot_dir / 'latest.json'}")
        return 0

    if cmd == "list":
        snaps = list_snapshots(snapshot_dir)
        payload = [{"file": p.name, "path": str(p)} for p in snaps]
        if fmt == "json":
            print(json.dumps(payload, ensure_ascii=False, indent=2))
        else:
            for item in payload:
                print(item["file"])
        return 0

    if cmd == "report":
        latest = snapshot_dir / "latest.json"
        if not latest.exists():
            print("尚无快照，请先运行: collect-disk.py snapshot", file=sys.stderr)
            return 1
        target = snapshot_dir / latest.readlink() if latest.is_symlink() else latest
        data = load_snapshot(target)
        print(render_report(data) if fmt != "json" else json.dumps(data, ensure_ascii=False, indent=2))
        return 0

    if cmd == "diff":
        snaps = list_snapshots(snapshot_dir)
        if args.before and args.after:
            old = load_snapshot(Path(args.before))
            new = load_snapshot(Path(args.after))
        elif len(snaps) >= 2:
            old = load_snapshot(snaps[-2])
            new = load_snapshot(snaps[-1])
        else:
            print("至少需要 2 份快照才能对比", file=sys.stderr)
            return 1
        rows = compare_snapshots(old, new)
        diff_md = render_diff(old, new, rows)
        diff_path = snapshot_dir / "diff-latest.md"
        diff_path.write_text(diff_md, encoding="utf-8")
        if fmt == "json":
            print(json.dumps(rows, ensure_ascii=False, indent=2))
        elif fmt == "diff":
            print(diff_md)
        else:
            print(diff_md)
            print(f"对比报告: {diff_path}")
        return 0

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
