# Copy this package's `_brand.yml` into a project

Quarto picks up a `_brand.yml` sitting beside `_quarto.yml`, so a
document, book, or website styled by the copy matches any pkgdown site
built with `template: package: brand`.

## Usage

``` r
use_brand(file = "_brand.yml", use_fonts = FALSE)
```

## Arguments

- file:

  Path to copy
  [`brand_file()`](https://brand.visruth.com/dev/reference/brand_file.md)
  to.

- use_fonts:

  Also copy this package's `inst/fonts/` next to `file`, and point the
  copy at those files rather than at the web. Only self-hosted families
  need this, and only for Typst: Quarto fetches Google families for a
  PDF itself, and a browser resolves either from the web. Each
  `source: file` face wants a TTF or OTF in `inst/fonts/` named
  `<family>-<weight>-<style>`; one with no such file is an error.

## Value

`file`, invisibly.
