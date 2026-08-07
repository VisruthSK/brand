import { schemes } from "./brand";
import { expect, test } from "./fixtures";
import { deckSlides, openPage, openSlide, sitePages } from "./site";

const tooTallToSnapshot = new Set(["LICENSE"]);

const reflowsUnpredictablyWhenNarrow = new Set(["articles-example"]);

for (const target of sitePages.filter((target) => !tooTallToSnapshot.has(target.name))) {
  for (const scheme of schemes) {
    test(`${target.name} ${scheme}`, async ({ page, isMobile }) => {
      test.skip(
        isMobile === true && reflowsUnpredictablyWhenNarrow.has(target.name),
        "its runtime table of contents settles at either of two heights",
      );
      await openPage(page, target, scheme);
      await expect(page).toHaveScreenshot(`${target.name}-${scheme}.png`, {
        fullPage: true,
        mask: target.mask === undefined ? [] : [page.locator(target.mask)],
      });
    });
  }
}

for (const slide of deckSlides) {
  test(slide.name, async ({ page }) => {
    await openSlide(page, slide.index);
    await expect(page).toHaveScreenshot(`${slide.name}.png`);
  });
}
