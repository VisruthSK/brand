import { schemes } from "./brand";
import { expect, test } from "./fixtures";
import { deckSlides, openPage, openSlide, sitePages } from "./site";

const tooTallToSnapshot = new Set(["LICENSE"]);

for (const target of sitePages.filter((target) => !tooTallToSnapshot.has(target.name))) {
  for (const scheme of schemes) {
    test(`${target.name} ${scheme}`, async ({ page }) => {
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
