// Entry point. Use build.py, or compile one variant directly:
//   typst compile --input variant=variants/example-en.yaml cv.typ output/example-en.pdf

#import "template/resolve.typ": resolve
#import "template/harvard.typ": harvard

#let variant-path = sys.inputs.at("variant", default: "variants/example-en.yaml")

#let cv = resolve(yaml("/" + variant-path), (
  profile: yaml("data/profile.yaml"),
  experience: yaml("data/experience.yaml"),
  education: yaml("data/education.yaml"),
  projects: yaml("data/projects.yaml"),
  certifications: yaml("data/certifications.yaml"),
  skills: yaml("data/skills.yaml"),
))

#show: harvard.with(cv)

// Read by build.py to export Markdown and to warn when a CV exceeds one page.
#metadata(cv) <cv>
#context [#metadata(counter(page).final().first()) <page-count>]
