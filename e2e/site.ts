import { expect, type Page } from "@playwright/test";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

export const schemes = ["light", "dark"] as const;

export type Scheme = (typeof schemes)[number];

declare global {
  interface Window {
    Reveal?: {
      isReady(): boolean;
      configure(options: Record<string, unknown>): void;
      slide(index: number): void;
      getIndices(): { h: number };
    };
  }
}

export type SiteKind = "pkgdown" | "quarto";

export type SitePage = {
  url: string;
  name: string;
  kind: SiteKind;
  mask: string | undefined;
};

export const docsDirectory = fileURLToPath(new URL("../docs", import.meta.url));

const unbuiltSite = `No rendered site in ${docsDirectory}; run npm run render first`;

const deckPath = "slides/index.html";

const vendoredAssets = /(^|\/)(deps|site_libs|libs|[^/]*_files)\//;

const servedOnlyFromTheDeployedSite = new Set(["404.html"]);

const volatilePkgdownText = ".navbar .nav-text, .pkgdown-footer-right, #citation ~ p, #citation ~ pre";

const htmlPaths = (existsSync(docsDirectory) ? readdirSync(docsDirectory, { recursive: true }) : [])
  .map((entry) => String(entry).split("\\").join("/"))
  .filter((entry) => entry.endsWith(".html"))
  .filter((entry) => !vendoredAssets.test(entry))
  .sort();

if (htmlPaths.length === 0) {
  throw new Error(unbuiltSite);
}

const kindOf = (path: string): SiteKind =>
  path.startsWith("website/") || path.startsWith("dashboard/") ? "quarto" : "pkgdown";

export const sitePages: SitePage[] = htmlPaths
  .filter((path) => path !== deckPath)
  .filter((path) => !servedOnlyFromTheDeployedSite.has(path))
  .map((path) => ({
    url: `/${path}`,
    name: path.replace(/\.html$/, "").split("/").join("-"),
    kind: kindOf(path),
    mask: kindOf(path) === "pkgdown" ? volatilePkgdownText : undefined,
  }));

export function sitePage(name: string): SitePage {
  const page = sitePages.find((candidate) => candidate.name === name);
  if (page === undefined) {
    throw new Error(`${unbuiltSite} (no page named ${name})`);
  }
  return page;
}

if (!htmlPaths.includes(deckPath)) {
  throw new Error(`${unbuiltSite} (no ${deckPath})`);
}

export const deckSlides = [
  ...readFileSync(join(docsDirectory, deckPath), "utf8").matchAll(/<section id="([^"]+)"/g),
].map((match, index) => ({ name: `slides-${match[1]}`, index }));

export async function openPage(page: Page, target: SitePage, scheme: Scheme) {
  if (target.kind === "pkgdown" && scheme === "dark") {
    await page.addInitScript(() => localStorage.setItem("theme", "dark"));
  }
  await page.goto(target.url);
  if (target.kind === "quarto" && scheme === "dark") {
    await page.locator(".quarto-color-scheme-toggle").click();
  }
  if (target.kind === "pkgdown") {
    await expect(page.locator("html")).toHaveAttribute("data-bs-theme", scheme);
  } else {
    await expect(page.locator("body")).toHaveClass(new RegExp(`\\bquarto-${scheme}\\b`));
  }
  await page.evaluate(() => document.fonts.ready);
}

export async function openSlide(page: Page, index: number) {
  await page.goto(`/${deckPath}`);
  await page.waitForFunction(() => window.Reveal?.isReady() === true);
  await page.evaluate((slide) => {
    window.Reveal!.configure({ transition: "none", backgroundTransition: "none" });
    window.Reveal!.slide(slide);
  }, index);
  await page.waitForFunction((slide) => window.Reveal!.getIndices().h === slide, index);
  await page.evaluate(() => document.fonts.ready);
}
