"""Strip const from lines that use *Strings getters (post-L10n conversion)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ERR = ROOT / "tool" / "analyze_errors.txt"

# Maps file -> set of 1-based line numbers with const errors
file_lines: dict[Path, set[int]] = {}
pat = re.compile(r"- (lib\\.+?\.dart):(\d+):")

for line in ERR.read_text(encoding="utf-8", errors="replace").splitlines():
    m = pat.search(line)
    if not m:
        continue
    rel = m.group(1).replace("\\", "/")
    path = ROOT / rel
    file_lines.setdefault(path, set()).add(int(m.group(2)))

STRING_REF = re.compile(
    r"(AppStrings|NavigationStrings|HomeStrings|CartFlowStrings|ScheduledCartStrings|"
    r"PickupCartStrings|DineInCartStrings|VapeCartStrings|OrderFlowStrings|"
    r"ScheduledOrderFlowStrings|PickupOrderFlowStrings|DineInOrderFlowStrings|"
    r"ServicesBookingStrings|ServicesOrderFlowStrings|VapeOrderFlowStrings)\."
)


def fix_file(path: Path, lines_hit: set[int]) -> int:
    if not path.exists():
        return 0
    raw = path.read_text(encoding="utf-8")
    lines = raw.splitlines(keepends=True)
    changed = 0

    # Broad pass: remove const before widgets/lists that reference *Strings
    new_lines: list[str] = []
    for i, line in enumerate(lines, start=1):
        original = line
        if STRING_REF.search(line) or i in lines_hit:
            # const Text( -> Text(
            line = re.sub(r"\bconst\s+Text\(", "Text(", line)
            # const Foo( ... Strings
            if STRING_REF.search(line):
                line = re.sub(r"\bconst\s+", "", line, count=1)
            elif i in lines_hit and "const " in line:
                line = re.sub(r"\bconst\s+", "", line, count=1)
            # static const list with strings
            if "static const" in line and ("[" in line or STRING_REF.search(line)):
                line = line.replace("static const", "static final", 1)
            if line != original:
                changed += 1
        new_lines.append(line)

    # Second pass: for hit lines that are just list entries, remove const on previous lines with [
    for ln in sorted(lines_hit):
        idx = ln - 1
        if idx < 0 or idx >= len(new_lines):
            continue
        # Walk up to find const [
        for j in range(idx, max(-1, idx - 15), -1):
            if "const [" in new_lines[j] or re.search(r"\bconst\s+[A-Za-z_]+\(", new_lines[j]):
                before = new_lines[j]
                new_lines[j] = re.sub(r"\bconst\s+", "", new_lines[j], count=1)
                if "static const" in before:
                    new_lines[j] = before.replace("static const", "static final", 1)
                if new_lines[j] != before:
                    changed += 1
                break
            if "static const" in new_lines[j]:
                before = new_lines[j]
                new_lines[j] = new_lines[j].replace("static const", "static final", 1)
                if new_lines[j] != before:
                    changed += 1
                break

    path.write_text("".join(new_lines), encoding="utf-8")
    return changed


def main() -> None:
    total = 0
    for path, hits in sorted(file_lines.items()):
        n = fix_file(path, hits)
        print(f"{path.relative_to(ROOT)}: {n} edits ({len(hits)} error lines)")
        total += n
    print(f"total edits {total}")


if __name__ == "__main__":
    main()
