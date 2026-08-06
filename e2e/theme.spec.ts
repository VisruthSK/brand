import { fontFamily, fonts, navbar, palette, rgb, schemes } from "./brand";
import { expect, test } from "./fixtures";
import { expectFontsLoaded, openPage, openSlide, sitePage, sitePages } from "./site";

type Typography = { heading?: string; body: string; code: string; link?: string };

const typography: Record<string, Typography> = {
  index: { heading: "main h1", body: "main p", code: "main code", link: "main a[href]" },
  "reference-pkgdown_override": {
    heading: "main h1",
    body: "main p",
    code: "main code",
    link: "main a[href]",
  },
  "articles-example": { heading: "main h1", body: "main p", code: "main p code", link: "main a[href]" },
  "website-index": { heading: "main h1", body: "main p", code: "main p code", link: "main a[href]" },
  "website-example": { heading: "main h1", body: "main p", code: "main p code" },
  "dashboard-index": { body: ".card-body p", code: ".card-body code" },
};

for (const scheme of schemes) {
  const colors = palette[scheme];

  for (const target of sitePages) {
    test(`${target.name} ${scheme} palette`, async ({ page }) => {
      await openPage(page, target, scheme);
      await expect(page.locator("body")).toHaveCSS("color", rgb(colors.foreground));
      await expect(page.locator("html")).toHaveCSS("--bs-primary", colors.primary);
      await expect(page.locator("html")).toHaveCSS("--bs-link-color", colors.link);
      await expect(page.locator(".navbar").first()).toHaveCSS(
        "background-color",
        rgb(navbar.background[target.kind][scheme]),
      );
      if (target.kind === "pkgdown") {
        await expect(page.locator(".navbar .nav-link").first()).toHaveCSS("color", rgb(navbar.foreground));
      }
    });
  }

  test(`dashboard-index ${scheme} header`, async ({ page }) => {
    await openPage(page, sitePage("dashboard-index"), scheme);
    await expect(page.locator(".navbar-title")).toHaveCSS("font-family", fontFamily(fonts.headings));
    const toggleIconFilter = await page
      .locator(".quarto-color-scheme-toggle .bi")
      .evaluate((icon) => getComputedStyle(icon, "::before").filter);
    expect(toggleIconFilter).toBe("brightness(0) invert(1)");
  });

  for (const [name, selectors] of Object.entries(typography)) {
    test(`${name} ${scheme} typography`, async ({ page }) => {
      await openPage(page, sitePage(name), scheme);
      await expectFontsLoaded(page, [fonts.monospace]);
      if (selectors.heading !== undefined) {
        await expect(page.locator(selectors.heading).first()).toHaveCSS(
          "font-family",
          fontFamily(fonts.headings),
        );
      }
      await expect(page.locator(selectors.body).first()).toHaveCSS("font-family", fontFamily(fonts.base));
      await expect(page.locator(selectors.code).first()).toHaveCSS(
        "font-family",
        fontFamily(fonts.monospace),
      );
      await expect(page.locator(selectors.code).first()).toHaveCSS("color", rgb(colors.code));
      if (selectors.link !== undefined) {
        await expect(page.locator(selectors.link).first()).toHaveCSS("color", rgb(colors.link));
      }
    });
  }
}

test("deck title typography", async ({ page }) => {
  await openSlide(page, 0);
  await expect(page.locator("body")).toHaveCSS("background-color", rgb(palette.light.background));
  await expect(page.locator("section.present h1").first()).toHaveCSS(
    "font-family",
    fontFamily(fonts.headings),
  );
});

test("deck content typography", async ({ page }) => {
  await openSlide(page, 1);
  await expectFontsLoaded(page, [fonts.monospace]);
  await expect(page.locator("section.present").first()).toHaveCSS("color", rgb(palette.light.foreground));
  await expect(page.locator("section.present").first()).toHaveCSS("font-family", fontFamily(fonts.base));
  await expect(page.locator("section.present h2").first()).toHaveCSS(
    "font-family",
    fontFamily(fonts.headings),
  );
  await expect(page.locator("section.present code").first()).toHaveCSS(
    "font-family",
    fontFamily(fonts.monospace),
  );
});
