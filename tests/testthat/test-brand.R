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
    face_names(list(family = "Fixture Sans", files = list(list(path = "x")))),
    "FixtureSans-400-normal"
  )
})

test_that("local_fonts() names every face it cannot find a file for", {
  font <- list(list(
    family = "Nonexistent",
    files = list(list(weight = 400, style = "normal"))
  ))
  expect_error(local_fonts(font), "Nonexistent-400-normal.ttf", fixed = TRUE)
})

test_that("sass_font_faces() renders the file faces as a Sass list", {
  fonts <- list(
    list(family = "Fixture Serif", source = "google"),
    list(
      family = "Fixture Sans",
      source = "file",
      files = list(
        list(path = "bold.woff2", weight = 700, style = "italic"),
        list(path = "plain.woff2")
      )
    )
  )
  expect_equal(
    sass_font_faces(fonts),
    paste0(
      '(("Fixture Sans", "bold.woff2", "woff2", 700, italic), ',
      '("Fixture Sans", "plain.woff2", "woff2", 400, normal),)'
    )
  )
})

test_that("sass_font_faces() is absent when no font ships a file", {
  expect_null(
    sass_font_faces(list(list(family = "Fixture Serif", source = "google")))
  )
})

test_that("font_format() names the format the extension implies", {
  expect_equal(font_format("a.woff2"), '"woff2"')
  expect_equal(font_format("a.WOFF"), '"woff"')
  expect_equal(font_format("fonts/a.ttf"), '"truetype"')
  expect_equal(font_format("fonts/a.otf"), '"opentype"')
})

test_that("font_format() leaves the hint out rather than guessing", {
  expect_equal(font_format("a.dfont"), "null")
})

test_that("select_mode() resolves one mode and keeps the palette whole", {
  color <- list(
    palette = list(light = "#FFFFFF", dark = "#000000"),
    background = list(light = "paper", dark = "soot"),
    primary = "ink",
    warning = list(light = "amber")
  )
  expect_equal(
    select_mode(color, "dark", "palette"),
    list(
      palette = list(light = "#FFFFFF", dark = "#000000"),
      background = "soot",
      primary = "ink"
    )
  )
})

test_that("select_mode() recurses into maps that are not modes", {
  value <- list(color = list(light = "ink", dark = "chalk"))
  expect_equal(select_mode(value, "light"), list(color = "ink"))
})

test_that("drop_null() removes only NULL entries", {
  expect_equal(drop_null(list(a = 1, b = NULL, c = NA)), list(a = 1, c = NA))
})

two_mode_brand <- function() {
  path <- tempfile(fileext = ".yml")
  yaml::write_yaml(
    list(
      color = list(
        palette = list(ink = "#111111"),
        background = list(light = "#FFFFFF", dark = "#000000"),
        foreground = list(light = "ink", dark = "#EEEEEE"),
        primary = list(light = "#222222", dark = "#333333"),
        link = list(light = "#444444", dark = "#555555")
      ),
      typography = list(headings = "Fixture Sans")
    ),
    path
  )
  path
}

test_that("brand_bslib() hands bslib the light brand", {
  path <- two_mode_brand()
  on.exit(unlink(path))

  theme <- brand_bslib(path)

  expect_s3_class(theme$brand, "brand_yml")
  expect_equal(theme$brand$color$primary, "#222222")
  expect_equal(theme$brand$typography$headings$family, "Fixture Sans")
  expect_equal(theme$brand$path, path)
})

test_that("brand_bslib() derives the dark mode as Bootstrap variables", {
  path <- two_mode_brand()
  on.exit(unlink(path))

  theme <- brand_bslib(path)

  expect_equal(theme[["body-bg-dark"]], "#000000")
  expect_equal(theme[["body-color-dark"]], "#EEEEEE")
  expect_equal(theme[["link-color-dark"]], "#555555")
  expect_match(theme[["brand-dark-theme-colors"]], '^\\("primary": #333333')
})

test_that("brand_bslib() colours the navbar from both modes", {
  path <- two_mode_brand()
  on.exit(unlink(path))

  theme <- brand_bslib(path)
  navbar <- theme[startsWith(names(theme), "navbar-")]

  expect_equal(navbar[["navbar-bg"]], "#222222")
  expect_true(all(unlist(navbar[names(navbar) != "navbar-bg"]) == "#EEEEEE"))
})

test_that("brand_bslib() reads the brand this package ships", {
  theme <- brand_bslib()

  expect_s3_class(theme$brand, "brand_yml")
  expect_equal(theme$brand$path, brand_file())
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
