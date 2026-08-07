# Site configuration that applies this brand

[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
reads `_pkgdown.yml` without evaluating `!expr` tags, so the Bootstrap
variables derived from `_brand.yml` cannot come from the file itself.
Pass them as `override`, which pkgdown merges into the site config
before handing `template.bslib` to
[`bslib::bs_theme()`](https://rstudio.github.io/bslib/reference/bs_theme.html):

## Usage

``` r
pkgdown_override(..., path = brand_file())
```

## Arguments

- ...:

  Further `_pkgdown.yml` values, such as `destination`.

- path:

  A `_brand.yml`, in the form described in
  [`brand_file()`](https://brand.visruth.com/dev/reference/brand_file.md).

## Value

A list suitable for the `override` argument of
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
and
[`pkgdown::build_site_github_pages()`](https://pkgdown.r-lib.org/reference/build_site_github_pages.html).

## Details

    pkgdown::build_site(override = brand::pkgdown_override())
