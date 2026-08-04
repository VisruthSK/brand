#' Path to this package's `_brand.yml`
#'
#' A single [brand.yml](https://posit-dev.github.io/brand-yml/) file describing
#' the light and dark palettes, in the form Quarto reads directly.
#'
#' @return Absolute path to the installed `_brand.yml`.
#' @export
brand_file <- function() {
  system.file("_brand.yml", package = "brand", mustWork = TRUE)
}

#' Copy this package's `_brand.yml` into a project
#'
#' Quarto picks up a `_brand.yml` sitting beside `_quarto.yml`, so a document,
#' book, or website styled by the copy matches any pkgdown site built with
#' `template: package: brand`.
#'
#' @param file Path to copy [brand_file()] to.
#'
#' @return `file`, invisibly.
#' @export
use_brand <- function(file = "_brand.yml") {
  dir.create(dirname(file), showWarnings = FALSE, recursive = TRUE)
  file.copy(brand_file(), file, overwrite = TRUE)
  invisible(file)
}

#' Site configuration that applies this brand
#'
#' `pkgdown::build_site()` reads `_pkgdown.yml` without evaluating `!expr`
#' tags, so the Bootstrap variables derived from `_brand.yml` cannot come from
#' the file itself. Pass them as `override`, which pkgdown merges into the site
#' config before handing `template.bslib` to `bslib::bs_theme()`:
#'
#' ```r
#' pkgdown::build_site(override = brand::pkgdown_override())
#' ```
#'
#' @param ... Further `_pkgdown.yml` values, such as `destination`.
#' @param path A `_brand.yml`, as read by [brand_bslib()].
#'
#' @return A list suitable for the `override` argument of
#'   `pkgdown::build_site()` and `pkgdown::build_site_github_pages()`.
#' @export
pkgdown_override <- function(..., path = brand_file()) {
  c(list(template = list(bslib = brand_bslib(path))), list(...))
}

#' Bootstrap theme arguments for pkgdown
#'
#' The `template.bslib` list that pkgdown splices into `bslib::bs_theme()`. The
#' light mode goes to bslib as a brand, which maps it onto Bootstrap for us; the
#' dark mode becomes the matching Bootstrap `*-dark` Sass variables, plus the
#' values `extra.scss` needs for the tokens Bootstrap keeps mode-invariant.
#'
#' @param path A `_brand.yml`. Values under `color` and `typography` may be
#'   `light`/`dark` maps, exactly as Quarto allows.
#'
#' @return A named list of `bslib::bs_theme()` arguments.
#' @export
brand_bslib <- function(path = brand_file()) {
  brand <- yaml::read_yaml(path)
  c(
    list(brand = brand_mode(brand, "light")),
    dark_variables(brand_mode(brand, "dark"))
  )
}

brand_mode <- function(brand, mode) {
  brand$color <- select_mode(brand$color, mode)
  brand$typography <- select_mode(brand$typography, mode)
  brand
}

select_mode <- function(x, mode) {
  if (!is.list(x)) {
    return(x)
  }
  if (length(names(x)) && all(names(x) %in% c("light", "dark"))) {
    return(x[[mode]])
  }
  lapply(x, select_mode, mode)
}

theme_colors <- c(
  "primary",
  "secondary",
  "success",
  "info",
  "warning",
  "danger",
  "light",
  "dark"
)

dark_variables <- function(brand) {
  color <- brand$color
  typography <- brand$typography
  hex <- function(value) palette_hex(value, color$palette)

  inline <- typography$`monospace-inline`
  block <- typography$`monospace-block`

  link_color <- typography$link$color
  if (is.null(link_color)) {
    link_color <- color$primary
  }

  drop_null(list(
    "body-bg-dark" = hex(color$background),
    "body-color-dark" = hex(color$foreground),
    "body-secondary-color-dark" = hex(color$secondary),
    "body-tertiary-color-dark" = hex(color$tertiary),
    "code-color-dark" = hex(inline$color),
    "link-color-dark" = hex(link_color),
    "brand-dark-code-bg" = hex(inline$`background-color`),
    "brand-dark-pre-color" = hex(block$color),
    "brand-dark-pre-bg" = hex(block$`background-color`),
    "brand-dark-theme-colors" = sass_map(
      lapply(color[intersect(theme_colors, names(color))], hex)
    )
  ))
}

palette_hex <- function(value, palette) {
  if (length(value) == 1 && value %in% names(palette)) {
    palette[[value]]
  } else {
    value
  }
}

sass_map <- function(x) {
  paste0("(", paste0('"', names(x), '": ', unlist(x), collapse = ", "), ")")
}

drop_null <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}
