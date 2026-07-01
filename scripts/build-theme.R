lines <- readLines("inst/pkgdown/_brand.yml", warn = FALSE)
clean_lines <- sub("\\s*$", "", gsub("\r", "", lines))

# Extract palette key-value pairs
pal_lines <- grep(
  "^[ \\t]+[A-Za-z0-9_-]+:\\s*\"#[0-9A-Fa-f]{6}\"",
  clean_lines,
  value = TRUE,
  perl = TRUE
)
pal <- setNames(
  sub(".*\"(#[0-9A-Fa-f]{6})\".*", "\\1", pal_lines, perl = TRUE),
  sub("^\\s*([\\w-]+):.*", "\\1", pal_lines, perl = TRUE)
)

# Parse indentation-based nested config paths
get_val <- function(path) {
  indent <- 0
  curr_idx <- 1
  for (key in path) {
    pattern <- paste0("^\\s{", indent, "}", key, ":")
    matches <- grep(
      pattern,
      clean_lines[curr_idx:length(clean_lines)],
      perl = TRUE
    )
    if (length(matches) == 0) {
      return(NULL)
    }
    curr_idx <- curr_idx + matches[1] - 1
    indent <- indent + 2
  }
  val <- sub(
    paste0("^\\s*", path[length(path)], ":\\s*(.*)"),
    "\\1",
    clean_lines[curr_idx],
    perl = TRUE
  )
  val <- sub("^\"(.*)\"$", "\\1", val)
  if (val %in% names(pal)) pal[[val]] else val
}

bg <- get_val(c("color", "background", "dark"))
fg <- get_val(c("color", "foreground", "dark"))
primary <- get_val(c("color", "primary", "dark"))
secondary <- get_val(c("color", "secondary", "dark"))
tertiary <- get_val(c("color", "tertiary", "dark"))
success <- get_val(c("color", "success", "dark"))
info <- get_val(c("color", "info", "dark"))
warning <- get_val(c("color", "warning", "dark"))
danger <- get_val(c("color", "danger", "dark"))
code_bg <- get_val(c(
  "typography",
  "monospace-inline",
  "background-color",
  "dark"
))

writeLines(
  paste0(
    "/* Generated dynamically from inst/pkgdown/_brand.yml. Do not edit manually. */\n",
    "[data-bs-theme=\"dark\"] {\n",
    "  --bs-body-bg: ",
    bg,
    " !important;\n",
    "  --bs-body-color: ",
    fg,
    " !important;\n\n",
    "  --bs-primary: ",
    primary,
    " !important;\n",
    "  --bs-primary-rgb: ",
    paste(col2rgb(primary), collapse = ", "),
    " !important;\n\n",
    "  --bs-secondary: ",
    secondary,
    " !important;\n",
    "  --bs-secondary-rgb: ",
    paste(col2rgb(secondary), collapse = ", "),
    " !important;\n\n",
    "  --bs-tertiary: ",
    tertiary,
    " !important;\n",
    "  --bs-tertiary-rgb: ",
    paste(col2rgb(tertiary), collapse = ", "),
    " !important;\n\n",
    "  --bs-success: ",
    success,
    " !important;\n",
    "  --bs-success-rgb: ",
    paste(col2rgb(success), collapse = ", "),
    " !important;\n\n",
    "  --bs-info: ",
    info,
    " !important;\n",
    "  --bs-info-rgb: ",
    paste(col2rgb(info), collapse = ", "),
    " !important;\n\n",
    "  --bs-warning: ",
    warning,
    " !important;\n",
    "  --bs-warning-rgb: ",
    paste(col2rgb(warning), collapse = ", "),
    " !important;\n\n",
    "  --bs-danger: ",
    danger,
    " !important;\n",
    "  --bs-danger-rgb: ",
    paste(col2rgb(danger), collapse = ", "),
    " !important;\n\n",
    "  code, pre {\n",
    "    background-color: ",
    code_bg,
    " !important;\n",
    "  }\n",
    "}\n"
  ),
  "inst/pkgdown/extra.scss"
)
