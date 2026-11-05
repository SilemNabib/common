// Turns the YAML data and a variant into one plain document: a single language,
// only the selected entries, in the selected order. The PDF layout (harvard.typ)
// and the Markdown export (build.py) both render this result.

#let labels = (
  en: (
    profile: "Professional Profile",
    experience: "Work Experience",
    education: "Education",
    projects: "Projects",
    certifications: "Certifications",
    skills: "Skills",
    links: "Highlights / Links / Portfolio",
    present: "Present",
    phone: "Phone",
    email: "Email",
  ),
  es: (
    profile: "Perfil profesional",
    experience: "Experiencia laboral",
    education: "Educación",
    projects: "Proyectos",
    certifications: "Certificaciones",
    skills: "Habilidades",
    links: "Destacados / Enlaces / Portafolio",
    present: "Presente",
    phone: "Teléfono",
    email: "Correo",
  ),
)

// Accepts plain text or { en: ..., es: ... } and returns the text for `lang`.
#let localize(value, lang) = {
  if type(value) != dictionary { return value }
  assert(lang in value, message: "Missing '" + lang + "' translation in: " + repr(value))
  value.at(lang)
}

#let find-by-id(items, id, kind) = {
  let found = items.filter(item => item.id == id)
  assert(found.len() == 1, message: "Unknown " + kind + " id: " + id)
  found.first()
}

// A variant picks an entry as "some-id" or as { id: some-id, bullets: [...] }.
#let choice-id(choice) = if type(choice) == dictionary { choice.id } else { choice }

// "2025-02" becomes "02.2025"; "2027" stays "2027".
#let format-date(date) = str(date).split("-").rev().join(".")

#let entry-date(entry, lang) = {
  if "date" in entry { return format-date(entry.date) }
  if "start" not in entry { return none }
  let end = entry.at("end", default: none)
  let end-text = if end == none { labels.at(lang).present } else { format-date(end) }
  format-date(entry.start) + " – " + end-text
}

#let resolve-entry(choice, items, kind, lang) = {
  let entry = find-by-id(items, choice-id(choice), kind)
  let all-bullets = entry.at("bullets", default: ())
  let bullets = if type(choice) == dictionary and "bullets" in choice {
    choice.bullets.map(id => find-by-id(all-bullets, id, "bullet"))
  } else {
    all-bullets
  }
  (
    title: localize(entry.title, lang),
    subtitle: localize(entry.at("subtitle", default: none), lang),
    date: entry-date(entry, lang),
    url: entry.at("url", default: none),
    bullets: bullets.map(bullet => localize(bullet.text, lang)),
  )
}

// A skill is plain text, or { id: ..., label: { en: ..., es: ... } } when it
// needs translating. A variant selects skills by that text or id.
#let skill-id(item) = if type(item) == dictionary { item.id } else { item }
#let skill-label(item, lang) = if type(item) == dictionary { localize(item.label, lang) } else { item }

#let resolve-skill-group(choice, groups, lang) = {
  let group = find-by-id(groups, choice-id(choice), "skill group")
  let available = group.at("items")
  let items = if type(choice) == dictionary and "items" in choice {
    choice.at("items").map(wanted => {
      let found = available.filter(item => skill-id(item) == wanted)
      assert(found.len() == 1, message: "Unknown skill: " + wanted)
      found.first()
    })
  } else {
    available
  }
  (
    label: localize(group.label, lang),
    items: items.map(item => skill-label(item, lang)),
  )
}

#let resolve(variant, data) = {
  let lang = variant.lang
  assert(lang in labels, message: "Unsupported language: " + lang)
  let strings = labels.at(lang)
  let profile = data.profile

  let resolve-section(kind) = {
    let content = if kind == "profile" {
      (text: localize(profile.summaries.at(variant.profile), lang))
    } else if kind == "skills" {
      (groups: variant.skills.map(choice => resolve-skill-group(choice, data.skills, lang)))
    } else if kind == "links" {
      (links: profile.links)
    } else {
      (entries: variant.at(kind).map(choice => resolve-entry(choice, data.at(kind), kind, lang)))
    }
    (kind: kind, title: strings.at(kind)) + content
  }

  let contact = (
    (label: none, text: localize(profile.location, lang), url: none),
    (label: strings.phone, text: profile.phone, url: none),
    (label: strings.email, text: profile.email, url: "mailto:" + profile.email),
    ..profile.contact_links.map(item => (label: none, text: item.label, url: item.url)),
  )

  (
    lang: lang,
    name: profile.name,
    contact: contact,
    sections: variant.sections.map(resolve-section),
  )
}
