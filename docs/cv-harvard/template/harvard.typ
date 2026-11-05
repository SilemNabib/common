// Harvard-style CV layout: one column, plain headings, dates aligned right.
// To adapt the look, change the settings in `harvard` at the end of this file.

#let link-blue = rgb("#0000EE")

#let web-link(url, body) = link(url, underline(text(fill: link-blue, body)))

#let short-url(url) = url.replace(regex("^https?://(www\.)?"), "")

#let contact-line(item) = {
  if item.label != none { item.label + ": " }
  if item.url != none { web-link(item.url, item.text) } else { item.text }
}

#let cv-header(cv) = align(center, {
  text(size: 20pt, weight: "bold", cv.name)
  v(0.5em, weak: true)
  cv.contact.map(contact-line).join(linebreak())
})

#let entry-heading(entry) = {
  set par(justify: false)
  strong(entry.title)
  if entry.url != none {
    [ · ]
    web-link(entry.url, short-url(entry.url))
  }
  if entry.subtitle != none {
    linebreak()
    emph(entry.subtitle)
  }
  // Entries without bullets keep the date on its own line: PDF readers split a
  // far-right date from short entries, which can confuse applicant tracking systems.
  if entry.date != none {
    if entry.bullets.len() > 0 { h(1fr) } else { linebreak() }
    emph(entry.date)
  }
}

// The explicit width keeps the list from shrinking to fit its content, which
// would leave justified lines short of the right margin.
#let entry-block(entry) = block(width: 100%, breakable: false, below: 0.9em, {
  entry-heading(entry)
  if entry.bullets.len() > 0 { list(..entry.bullets) }
})

#let skill-group(group) = par(justify: false, {
  strong(group.label + ":")
  [ ]
  group.at("items").join(", ") + "."
})

#let link-line(item) = par(justify: false, {
  item.label + ": "
  web-link(item.url, item.url)
})

#let cv-section(section) = {
  let title = heading(level: 1, upper(section.title))
  if section.kind == "profile" { align(center, title) } else { title }

  if section.kind == "profile" {
    par(section.text)
  } else if section.kind == "skills" {
    section.groups.map(skill-group).join()
  } else if section.kind == "links" {
    section.links.map(link-line).join()
  } else {
    section.entries.map(entry-block).join()
  }
}

#let harvard(cv, body) = {
  set document(title: cv.name + " - CV", author: cv.name)
  set page(paper: "us-letter", margin: (x: 0.5in, y: 0.5in))
  set text(font: "Arial", size: 10pt, lang: cv.lang, hyphenate: false)
  set par(justify: true, leading: 0.43em, spacing: 0.5em)
  set list(marker: [•], indent: 0.03in, body-indent: 0.2in, spacing: 0.43em)
  set block(spacing: 0.5em)
  show heading: it => block(above: 1.1em, below: 0.55em, text(size: 11pt, weight: "bold", it.body))

  cv-header(cv)
  cv.sections.map(cv-section).join()
  body
}
