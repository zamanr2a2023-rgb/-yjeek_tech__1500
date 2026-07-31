"""Extract and convert String constant classes to L10n.tr getters."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib"
OUT = Path(__file__).resolve().parents[1] / "tool" / "extracted_strings.json"

CONST_RE = re.compile(
    r"static const String (\w+)\s*=\s*((?:'[^'\\]*(?:\\.[^'\\]*)*'|\"[^\"\\]*(?:\\.[^\"\\]*)*\"))\s*;",
    re.MULTILINE,
)
# Multi-line const with adjacent string concat
CONST_MULTI_RE = re.compile(
    r"static const String (\w+)\s*=\s*((?:'[^'\\]*(?:\\.[^'\\]*)*'\s*)+);",
    re.MULTILINE,
)


def unquote(raw: str) -> str:
    parts = re.findall(r"'([^'\\]*(?:\\.[^'\\]*)*)'|\"([^\"\\]*(?:\\.[^\"\\]*)*)\"", raw)
    chunks: list[str] = []
    for a, b in parts:
        s = a if a or a == "" else b
        s = bytes(s, "utf-8").decode("unicode_escape") if "\\" in s else s
        # simpler unescape for common cases
        s = (a if a != "" or (a == "" and not b) else b)
        s = s.replace("\\'", "'").replace('\\"', '"').replace("\\n", "\n")
        chunks.append(s)
    if not chunks:
        # fallback
        return raw.strip().strip("'\"")
    return "".join(chunks)


def collect() -> dict[str, str]:
    """english_value -> first key name"""
    values: dict[str, str] = {}
    targets = list(ROOT.rglob("*strings*.dart")) + list(ROOT.rglob("*_data.dart"))
    for path in targets:
        text = path.read_text(encoding="utf-8")
        if "Strings" not in text:
            continue
        for m in CONST_MULTI_RE.finditer(text):
            name, raw = m.group(1), m.group(2)
            try:
                val = unquote(raw)
            except Exception:
                continue
            values.setdefault(val, name)
    return values


def dart_escape(s: str) -> str:
    return (
        s.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\n", "\\n")
        .replace("\r", "")
    )


def convert_file(path: Path) -> int:
    text = path.read_text(encoding="utf-8")
    if "Strings" not in text:
        return 0

    count = 0

    def repl(m: re.Match[str]) -> str:
        nonlocal count
        name, raw = m.group(1), m.group(2)
        val = unquote(raw)
        count += 1
        return f"static String get {name} => L10n.tr('{dart_escape(val)}');"

    new_text, n = CONST_MULTI_RE.subn(repl, text)
    if n == 0:
        return 0

    if "package:yjeek_app/l10n/l10n.dart" not in new_text:
        # insert import after existing imports
        lines = new_text.splitlines(keepends=True)
        insert_at = 0
        for i, line in enumerate(lines):
            if line.startswith("import "):
                insert_at = i + 1
            elif insert_at and not line.startswith("import "):
                break
        lines.insert(insert_at, "import 'package:yjeek_app/l10n/l10n.dart';\n")
        new_text = "".join(lines)

    path.write_text(new_text, encoding="utf-8")
    return n


def main() -> None:
    values = collect()
    OUT.write_text(
        json.dumps(values, ensure_ascii=False, indent=2, sort_keys=True),
        encoding="utf-8",
    )
    print(f"extracted {len(values)} unique strings -> {OUT}")

    converted = 0
    targets = list(ROOT.rglob("*strings*.dart")) + list(ROOT.rglob("*_data.dart"))
    for path in targets:
        text = path.read_text(encoding="utf-8")
        if "abstract final class" in text and "Strings" in text:
            n = convert_file(path)
            if n:
                print(f"converted {n}: {path.relative_to(ROOT)}")
                converted += n
    print(f"total getters: {converted}")


if __name__ == "__main__":
    main()
