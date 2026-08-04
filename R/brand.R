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
#' Quarto reads `color.link` where Bootstrap spells the same thing
#' `typography.link.color`; either form works here.
#'
#' @param path A `_brand.yml`. Values under `color` and `typography` may be
#'   `light`/`dark` maps.
#'
#' @return A named list of `bslib::bs_theme()` arguments.
#' @export
brand_bslib <- function(path = brand_file()) {
  brand <- yaml::read_yaml(path)

  if (is.null(brand$typography$link$color)) {
    brand$typography$link$color <- brand$color$link
  }
  brand$color$link <- NULL

  c(
    list(brand = brand_mode(brand, "light", path)),
    dark_variables(brand_mode(brand, "dark", path))
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
  values <- c(
    brand.yml::brand_sass_color(brand)$defaults,
    brand.yml::brand_sass_typography(brand)$defaults
  ) |>
    lapply(sub, pattern = " !default$", replacement = "")

  colors <- values[paste0(
    "brand_color_",
    c(
      "primary",
      "secondary",
      "success",
      "info",
      "warning",
      "danger",
      "light",
      "dark"
    )
  )] |>
    drop_null()

  drop_null(c(
    lapply(
      c(
        "body-bg-dark" = "brand_color_background",
        "body-color-dark" = "brand_color_foreground",
        "body-secondary-color-dark" = "brand_color_secondary",
        "body-tertiary-color-dark" = "brand_color_tertiary",
        "headings-color-dark" = "brand_typography_headings_color",
        "code-color-dark" = "brand_typography_monospace_inline_color",
        "brand-dark-code-bg" = "brand_typography_monospace_inline_background_color",
        "brand-dark-pre-color" = "brand_typography_monospace_block_color",
        "brand-dark-pre-bg" = "brand_typography_monospace_block_background_color",
        "brand-dark-link-bg" = "brand_typography_link_background_color"
      ),
      function(default) values[[default]]
    ),
    list(
      "link-color-dark" = c(
        values$brand_typography_link_color,
        values$brand_color_primary
      )[1],
      "brand-dark-theme-colors" = if (length(colors)) {
        paste0(
          "(",
          paste0(
            '"',
            sub("^brand_color_", "", names(colors)),
            '": ',
            unlist(colors),
            collapse = ", "
          ),
          ")"
        )
      }
    )
  ))
}

drop_null <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}
