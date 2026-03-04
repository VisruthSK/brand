#' Hello!
#'
#' Trivial example for documentation.
#'
#' @param name Character to greet. Defaults to `world`.
#' @return Character greeting.
#' @examples
#' hello()
#' hello("Stan")
#' @export
hello <- function(name = "world") {
  paste0("Hello, ", name, "!")
}
