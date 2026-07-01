#' Use brand.yml in your project
#'
#' Copies the package's `_brand.yml` to your project root.
#'
#' @param dest Path to copy the file to. Defaults to `"_brand.yml"`.
#' @export
use_brand <- function(dest = "_brand.yml") {
  src <- system.file("pkgdown/_brand.yml", package = "brand", mustWork = TRUE)
  dir <- dirname(dest)
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  file.copy(src, dest, overwrite = TRUE)
  invisible(NULL)
}

#' Path to this package's brand.yml file (Internal)
#'
#' @keywords internal
#' @noRd
brand_yml <- function() {
  path <- system.file("pkgdown/_brand.yml", package = "brand", mustWork = TRUE)

  if (!requireNamespace("yaml", quietly = TRUE)) {
    return(path)
  }

  yml <- yaml::read_yaml(path)

  # Preprocess mode-specific list values to satisfy brand.yml package validation
  if (is.list(yml$color)) {
    theme_fields <- c("foreground", "background", "primary", "secondary", "tertiary",
                      "success", "info", "warning", "danger", "light", "dark")
    for (field in theme_fields) {
      if (is.list(yml$color[[field]])) {
        val <- if (!is.null(yml$color[[field]]$light)) yml$color[[field]]$light else yml$color[[field]][[1]]
        yml$color[[field]] <- val
      }
    }
  }

  if (is.list(yml$typography)) {
    for (el in names(yml$typography)) {
      if (is.list(yml$typography[[el]])) {
        for (prop in names(yml$typography[[el]])) {
          if (is.list(yml$typography[[el]][[prop]])) {
            val <- if (!is.null(yml$typography[[el]][[prop]]$light)) yml$typography[[el]][[prop]]$light else yml$typography[[el]][[prop]][[1]]
            yml$typography[[el]][[prop]] <- val
          }
        }
      }
    }
  }

  tmp <- tempfile(fileext = ".yml")
  yaml::write_yaml(yml, tmp)
  tmp
}
