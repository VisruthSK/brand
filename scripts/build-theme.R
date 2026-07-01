yml <- yaml::read_yaml("inst/pkgdown/_brand.yml")
pal <- yml$color$palette
colors <- lapply(yml$`dark-mode-color`, function(x) pal[[x]])

writeLines(
  paste0(
    "/* Generated dynamically from inst/pkgdown/_brand.yml. Do not edit manually. */\n",
    "[data-bs-theme=\"dark\"] {\n",
    "  --bs-body-bg: ", colors$background, " !important;\n",
    "  --bs-body-color: ", colors$foreground, " !important;\n\n",
    "  --bs-primary: ", colors$primary, " !important;\n",
    "  --bs-primary-rgb: ", paste(col2rgb(colors$primary), collapse = ", "), " !important;\n\n",
    "  --bs-secondary: ", colors$secondary, " !important;\n",
    "  --bs-secondary-rgb: ", paste(col2rgb(colors$secondary), collapse = ", "), " !important;\n\n",
    "  --bs-tertiary: ", colors$tertiary, " !important;\n",
    "  --bs-tertiary-rgb: ", paste(col2rgb(colors$tertiary), collapse = ", "), " !important;\n\n",
    "  --bs-success: ", colors$success, " !important;\n",
    "  --bs-success-rgb: ", paste(col2rgb(colors$success), collapse = ", "), " !important;\n\n",
    "  --bs-info: ", colors$info, " !important;\n",
    "  --bs-info-rgb: ", paste(col2rgb(colors$info), collapse = ", "), " !important;\n\n",
    "  --bs-warning: ", colors$warning, " !important;\n",
    "  --bs-warning-rgb: ", paste(col2rgb(colors$warning), collapse = ", "), " !important;\n\n",
    "  --bs-danger: ", colors$danger, " !important;\n",
    "  --bs-danger-rgb: ", paste(col2rgb(colors$danger), collapse = ", "), " !important;\n\n",
    "  code, pre {\n",
    "    background-color: ", pal[[yml$`dark-mode-typography`$`monospace-inline`$`background-color`]], " !important;\n",
    "  }\n",
    "}\n"
  ),
  "inst/pkgdown/extra.scss"
)
