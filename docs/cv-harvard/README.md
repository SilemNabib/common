# CV generator (Harvard format)

Turns plain-text files into a one-column, Harvard-style CV, as a PDF and as Markdown.

Keeping a separate Word file for each job and language gets tiring: every change has to be repeated in every copy. Here, all your content lives in one place, and each version of your CV is a short file that picks what to include. Edit a bullet once and every version that uses it updates, in any language.

The data in this folder is fictional. See `output/` for the result.

## How it works

The generator and your content are kept apart, so the generator can be public while your personal data stays private:

```text
Generator (this folder)         Your content (any private folder)
├── build.py                    ├── data/            everything you could include
├── cv.typ                      ├── variants/        one short file per CV version
└── template/                   ├── applications/    optional, one folder per job
                                └── output/          generated PDF and Markdown
```

You run `build.py` from your content folder, and the results are saved there.

## Requirements

- [Typst](https://github.com/typst/typst#installation), to build the PDF. On Windows: `winget install --id Typst.Typst`
- Python 3, with no extra packages
- The Arial font. To use another font, change it in `template/harvard.typ`

## Try it

From this folder:

```bash
python build.py
```

This builds the fictional examples into `output/`.

## Use your own content

1. Create a folder outside any public repo, and copy `data/` and `variants/` into it.
2. Replace the example content with your own, as described below.
3. From that folder, run the generator:

   ```bash
   python path/to/cv-harvard/build.py
   ```

| Command | What it builds | Where it saves |
|---|---|---|
| `build.py` | Every file in `variants/` | `output/` |
| `build.py base-en` | `variants/base-en.yaml` | `output/` |
| `build.py applications/2026-11-acme` | `variant.yaml` in that folder | That same folder |

The script warns you if a CV doesn't fit on one page.

## Write your content

These six files must exist in `data/`. Use `[]` for a file with nothing in it yet.

| File | Content |
|---|---|
| `profile.yaml` | Name, contact details, links, and one summary per focus |
| `experience.yaml` | Jobs and their bullets |
| `education.yaml` | Degrees |
| `projects.yaml` | Projects |
| `certifications.yaml` | Certifications |
| `skills.yaml` | Skill groups |

Each entry has an `id`, which variants use to pick it. Bullets have one too, and their `tags` are notes to help you choose; they are never printed.

```yaml
- id: acme-developer
  title: Acme Software (Springfield)
  subtitle: { en: Junior Backend Developer, es: Desarrollador Backend Junior }
  start: "2025-03"
  end: null # null means the job is current
  bullets:
    - id: rest-api
      tags: [backend, api]
      text:
        en: Built REST API endpoints used by the internal billing tool.
        es: Desarrollé endpoints de API REST usados por la herramienta interna de facturación.
```

Entries also accept `url`, and a single `date` in place of `start` and `end`. Text can be plain, or written as `{ en: ..., es: ... }` if it changes by language. You only need the languages you use.

## Choose what goes in each version

A variant sets the language, the summary, the sections, and the entries, all in the order you list them:

```yaml
lang: en
profile: backend
sections: [profile, experience, projects, education, skills, links]

experience:
  - acme-developer # no bullet list means every bullet
  - id: university-support
    bullets: [help-desk] # or pick the bullets you want

projects: [task-api]
education: [university, high-school]

skills:
  - id: technical
    items: [TypeScript, NestJS, PostgreSQL] # or pick the skills you want
  - soft
```

Every section in `sections` except `profile` and `links` needs its own list.

## Tailor a CV for a job

Create a folder such as `applications/2026-11-acme/` in your content folder, add a `variant.yaml` with the same format, and build it with the command above. The PDF and Markdown are saved next to the variant, so you can see what you sent to each company.

## Customize

- **Layout, fonts, and spacing:** edit `template/harvard.typ`.
- **Section titles, or a new language:** edit the labels in `template/resolve.typ`.

## Troubleshooting

| Message | What to do |
|---|---|
| `No data/ folder in ...` | Run the command from your content folder |
| `Variant not found` | Check the name, and leave out `.yaml` and `variants/` |
| `Missing 'es' translation` | Add that language to the text shown in the message |
| `Unknown experience id` | Make sure the variant uses an `id` that exists in `data/` |
| `does not fit on one page` | Remove bullets or entries from the variant |
| `unknown font family` | Install Arial, or change the font in `template/harvard.typ` |
