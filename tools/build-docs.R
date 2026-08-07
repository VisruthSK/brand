pkgdown::build_site_github_pages(
  override = brand::pkgdown_override(),
  new_process = FALSE,
  install = FALSE,
  quiet = FALSE
)

brand::use_brand("vignettes/_brand.yml")

quarto::quarto_render(
  "vignettes/example.qmd",
  output_format = "revealjs",
  output_file = "index.html",
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

quarto::quarto_render(
  "vignettes/_dashboard.qmd",
  output_format = "dashboard",
  output_file = "index.html",
  quarto_args = c("--output-dir", "../docs/dashboard")
)

quarto::quarto_render("website")

brand::use_brand("vignettes/_brand.yml", use_fonts = TRUE)

quarto::quarto_render(
  "vignettes/example.qmd",
  output_format = "typst",
  output_file = "typst.pdf",
  metadata = list(format = list(typst = list(`keep-typ` = TRUE))),
  quarto_args = c("--output-dir", "../docs/pdf")
)
file.rename("vignettes/example.typ", "docs/pdf/example.typ")

unlink(c("vignettes/_brand.yml", "vignettes/fonts"), recursive = TRUE)
