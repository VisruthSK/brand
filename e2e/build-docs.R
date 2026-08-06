pkgdown::build_site_github_pages(
  override = brand::pkgdown_override(),
  new_process = FALSE,
  install = FALSE
)

brand::use_brand("vignettes/_brand.yml")

quarto::quarto_render(
  "vignettes/example.qmd",
  output_format = "revealjs",
  metadata = list(
    format = list(
      revealjs = list(
        `slide-number` = TRUE,
        smaller = TRUE,
        scrollable = TRUE
      )
    )
  ),
  quarto_args = c("--output-dir", "../docs/slides")
)
file.rename("docs/slides/example.html", "docs/slides/index.html")

quarto::quarto_render(
  "vignettes/_dashboard.qmd",
  output_format = "dashboard",
  quarto_args = c("--output-dir", "../docs/dashboard")
)
file.rename("docs/dashboard/_dashboard.html", "docs/dashboard/index.html")

quarto::quarto_render("website")

brand::use_brand("vignettes/_brand.yml", use_fonts = TRUE)

quarto::quarto_render(
  "vignettes/example.qmd",
  output_format = "typst",
  metadata = list(format = list(typst = list(`keep-typ` = TRUE))),
  quarto_args = c("--output-dir", "../docs/pdf")
)
file.rename("docs/pdf/example.pdf", "docs/pdf/typst.pdf")
file.rename("vignettes/example.typ", "docs/pdf/example.typ")

unlink(c("vignettes/_brand.yml", "vignettes/fonts"), recursive = TRUE)
