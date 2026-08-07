#let brand-color = (
  background: rgb("#f6efe1"),
  blackish: rgb("#0a0a0a"),
  blush: rgb("#eae0d8"),
  carmine: rgb("#a8283a"),
  carmine-light: rgb("#d25668"),
  code-bg-dark: rgb("#1d1512"),
  code-bg-light: rgb("#f0e6dc"),
  cream: rgb("#f6efe1"),
  danger: rgb("#a8283a"),
  espresso: rgb("#1e1512"),
  foreground: rgb("#1e1512"),
  info: rgb("#380c12"),
  ochre: rgb("#a8721c"),
  ochre-light: rgb("#f0bc5c"),
  oxblood: rgb("#380c12"),
  oxblood-light: rgb("#b0293a"),
  primary: rgb("#380c12"),
  sable: rgb("#241813"),
  secondary: rgb("#6b5b52"),
  shell: rgb("#f2e8de"),
  success: rgb("#146860"),
  taupe: rgb("#6b5b52"),
  taupe-light: rgb("#c9baae"),
  teal: rgb("#146860"),
  teal-light: rgb("#5fcbb8"),
  tertiary: rgb("#eae0d8"),
  warning: rgb("#a8721c")
)
#let brand-color-background = (
  background: color.mix((brand-color.background, 15%), (brand-color.background, 85%)),
  blackish: color.mix((brand-color.blackish, 15%), (brand-color.background, 85%)),
  blush: color.mix((brand-color.blush, 15%), (brand-color.background, 85%)),
  carmine: color.mix((brand-color.carmine, 15%), (brand-color.background, 85%)),
  carmine-light: color.mix((brand-color.carmine-light, 15%), (brand-color.background, 85%)),
  code-bg-dark: color.mix((brand-color.code-bg-dark, 15%), (brand-color.background, 85%)),
  code-bg-light: color.mix((brand-color.code-bg-light, 15%), (brand-color.background, 85%)),
  cream: color.mix((brand-color.cream, 15%), (brand-color.background, 85%)),
  danger: color.mix((brand-color.danger, 15%), (brand-color.background, 85%)),
  espresso: color.mix((brand-color.espresso, 15%), (brand-color.background, 85%)),
  foreground: color.mix((brand-color.foreground, 15%), (brand-color.background, 85%)),
  info: color.mix((brand-color.info, 15%), (brand-color.background, 85%)),
  ochre: color.mix((brand-color.ochre, 15%), (brand-color.background, 85%)),
  ochre-light: color.mix((brand-color.ochre-light, 15%), (brand-color.background, 85%)),
  oxblood: color.mix((brand-color.oxblood, 15%), (brand-color.background, 85%)),
  oxblood-light: color.mix((brand-color.oxblood-light, 15%), (brand-color.background, 85%)),
  primary: color.mix((brand-color.primary, 15%), (brand-color.background, 85%)),
  sable: color.mix((brand-color.sable, 15%), (brand-color.background, 85%)),
  secondary: color.mix((brand-color.secondary, 15%), (brand-color.background, 85%)),
  shell: color.mix((brand-color.shell, 15%), (brand-color.background, 85%)),
  success: color.mix((brand-color.success, 15%), (brand-color.background, 85%)),
  taupe: color.mix((brand-color.taupe, 15%), (brand-color.background, 85%)),
  taupe-light: color.mix((brand-color.taupe-light, 15%), (brand-color.background, 85%)),
  teal: color.mix((brand-color.teal, 15%), (brand-color.background, 85%)),
  teal-light: color.mix((brand-color.teal-light, 15%), (brand-color.background, 85%)),
  tertiary: color.mix((brand-color.tertiary, 15%), (brand-color.background, 85%)),
  warning: color.mix((brand-color.warning, 15%), (brand-color.background, 85%))
)
#set page(fill: brand-color.background)
#set text(fill: brand-color.foreground)
#set table.hline(stroke: (paint: brand-color.foreground))
#set line(stroke: (paint: brand-color.foreground))
#let brand-logo = (:)
#set text()
#show heading: set text(font: ("Valley Sans",), )
#show raw.where(block: false): set text(fill: rgb("#a8283a"), )
#show raw.where(block: false): content => highlight(fill: rgb("#f0e6dc"), content)
#show raw.where(block: true): set text()
#show raw.where(block: true): set block(fill: rgb("#f0e6dc"))
#show link: set text(fill: rgb("#a8283a"), )

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => article(
  title: [Example Vignette],
  font: ("Domine",),
  heading-family: ("Valley Sans",),
  heading-color: rgb("#1e1512"),
  codefont: ("CommitMono",),
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)
