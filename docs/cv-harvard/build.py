#!/usr/bin/env python3
"""Build CVs into PDF and Markdown. Requires Typst and Python 3 only.

Run it from a folder that has data/ and variants/. That folder can be anywhere,
so your personal data can live outside this repo.

Usage:
    python build.py                            every file in variants/
    python build.py base-en                    variants/base-en.yaml -> output/base-en.*
    python build.py applications/2026-11-acme  its variant.yaml -> same folder
"""

import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

GENERATOR = Path(__file__).resolve().parent
PROJECT = Path.cwd()
ENTRY = "cv.typ"
VARIANT = "variant.yaml"


def typst(workspace, *args):
    result = subprocess.run(
        ["typst", *args],
        cwd=workspace,
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
    folder = PROJECT / target
    if folder.is_dir():
        return folder / VARIANT, folder / folder.name
    return PROJECT / "variants" / f"{target}.yaml", PROJECT / "output" / target


def prepare_workspace(workspace, variant):
    """Typst only reads files inside its root, so put generator and data together."""
    shutil.copy(GENERATOR / ENTRY, workspace)
    shutil.copytree(GENERATOR / "template", workspace / "template")
    shutil.copytree(PROJECT / "data", workspace / "data")
    shutil.copy(variant, workspace / VARIANT)


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

    with tempfile.TemporaryDirectory() as temp:
        workspace = Path(temp)
        prepare_workspace(workspace, variant)
        inputs = ("--input", f"variant={VARIANT}")

        def query(label):
            expression = f"query(<{label}>).first().value"
            return json.loads(typst(workspace, "eval", expression, "--in", ENTRY, *inputs))

        typst(workspace, "compile", ENTRY, str(output.with_suffix(".pdf")), *inputs)
        output.with_suffix(".md").write_text(to_markdown(query("cv")), encoding="utf-8", newline="\n")
        pages = query("page-count")

    print(f"{target}: {output.relative_to(PROJECT).as_posix()}.pdf and .md ({pages} page(s))")
    if pages > 1:
        print(f"warning: {target} does not fit on one page", file=sys.stderr)


def main():
    if not shutil.which("typst"):
        sys.exit("Typst not found. Install it from https://github.com/typst/typst#installation")
    if not (PROJECT / "data").is_dir():
        sys.exit(f"No data/ folder in {PROJECT}. Run this from the folder that has data/ and variants/.")
    targets = sys.argv[1:] or sorted(path.stem for path in (PROJECT / "variants").glob("*.yaml"))
    for target in targets:
        build(target)


if __name__ == "__main__":
    main()
