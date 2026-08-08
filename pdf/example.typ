// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}


// syntax highlighting functions from skylighting:
/* Function definitions for syntax highlighting generated by skylighting: */
#let EndLine() = raw("\n")
#let Skylighting(fill: none, number: false, start: 1, sourcelines) = {
   let blocks = []
   let lnum = start - 1
   let bgcolor = rgb("#F0E6DC")
   for ln in sourcelines {
     if number {
       lnum = lnum + 1
       blocks = blocks + box(width: if start + sourcelines.len() > 999 { 30pt } else { 24pt }, text(fill: rgb("#aaaaaa"), [ #lnum ]))
     }
     blocks = blocks + ln + EndLine()
   }
   block(fill: bgcolor, width: 100%, inset: 8pt, radius: 2pt, blocks)
}
#let AlertTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let AnnotationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let AttributeTok(s) = text(fill: rgb("#657422"),raw(s))
#let BaseNTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let BuiltInTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let CharTok(s) = text(fill: rgb("#20794d"),raw(s))
#let CommentTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let CommentVarTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ConstantTok(s) = text(fill: rgb("#8f5902"),raw(s))
#let ControlFlowTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let DataTypeTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DecValTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DocumentationTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ErrorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let ExtensionTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let FloatTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let FunctionTok(s) = text(fill: rgb("#4758ab"),raw(s))
#let ImportTok(s) = text(fill: rgb("#00769e"),raw(s))
#let InformationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let KeywordTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let NormalTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let OperatorTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let OtherTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let PreprocessorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let RegionMarkerTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let SpecialCharTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let SpecialStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let StringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let VariableTok(s) = text(fill: rgb("#111111"),raw(s))
#let VerbatimStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let WarningTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))



#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
   }

  let has-title-block = title != none or (authors != none and authors != ()) or date != none or abstract != none
  if has-title-block {
    place(
      top,
      float: true,
      scope: "parent",
      clearance: 4mm,
      block(below: 1em, width: 100%)[

        #if title != none {
          align(center, block(inset: 2em)[
            #set par(leading: heading-line-height) if heading-line-height != none
            #set text(font: heading-family) if heading-family != none
            #set text(weight: heading-weight)
            #set text(style: heading-style) if heading-style != "normal"
            #set text(fill: heading-color) if heading-color != black

            #text(size: title-size)[#title #if thanks != none {
              footnote(thanks, numbering: "*")
              counter(footnote).update(n => n - 1)
            }]
            #(if subtitle != none {
              parbreak()
              text(size: subtitle-size)[#subtitle]
            })
          ])
        }

        #if authors != none and authors != () {
          let count = authors.len()
          let ncols = calc.min(count, 3)
          grid(
            columns: (1fr,) * ncols,
            row-gutter: 1.5em,
            ..authors.map(author =>
                align(center)[
                  #author.name \
                  #author.affiliation \
                  #author.email
                ]
            )
          )
        }

        #if date != none {
          align(center)[#block(inset: 1em)[
            #date
          ]]
        }

        #if abstract != none {
          block(inset: 2em)[
          #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
          ]
        }
      ]
    )
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc
}

#set table(
  inset: 6pt,
  stroke: none
)
#import "@preview/fontawesome:0.5.0": *
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
  font: ("Alegreya",),
  heading-family: ("Valley Sans",),
  heading-color: rgb("#1e1512"),
  codefont: ("CommitMono",),
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)

= Typography
<typography>
== H3
<h3>
=== H4
<h4>
Paragraph text should use the brand base font. Inline code should use the brand monospace: #NormalTok("const x = 42");.

#Skylighting(([#NormalTok("text block should use the brand monospace.");],
[#NormalTok("abcdefghijklmnopqrstuvwxyz 0123456789");],));
- Headings: #text(font: "Valley Sans")[Valley Sans]
- Body: #text(font: "Alegreya")[Alegreya]
- Code: #text(font: "CommitMono")[CommitMono]

= Theme colors (semantic)
<theme-colors-semantic>
Read straight out of #NormalTok("_brand.yml");, the same file that styles this site.

#table(
  columns: 3,
  align: (left,left,left,),
  table.header([Token], [Light], [Dark],),
  table.hline(),
  [background], [#NormalTok("#F6EFE1");], [#NormalTok("#0A0A0A");],
  [foreground], [#NormalTok("#1E1512");], [#NormalTok("#F2E8DE");],
  [primary], [#NormalTok("#380C12");], [#NormalTok("#B0293A");],
  [secondary], [#NormalTok("#6B5B52");], [#NormalTok("#C9BAAE");],
  [tertiary], [#NormalTok("#EAE0D8");], [#NormalTok("#241813");],
  [success], [#NormalTok("#146860");], [#NormalTok("#5FCBB8");],
  [info], [#NormalTok("#380C12");], [#NormalTok("#B0293A");],
  [warning], [#NormalTok("#A8721C");], [#NormalTok("#F0BC5C");],
  [danger], [#NormalTok("#A8283A");], [#NormalTok("#D25668");],
)
= Palette (named colors)
<palette-named-colors>
These are the single-value entries under #NormalTok("color.palette");.

#table(
  columns: 2,
  align: (left,left,),
  table.header([Name], [Value],),
  table.hline(),
  [cream], [#NormalTok("#F6EFE1");],
  [blackish], [#NormalTok("#0A0A0A");],
  [espresso], [#NormalTok("#1E1512");],
  [shell], [#NormalTok("#F2E8DE");],
  [oxblood], [#NormalTok("#380C12");],
  [oxblood-light], [#NormalTok("#B0293A");],
  [taupe], [#NormalTok("#6B5B52");],
  [taupe-light], [#NormalTok("#C9BAAE");],
  [blush], [#NormalTok("#EAE0D8");],
  [sable], [#NormalTok("#241813");],
  [teal], [#NormalTok("#146860");],
  [teal-light], [#NormalTok("#5FCBB8");],
  [ochre], [#NormalTok("#A8721C");],
  [ochre-light], [#NormalTok("#F0BC5C");],
  [carmine], [#NormalTok("#A8283A");],
  [carmine-light], [#NormalTok("#D25668");],
  [code-bg-light], [#NormalTok("#F0E6DC");],
  [code-bg-dark], [#NormalTok("#1D1512");],
)
= Components
<components>
#block[
#callout(
body: 
[
Info callout.

]
, 
title: 
[
Note
]
, 
background_color: 
brand-color-background.primary
, 
icon_color: 
brand-color.primary
, 
icon: 
fa-info()
, 
body_background_color: 
brand-color.background
)
]
#block[
#callout(
body: 
[
Warning callout.

]
, 
title: 
[
Warning
]
, 
background_color: 
brand-color-background.warning
, 
icon_color: 
brand-color.warning
, 
icon: 
fa-exclamation-triangle()
, 
body_background_color: 
brand-color.background
)
]
#block[
#callout(
body: 
[
Danger callout.

]
, 
title: 
[
Important
]
, 
background_color: 
brand-color-background.danger
, 
icon_color: 
brand-color.danger
, 
icon: 
fa-exclamation()
, 
body_background_color: 
brand-color.background
)
]
#block[
#callout(
body: 
[
Tip callout.

]
, 
title: 
[
Tip
]
, 
background_color: 
brand-color-background.success
, 
icon_color: 
brand-color.success
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
brand-color.background
)
]
#block[
#callout(
body: 
[
Caution callout.

]
, 
title: 
[
Caution
]
, 
background_color: 
color.mix((rgb("#FC5300"), 15%), (brand-color.background, 85%))
, 
icon_color: 
rgb("#FC5300")
, 
icon: 
fa-fire()
, 
body_background_color: 
brand-color.background
)
]
#quote(block: true)[
Blockquote example. This should remain readable in both light and dark modes.
]

== Table
<table>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Item], [Example],),
  table.hline(),
  [Link], [#link("https://www.visruth.com")],
  [Inline code], [#NormalTok("printf(\"hello\")");],
  [Emphasis], [#emph[italic], #strong[bold], and #strong[#emph[both]]],
)



