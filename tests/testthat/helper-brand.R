brand_yml <- function(brand) {
  path <- tempfile(fileext = ".yml")
  yaml::write_yaml(brand, path)
  path
}

copy_target <- function() {
  file.path(tempfile(), "_brand.yml")
}

from_source <- function(source) {
  function(font) identical(font$source, source)
}

two_modes <- list(
  color = list(
    palette = list(ink = "#111111"),
    background = list(light = "#FFFFFF", dark = "#000000"),
    foreground = list(light = "ink", dark = "#EEEEEE"),
    primary = list(light = "#222222", dark = "#333333"),
    link = list(light = "#444444", dark = "#555555")
  ),
  typography = list(headings = "Fixture Sans")
)

sans_faces <- list(
  family = "Fixture Sans",
  source = "file",
  files = list(
    list(path = "bold.woff2", weight = 700, style = "italic"),
    list(path = "plain.woff2")
  )
)

serif <- list(family = "Fixture Serif", source = "google")
