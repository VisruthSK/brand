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
