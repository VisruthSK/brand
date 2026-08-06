pkgdown::build_site_github_pages(
  override = brand::pkgdown_override(),
  new_process = FALSE,
  install = FALSE
)

brand::use_brand("vignettes/_brand.yml")

quarto::quarto_render(
  "vignettes/example.qmd",
  output_format = "revealjs",
  quarto_args = c(
    "--output-dir",
    "../docs/slides",
    "-M",
    "slide-number:true",
    "-M",
    "smaller:true",
    "-M",
    "scrollable:true"
  )
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
  quarto_args = c("--output-dir", "../docs/pdf")
)
file.rename("docs/pdf/example.pdf", "docs/pdf/typst.pdf")

unlink(c("vignettes/_brand.yml", "vignettes/fonts"), recursive = TRUE)
