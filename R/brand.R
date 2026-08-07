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
#' @param use_fonts Also copy this package's `inst/fonts/` next to `file`, and
#'   point the copy at those files rather than at the web. Typst reads neither
#'   URLs nor WOFF2, so branded PDFs need a TTF or OTF per face in
#'   `inst/fonts/`, each named `<family>-<weight>-<style>`; a declared face with
#'   no such file is an error. Output bound for a browser needs none of this.
#'
#' @return `file`, invisibly.
#' @export
use_brand <- function(file = "_brand.yml", use_fonts = FALSE) {
  dir.create(dirname(file), showWarnings = FALSE, recursive = TRUE)

  if (!use_fonts) {
    file.copy(brand_file(), file, overwrite = TRUE)
    return(invisible(file))
  }

  brand <- yaml::read_yaml(brand_file())
  brand$typography$fonts <- local_fonts(brand$typography$fonts)

  fonts <- file.path(dirname(file), "fonts")
  dir.create(fonts, showWarnings = FALSE)
  file.copy(list.files(font_dir(), full.names = TRUE), fonts, overwrite = TRUE)
  yaml::write_yaml(brand, file)

  invisible(file)
}

font_dir <- function() {
  system.file("fonts", package = "brand", mustWork = TRUE)
}

face_names <- function(font) {
  vapply(
    font$files,
    function(face) {
      sprintf(
        "%s-%s-%s",
        gsub(" ", "", font$family),
        if (is.null(face$weight)) 400 else face$weight,
        if (is.null(face$style)) "normal" else face$style
      )
    },
    ""
  )
}

local_fonts <- function(fonts) {
  available <- list.files(font_dir(), "\\.(ttf|otf)$")
  names(available) <- sub("\\.[^.]+$", "", available)

  wanted <- lapply(fonts, face_names)
  missing <- setdiff(unlist(wanted), names(available))
  if (length(missing)) {
    stop(missing_faces(missing, available), call. = FALSE)
  }

  for (font in seq_along(fonts)) {
    for (face in seq_along(wanted[[font]])) {
      fonts[[font]]$files[[face]]$path <- file.path(
        "fonts",
        available[[wanted[[font]][[face]]]]
      )
    }
  }
  fonts
}

missing_faces <- function(missing, available) {
  bullets <- function(x) paste0("  ", x, collapse = "\n")
  sprintf(
    paste(
      "`use_fonts = TRUE` needs a local file for every font face in `%s`.",
      "No file for:",
      "%s",
      "Faces are matched on `<family>-<weight>-<style>`, spaces stripped from",
      "the family. Add each one as a `.ttf` or `.otf` to `%s`, which holds:",
      "%s",
      sep = "\n"
    ),
    brand_file(),
    bullets(paste0(missing, ".ttf")),
    font_dir(),
    bullets(available)
  )
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
#' `brand-font-faces` carries every file-sourced face because bslib emits only
#' the first face of each such family: the dependencies it builds share a name
#' and a version, so `htmltools` keeps one and drops the bold and the italic.
#'
#' Bootstrap spells the link colour `typography.link.color`, which is also the
#' only form Quarto's Typst output honours -- it ignores `color.link` and falls
#' back to `color.primary`. `color.link` is accepted here for completeness.
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
      "navbar-dark-color" = navbar_color,
      "navbar-dark-hover-color" = navbar_color,
      "navbar-dark-active-color" = navbar_color,
      "brand-navbar-version-color" = dark$color$warning,
      "brand-font-faces" = sass_font_faces(brand$typography$fonts)
    )),
    dark_variables(dark)
  )
}

sass_font_faces <- function(fonts) {
  faces <- unlist(lapply(fonts, function(font) {
    vapply(
      font$files,
      function(face) {
        sprintf(
          '("%s", "%s", %s, %s, %s)',
          font$family,
          face$path,
          font_format(face$path),
          if (is.null(face$weight)) 400 else face$weight,
          if (is.null(face$style)) "normal" else face$style
        )
      },
      ""
    )
  }))
  if (length(faces)) {
    sprintf("(%s,)", paste(faces, collapse = ", "))
  }
}

font_format <- function(path) {
  known <- c(woff2 = "woff2", woff = "woff", ttf = "truetype", otf = "opentype")
  format <- known[tolower(sub(".*\\.", "", path))]
  if (is.na(format)) "null" else sprintf('"%s"', format)
}

brand_mode <- function(brand, mode, path) {
  brand$color <- select_mode(brand$color, mode, "palette")
  brand$typography <- select_mode(brand$typography, mode, "fonts")
  brand <- brand.yml::as_brand_yml(brand)
  brand$path <- path
  brand
}

select_mode <- function(x, mode, keep = character()) {
  if (!is.list(x)) {
    return(x)
  }
  modes <- names(x)
  if (length(modes) && all(modes %in% c("light", "dark"))) {
    return(if (mode %in% modes) select_mode(x[[mode]], mode))
  }
  resolved <- setdiff(modes, keep)
  x[resolved] <- lapply(x[resolved], select_mode, mode)
  drop_null(x)
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
