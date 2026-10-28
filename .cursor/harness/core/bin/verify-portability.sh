#!/usr/bin/env bash
# 可移植性静态门禁 —— 让「支持 Linux · macOS · Git Bash」是可被守护的断言
#
# 检查发布脚本中的：
#   1. GNU-only 构造（BSD/macOS 缺失）：sed -i 无后缀 · find -printf · stat -c ·
#      sort -h · du --max-depth · date -d / -Iseconds · grep -P · xargs -r · tac
#   2. 非 POSIX 正则：grep/sed 模式里的 `\s`
#   3. `readlink -f` 无同层回退
#   4. 硬编码 `python3` 调用（Git Bash 可能只有 `python`）→ 应经 $PYTHON_BIN / sc_python
#   5. shebang 必须 `#!/usr/bin/env bash`
#   6. 勿复用 Bash 内置数组名（BASH_CMDS · FUNCNAME · GROUPS 等）
#   7. 勿用 xargs -I{} + bash -c … {}（多词 command 被拆碎）
#
# 自检脚本本身把模式当**数据**用，故排除；`lib/platform.sh` 是解析器，允许 `command -v python3`。
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"
# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-portability"

echo "=== verify-portability ==="

vc_py "$ROOT" "$CUR" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
cur = Path(sys.argv[2])

# 检查器把模式当数据用，排除自身
SELF = {"verify-portability.sh", "verify-super-cursor.sh"}

RESERVED_BASH_NAMES = (
    "BASH_CMDS",
    "BASH_ARGV",
    "BASH_ARGC",
    "BASH_ALIASES",
    "FUNCNAME",
    "GROUPS",
    "PIPESTATUS",
    "DIRSTACK",
)
RESERVED_BASH_RE = re.compile(
    r"(?<![.\w-])(?:local\s+)?(?:"
    + "|".join(RESERVED_BASH_NAMES)
    + r")\s*\+?="
)
XARGS_I_BASH_C_RE = re.compile(r"xargs\b.*-I\s*\{\}.*bash\s+-c.*\{\}")
MAPFILE_RE = re.compile(r"\bmapfile\b")
PROC_SUB_RE = re.compile(r"<\s*<\(")

files = []
files += sorted(p for p in cur.rglob("*.sh") if p.name not in SELF)
installer = root / "install-super-cursor.sh"
if installer.is_file():
    files.append(installer)

GNU_ONLY = [
    (r"(?<![.\w-])sed\b[^|]*\s-i(?![.\w])", "sed -i without backup suffix (BSD needs -i '')"),
    (r"find\b[^|]*-printf\b", "find -printf (GNU only)"),
    (r"stat\s+(-c|--format)\b", "stat -c/--format (GNU only)"),
    (r"sort\b[^|]*\s-h\b", "sort -h (GNU only)"),
    (r"du\b[^|]*--max-depth\b", "du --max-depth (BSD uses -d)"),
    (r"date\s+(-d\s|--date|-Iseconds)", "date -d/--date/-Iseconds (GNU only)"),
    (r"grep\b[^|]*\s-P\b", "grep -P (GNU only)"),
    (r"xargs\b[^|]*\s-r\b", "xargs -r (GNU only)"),
    (r"(?<![.\w-])tac\s", "tac (GNU only)"),
]
NON_POSIX_RE = re.compile(r"(grep\s+(-\w+\s+)*'[^']*\\s|sed\s+(-\w+\s+)*'[^']*\\s)")
READLINK_RE = re.compile(r"readlink\s+-f\b")
LN_S_RE = re.compile(r"(^\s*|[;&|(]\s*|\bthen\s+)ln\s+-s")
PYTHON3_RE = re.compile(r"(^|[|(]\s*|\$\(\s*|\beval\s+\"\$\(\s*)python3\s")

fails = []
for path in files:
    rel = path.relative_to(root).as_posix()
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()

    if not lines or not lines[0].startswith("#!/usr/bin/env bash"):
        fails.append(f"{rel}:1 shebang must be '#!/usr/bin/env bash'")

    # Python 块会打印中文 → Windows 默认 cp1252 stdout 直接 UnicodeEncodeError。
    # 要求 source platform/verify-common（其中 export PYTHONIOENCODING/UTF8），或本文件自行导出。
    if "<<'PY'" in text and not re.search(r"(platform|verify-common)\.sh", text) and "PYTHONIOENCODING" not in text:
        fails.append(
            f"{rel}: python heredoc without UTF-8 stdio guard "
            "(source lib/platform.sh or export PYTHONIOENCODING=utf-8)"
        )

    # bash 3.2（macOS 系统 bash）+ set -u：空数组展开会 unbound variable 中止（bash 4.4+ 才算空）。
    # 只针对「由 \"$@\" 填充、可能为空」的数组，避免误报字面量数组。
    splat_arrays = set(
        re.findall(r"^\s*(?:local\s+(?:-[a-zA-Z]+\s+)*)?([A-Za-z_][A-Za-z0-9_]*)=\(\"\$@\"\)", text, re.M)
    )

    for i, line in enumerate(lines, 1):
        stripped = line.lstrip()
        if stripped.startswith("#"):
            continue
        # 显式豁免：只用于「本就是平台探测」的行，须在同一行写理由
        if "portability-allow" in line:
            continue
        # 去掉行尾注释里可能出现的示例（保守：只在 '#' 前是空白时截断）
        code = re.split(r"\s#\s", line)[0]
        # Windows 路径分隔符：relative_to/relpath 的结果必须归一后才能与字面量比较
        if re.search(r"(relative_to\(|os\.path\.relpath\()", code) and not re.search(
            r"as_posix\(\)|replace\(os\.sep", line
        ):
            fails.append(f"{rel}:{i} relative_to/relpath without .as_posix() (Windows returns backslashes)")

        for pat, why in GNU_ONLY:
            if re.search(pat, code):
                fails.append(f"{rel}:{i} {why} :: {stripped[:80]}")
        if NON_POSIX_RE.search(code):
            fails.append(f"{rel}:{i} non-POSIX \\s in grep/sed pattern")
        if READLINK_RE.search(code) and "||" not in code:
            fails.append(f"{rel}:{i} readlink -f without same-line fallback")
        if LN_S_RE.search(code) and not re.search(r"2>/dev/null|\|\||if\s+ln\b", line):
            fails.append(f"{rel}:{i} bare 'ln -s' without fallback (Windows/Git Bash may lack symlink rights)")
        # bash 3.2 / C locale：`$VAR` 紧跟多字节字符时字节会被并入变量名 →
        # `PROFILE）: unbound variable`，set -u 下直接中止（macOS 与 Git Bash 都中过）。
        for _m in re.finditer(r"\$[A-Za-z_][A-Za-z0-9_]*(?=[^\x00-\x7F])", line):
            fails.append(
                f"{rel}:{i} '{_m.group(0)}' is immediately followed by a non-ASCII char; "
                f"write '${{{_m.group(0)[1:]}}}' (bash 3.2 folds those bytes into the name)"
            )
        for _name in splat_arrays:
            if f'"${{{_name}[@]}}"' in line and f"{_name}[@]+" not in line:
                fails.append(
                    f"{rel}:{i} '${{{_name}[@]}}' may be empty: bash 3.2 + set -u aborts "
                    f'(use ${{{_name}[@]}}+\"${{{_name}[@]}}\")'
                )
        if PYTHON3_RE.search(code):
            fails.append(f"{rel}:{i} hardcoded python3 call (use $PYTHON_BIN / sc_python)")
        if RESERVED_BASH_RE.search(code):
            fails.append(
                f"{rel}:{i} reserved bash variable/array name (e.g. BASH_CMDS); "
                f"use a project prefix like MANIFEST_BASH_CMDS"
            )
        if XARGS_I_BASH_C_RE.search(code):
            fails.append(
                f"{rel}:{i} xargs -I{{}} with bash -c … {{}} splits multi-word commands; "
                f"use xargs -0 -n 1 (or portability-allow: xargs-I)"
            )
        if MAPFILE_RE.search(code):
            fails.append(f"{rel}:{i} mapfile (bash 4+; macOS system bash is 3.2)")
        # 门禁脚本在 Windows Git Bash 上常因 process substitution 失败；优先 mktemp 重定向
        if PROC_SUB_RE.search(code) and rel.endswith("bin/cursor-coherence.sh"):
            fails.append(
                f"{rel}:{i} process substitution in cursor-coherence "
                "(use mktemp + file redirect; see docs/platforms.md)"
            )

# --- packaged rules SSOT regression ---
coherence = cur / "bin" / "cursor-coherence.sh"
if coherence.is_file():
    ct = coherence.read_text(encoding="utf-8", errors="replace")
    if "sc_find_packaged_rules_mdc" not in ct:
        fails.append("cursor-coherence.sh must use sc_find_packaged_rules_mdc (platform SSOT)")
platform_sh = cur / "lib" / "platform.sh"
if platform_sh.is_file():
    pt = platform_sh.read_text(encoding="utf-8", errors="replace")
    if "sc_find_packaged_rules_mdc" not in pt:
        fails.append("lib/platform.sh missing sc_find_packaged_rules_mdc")
    if "rules/local" not in pt or "-prune" not in pt:
        fails.append("sc_find_packaged_rules_mdc must prune rules/local from packaged gates")
else:
    fails.append("lib/platform.sh missing (packaged rules SSOT)")

# --- linter self-test (must fail on deliberate bad samples) ---
if not RESERVED_BASH_RE.search("BASH_CMDS+=('x')"):
    fails.append("selftest: RESERVED_BASH_RE did not match BASH_CMDS+=")
_bad_xargs = "printf '%s\\0' \"$@\" | xargs -0 -P 4 -I{} bash -c 'run_one \"$1\"' _ {}"
if not XARGS_I_BASH_C_RE.search(_bad_xargs):
    fails.append("selftest: XARGS_I_BASH_C_RE did not match fragile parallel idiom")

# --- 行尾策略：Windows autocrlf=true 会把 *.sh 变 CRLF → 脚本秒退 ---
if (root / "install-super-cursor.sh").is_file():
    ga = root / ".gitattributes"
    if not ga.is_file():
        fails.append(
            ".gitattributes missing — Git for Windows (autocrlf=true) checks out *.sh as CRLF, "
            "which breaks the shebang; declare 'eol=lf'"
        )
    else:
        gates = ga.read_text(encoding="utf-8", errors="replace")
        if not re.search(r"^\*\.sh\s+text\s+eol=lf", gates, re.M) and not re.search(
            r"^\*\s+text=auto\s+eol=lf", gates, re.M
        ):
            fails.append(".gitattributes must force LF for shell scripts (eol=lf)")

# --- 技能平台作用域：文档声明 ⇔ 代码实际 ---
platforms = cur / "docs/platforms.md"
if not platforms.is_file():
    fails.append("docs/platforms.md missing (platform scope undocumented)")
else:
    pt = platforms.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"^## 技能平台作用域\n(.*?)(?=^## )", pt, re.S | re.M)
    section = m.group(1) if m else ""
    if not section:
        fails.append("docs/platforms.md: missing '## 技能平台作用域' section")
    else:
        linux_only = set()
        for sh in (cur / "skills").glob("*/scripts/*.sh"):
            if "require_linux" in sh.read_text(encoding="utf-8", errors="replace"):
                linux_only.add(sh.parent.parent.name)
        for sk in sorted(linux_only):
            if not re.search(r"\*\*" + re.escape(sk) + r"\*\*", section):
                fails.append(
                    f"docs/platforms.md: skill '{sk}' enforces require_linux but is not documented as Linux-only"
                )
        for row in re.finditer(r"^\|\s*\*\*([a-z0-9-]+)\*\*\s*\|([^|]*)\|", section, re.M):
            sk, scope = row.group(1), row.group(2)
            if "仅 Linux" in scope and sk not in linux_only:
                fails.append(
                    f"docs/platforms.md: '{sk}' declared Linux-only but no require_linux in its scripts"
                )

if fails:
    for f in fails:
        print("FAIL portability:", f)
    sys.exit(1)
print(f"OK  portability scan clean ({len(files)} scripts) + platform scope consistent")
PY

vc_summary "verify-portability passed."
