#' Use brand.yml in your project
#'
#' Copies the package's `_brand.yml` to your project root.
#'
#' @param dest Path to copy the file to. Defaults to `"_brand.yml"`.
#' @export
use_brand <- function(dest = "_brand.yml") {
  fs::dir_create(fs::path_dir(dest))
  fs::path_package("brand", "pkgdown", "_brand.yml") |>
    fs::file_copy(dest, overwrite = TRUE)
  invisible(NULL)
}
