# CV Harvard template

A one-column, Harvard-style CV that you build from plain text. You keep all your content in one place and create a short file for each version you need, so one edit reaches every version.

The data in this folder is fictional. See `output/` for the result.

## Requirements

- [Typst](https://github.com/typst/typst#installation), to build the PDF
- Python 3, to run `build.py` (no extra packages)
- The Arial font. To use another font, change it in `template/harvard.typ`

## Build

```bash
python build.py
```

This creates a PDF and a Markdown file in `output/` for each file in `variants/`. To build only one version:

```bash
python build.py example-en
```

The script warns you if a CV doesn't fit on one page.

## Make it yours

1. Copy this folder somewhere private. Your CV contains personal data, so don't commit it to a public repo.
2. Replace the files in `data/` with your own content:

   | File | Content |
   |---|---|
   | `profile.yaml` | Name, contact details, links, and summaries |
   | `experience.yaml` | Jobs and their bullets |
   | `education.yaml` | Degrees |
   | `projects.yaml` | Projects |
   | `certifications.yaml` | Certifications |
   | `skills.yaml` | Skill groups |

3. Create a file in `variants/` for each version you need. It sets the language, the summary, the sections, and which entries to include, all in the order you list them. The example files show each option.

Text can be written as `{ en: ..., es: ... }`. You only need the languages you use, and the build stops with a clear error if a translation is missing.

To add a language, add its labels to `template/resolve.typ`.

## Tailored versions

To keep a CV for a specific application, create a folder with a `variant.yaml` inside and build it:

```bash
python build.py applications/2026-11-acme
```

The PDF and Markdown files are saved in that same folder.
