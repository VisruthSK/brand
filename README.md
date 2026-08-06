# Personal Brand

**Please do not use this without modification if you are not me.**

---

A pkgdown template package driven by a single [`_brand.yml`](https://posit-dev.github.io/brand-yml/) file. This package also exports a simple function `brand::use_brand()` which copies that brand file into the working directory to style Shiny apps, Quarto files, etc. Pass `use_fonts = TRUE` to copy the fonts alongside it, which Typst needs since it can read neither URLs nor WOFF2.

To use this, just click the green "Use this template" button and change these things:

1. The actual [`inst/_brand.yml`](inst/_brand.yml)
2. The font sources in [`inst/pkgdown/extra.scss`](inst/pkgdown/extra.scss), and the files in [`inst/fonts/`](inst/fonts) (I self-host some fonts on <https://www.visruth.com>, which you won't have to do if you only use fonts available on [Google Fonts](https://fonts.google.com))
3. [`_pkgdown.yml`](_pkgdown.yml), specifically the url; and [`inst/pkgdown/_pkgdown.yml`](inst/pkgdown/_pkgdown.yml), removing the Links and Bluesky components
4. [`DESCRIPTION`](DESCRIPTION): the author, the url, and `Config/Needs/website`, which points this package's own site back at itself
5. Optionally, this [`README.md`](README.md)!

If you do use this repo as a template it would be nice if you pointed back to this repo somewhere unobtrusive.

