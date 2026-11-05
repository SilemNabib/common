#!/usr/bin/env python3
"""Build CV variants into PDF and Markdown. Requires Typst and Python 3 only.

Usage:
    python build.py                            every file in variants/
    python build.py example-en                 variants/example-en.yaml -> output/example-en.*
    python build.py applications/2026-11-acme  its variant.yaml -> same folder
"""

import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
ENTRY = "cv.typ"


def typst(*args):
    result = subprocess.run(
        ["typst", *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    if result.returncode != 0:
        sys.exit(result.stderr)
    if result.stderr:
        print(result.stderr, file=sys.stderr)
    return result.stdout


def locate(target):
    """Return the variant file and the output path (without extension)."""
    folder = ROOT / target
    if folder.is_dir():
        return folder / "variant.yaml", folder / folder.name
    return ROOT / "variants" / f"{target}.yaml", ROOT / "output" / target


def contact_item(item):
    text = f"[{item['text']}]({item['url']})" if item["url"] else item["text"]
    return f"{item['label']}: {text}" if item["label"] else text


def entry_lines(entry):
    title = f"[{entry['title']}]({entry['url']})" if entry["url"] else entry["title"]
    lines = [f"### {title}", ""]
    subtitle = f"*{entry['subtitle']}*" if entry["subtitle"] else None
    details = " | ".join(part for part in (subtitle, entry["date"]) if part)
    if details:
        lines += [details, ""]
    if entry["bullets"]:
        lines += [f"- {bullet}" for bullet in entry["bullets"]] + [""]
    return lines


def section_lines(section):
    lines = [f"## {section['title']}", ""]
    if section["kind"] == "profile":
        lines += [section["text"], ""]
    elif section["kind"] == "skills":
        for group in section["groups"]:
            lines += [f"**{group['label']}:** {', '.join(group['items'])}.", ""]
    elif section["kind"] == "links":
        for link in section["links"]:
            lines += [f"{link['label']}: [{link['url']}]({link['url']})", ""]
    else:
        for entry in section["entries"]:
            lines += entry_lines(entry)
    return lines


def to_markdown(cv):
    lines = [f"# {cv['name']}", "", " · ".join(map(contact_item, cv["contact"])), ""]
    for section in cv["sections"]:
        lines += section_lines(section)
    return "\n".join(lines).rstrip() + "\n"


def build(target):
    variant, output = locate(target)
    if not variant.is_file():
        sys.exit(f"Variant not found: {variant}")
    output.parent.mkdir(parents=True, exist_ok=True)
    inputs = ("--input", f"variant={variant.relative_to(ROOT).as_posix()}")

    def query(label):
        return json.loads(typst("eval", f"query(<{label}>).first().value", "--in", ENTRY, *inputs))

    typst("compile", ENTRY, str(output.with_suffix(".pdf")), *inputs)
    output.with_suffix(".md").write_text(to_markdown(query("cv")), encoding="utf-8", newline="\n")

    pages = query("page-count")
    print(f"{target}: {output.relative_to(ROOT).as_posix()}.pdf and .md ({pages} page(s))")
    if pages > 1:
        print(f"warning: {target} does not fit on one page", file=sys.stderr)


def main():
    if not shutil.which("typst"):
        sys.exit("Typst not found. Install it from https://github.com/typst/typst#installation")
    targets = sys.argv[1:] or sorted(path.stem for path in (ROOT / "variants").glob("*.yaml"))
    for target in targets:
        build(target)


if __name__ == "__main__":
    main()
