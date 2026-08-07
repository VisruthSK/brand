# Personal Brand

**Please do not use this without modification if you are not me.**

---

A pkgdown template package driven by a single [`_brand.yml`](https://posit-dev.github.io/brand-yml/) file. It also exports `brand::use_brand()`, which copies that brand file into the working directory to style Shiny apps, Quarto documents, and anything else that reads brand.yml. Pass `use_fonts = TRUE` only if you self-host a font; families from [Google Fonts](https://fonts.google.com) need nothing extra, Typst included.

To use this, just click the green "Use this template" button and change these things:

1. The actual [`inst/_brand.yml`](inst/_brand.yml)
2. The files in [`inst/fonts/`](inst/fonts), which Typst needs for any family you self-host (I serve mine from <https://www.visruth.com>; families on [Google Fonts](https://fonts.google.com) need nothing here)
3. [`_pkgdown.yml`](_pkgdown.yml), specifically the url; [`inst/pkgdown/_pkgdown.yml`](inst/pkgdown/_pkgdown.yml), removing the Links and Bluesky entries from both `navbar.structure` and `navbar.components`; and [`website/_quarto.yml`](website/_quarto.yml) plus [`website/setup.R`](website/setup.R), which both point at this repo
4. [`DESCRIPTION`](DESCRIPTION): the author and the url
5. Optionally, this [`README.md`](README.md)!

Build the site with [`tools/build-docs.R`](tools/build-docs.R), or at least pass `override = brand::pkgdown_override()` to pkgdown. A plain `pkgdown::build_site()` cannot reach the brand file and will warn and give you an unstyled site.

If you do use this repo as a template it would be nice if you pointed back to this repo somewhere unobtrusive.

