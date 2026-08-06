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
#' @param path A `_brand.yml`, in the form described in [brand_file()].
#'
#' @return A list suitable for the `override` argument of
#'   `pkgdown::build_site()` and `pkgdown::build_site_github_pages()`.
#' @export
pkgdown_override <- function(..., path = brand_file()) {
  list(template = list(bslib = brand_bslib(path)), ...)
}

#' Bootstrap theme arguments for pkgdown
#'
#' The `template.bslib` list that pkgdown splices into `bslib::bs_theme()`. The
#' light mode goes to bslib as a brand, which maps it onto Bootstrap for us; the
#' dark mode becomes the matching Bootstrap `*-dark` Sass variables, plus the
#' values `extra.scss` needs for the tokens Bootstrap keeps mode-invariant.
#'
#' Quarto reads `color.link` where Bootstrap spells the same thing
#' `typography.link.color`; either form works here.
#'
#' @param path A `_brand.yml`. Values under `color` and `typography` may be
#'   `light`/`dark` maps.
#'
#' @return A named list of `bslib::bs_theme()` arguments.
#' @noRd
brand_bslib <- function(path = brand_file()) {
  brand <- yaml::read_yaml(path)

  if (is.null(brand$typography$link$color)) {
    brand$typography$link$color <- brand$color$link
  }
  brand$color$link <- NULL

  light <- brand_mode(brand, "light", path)
  dark <- brand_mode(brand, "dark", path)
  navbar_color <- dark$color$foreground

  c(
    list(brand = light),
    drop_null(list(
      "navbar-bg" = light$color$primary,
      "navbar-light-color" = navbar_color,
      "navbar-light-hover-color" = navbar_color,
      "navbar-light-active-color" = navbar_color,
      "navbar-light-brand-color" = navbar_color,
      "navbar-light-brand-hover-color" = navbar_color,
      "navbar-dark-color" = navbar_color,
      "navbar-dark-hover-color" = navbar_color,
      "navbar-dark-active-color" = navbar_color,
      "navbar-dark-brand-color" = navbar_color,
      "navbar-dark-brand-hover-color" = navbar_color
    )),
    dark_variables(dark)
  )
}

brand_mode <- function(brand, mode, path) {
  brand$color <- select_mode(brand$color, "palette", mode)
  brand$typography <- select_mode(brand$typography, "fonts", mode)
  brand <- brand.yml::as_brand_yml(brand)
  brand$path <- path
  brand
}

select_mode <- function(x, keep, mode) {
  if (!is.list(x)) {
    return(x)
  }
  selected <- setdiff(names(x), keep)
  x[selected] <- lapply(x[selected], select_value, mode)
  drop_null(x)
}

select_value <- function(value, mode) {
  modes <- names(value)
  if (is.list(value) && length(modes) && all(modes %in% c("light", "dark"))) {
    value <- if (mode %in% modes) value[[mode]]
  }
  select_mode(value, character(), mode)
}

dark_variables <- function(brand) {
  color <- brand$color
  typography <- brand$typography

  theme_colors <- intersect(
    c(
      "primary",
      "secondary",
      "success",
      "info",
      "warning",
      "danger",
      "light",
      "dark"
    ),
    names(color)
  )

  drop_null(list(
    "body-bg-dark" = color$background,
    "body-color-dark" = color$foreground,
    "body-secondary-color-dark" = color$secondary,
    "body-tertiary-color-dark" = color$tertiary,
    "headings-color-dark" = typography$headings$color,
    "code-color-dark" = typography$monospace_inline$color,
    "brand-dark-code-bg" = typography$monospace_inline$background_color,
    "brand-dark-pre-color" = typography$monospace_block$color,
    "brand-dark-pre-bg" = typography$monospace_block$background_color,
    "brand-dark-link-bg" = typography$link$background_color,
    "link-color-dark" = c(typography$link$color, color$primary)[1],
    "brand-dark-theme-colors" = if (length(theme_colors)) {
      paste0(
        "(",
        paste(
          sprintf('"%s": %s', theme_colors, unlist(color[theme_colors])),
          collapse = ", "
        ),
        ")"
      )
    }
  ))
}

drop_null <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}
