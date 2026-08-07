brand::use_brand()

blob <- "https://github.com/VisruthSK/brand/blob/main/"
writeLines(
  gsub(
    "\\]\\((?!\\w+:)",
    paste0("](", blob),
    readLines("../README.md"),
    perl = TRUE
  ),
  "index.md"
)

file.copy("../vignettes/example.qmd", "example.qmd", overwrite = TRUE)
