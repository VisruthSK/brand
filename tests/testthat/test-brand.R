test_that("brand_file() finds the installed brand", {
  expect_true(file.exists(brand_file()))
  expect_equal(basename(brand_file()), "_brand.yml")
})

test_that("use_brand() copies the brand file verbatim", {
  dir <- tempfile()
  on.exit(unlink(dir, recursive = TRUE))
  file <- file.path(dir, "_brand.yml")

  expect_equal(use_brand(file), file)
  expect_identical(readLines(file), readLines(brand_file()))
  expect_false(dir.exists(file.path(dir, "fonts")))
})

test_that("use_brand(use_fonts = TRUE) points file fonts at local copies", {
  dir <- tempfile()
  on.exit(unlink(dir, recursive = TRUE))
  file <- file.path(dir, "_brand.yml")
  use_brand(file, use_fonts = TRUE)

  fonts <- yaml::read_yaml(file)$typography$fonts
  hosted <- Filter(function(font) font$source == "file", fonts)
  paths <- unlist(lapply(hosted, function(font) {
    vapply(font$files, function(face) face$path, "")
  }))

  expect_true(length(paths) > 0)
  expect_true(all(startsWith(paths, "fonts/")))
  expect_true(all(file.exists(file.path(dir, paths))))
})

test_that("use_brand(use_fonts = TRUE) leaves google fonts alone", {
  dir <- tempfile()
  on.exit(unlink(dir, recursive = TRUE))
  file <- file.path(dir, "_brand.yml")
  use_brand(file, use_fonts = TRUE)

  google <- function(path) {
    Filter(
      function(font) font$source == "google",
      yaml::read_yaml(path)$typography$fonts
    )
  }
  expect_identical(google(file), google(brand_file()))
})

test_that("face_names() defaults to weight 400 and normal style", {
  expect_equal(
    face_names(list(family = "Valley Sans", files = list(list(path = "x")))),
    "ValleySans-400-normal"
  )
})

test_that("local_fonts() names every face it cannot find a file for", {
  font <- list(list(
    family = "Nonexistent",
    files = list(list(weight = 400, style = "normal"))
  ))
  expect_error(local_fonts(font), "Nonexistent-400-normal.ttf", fixed = TRUE)
})

test_that("select_mode() resolves one mode and keeps the palette whole", {
  color <- list(
    palette = list(light = "#F6EFE1", dark = "#0A0A0A"),
    background = list(light = "cream", dark = "blackish"),
    primary = "oxblood",
    warning = list(light = "ochre")
  )
  expect_equal(
    select_mode(color, "palette", "dark"),
    list(
      palette = list(light = "#F6EFE1", dark = "#0A0A0A"),
      background = "blackish",
      primary = "oxblood"
    )
  )
})

test_that("select_value() recurses into maps that are not modes", {
  value <- list(color = list(light = "carmine", dark = "oxblood-light"))
  expect_equal(select_value(value, "light"), list(color = "carmine"))
})

test_that("drop_null() removes only NULL entries", {
  expect_equal(drop_null(list(a = 1, b = NULL, c = NA)), list(a = 1, c = NA))
})

test_that("brand_bslib() hands bslib the light brand", {
  theme <- brand_bslib()

  expect_s3_class(theme$brand, "brand_yml")
  expect_equal(theme$brand$color$primary, "#380C12")
  expect_equal(theme$brand$typography$headings$family, "Valley Sans")
  expect_equal(theme$brand$path, brand_file())
})

test_that("brand_bslib() derives the dark mode as Bootstrap variables", {
  theme <- brand_bslib()

  expect_equal(theme[["body-bg-dark"]], "#0A0A0A")
  expect_equal(theme[["body-color-dark"]], "#F2E8DE")
  expect_equal(theme[["link-color-dark"]], "#DA5265")
  expect_match(theme[["brand-dark-theme-colors"]], '^\\("primary": #DA5265,')
})

test_that("brand_bslib() colours the navbar from both modes", {
  theme <- brand_bslib()
  navbar <- theme[startsWith(names(theme), "navbar-")]

  expect_equal(navbar[["navbar-bg"]], "#380C12")
  expect_true(all(unlist(navbar[names(navbar) != "navbar-bg"]) == "#F2E8DE"))
})

test_that("brand_bslib() reads color.link where Bootstrap wants a typography key", {
  path <- tempfile(fileext = ".yml")
  on.exit(unlink(path))
  yaml::write_yaml(
    list(color = list(link = list(light = "#111111", dark = "#EEEEEE"))),
    path
  )

  theme <- brand_bslib(path)
  expect_equal(theme$brand$typography$link$color, "#111111")
  expect_equal(theme[["link-color-dark"]], "#EEEEEE")
})

test_that("pkgdown_override() nests the theme and passes extras through", {
  override <- pkgdown_override(destination = "docs")

  expect_equal(override$template$bslib, brand_bslib())
  expect_equal(override$destination, "docs")
})
