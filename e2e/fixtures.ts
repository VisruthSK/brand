import { expect, type Route, test as base } from "@playwright/test";
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

export { expect };

const localHosts = new Set(["127.0.0.1", "localhost"]);

const allowedExternalHosts = new Set([
  "fonts.googleapis.com",
  "fonts.gstatic.com",
  "cdn.jsdelivr.net",
  "www.visruth.com",
]);

const cacheDirectory = fileURLToPath(new URL("../.playwright", import.meta.url));

type CachedResponse = { status: number; contentType: string; body: string };

function readCache(path: string) {
  try {
    return JSON.parse(readFileSync(path, "utf8")) as CachedResponse;
  } catch {
    return undefined;
  }
}

function cacheBestEffort(path: string, response: CachedResponse) {
  try {
    mkdirSync(cacheDirectory, { recursive: true });
    writeFileSync(path, JSON.stringify(response), { flag: "wx" });
  } catch {}
}

async function fetchAndCache(path: string, route: Route) {
  const response = await route.fetch();
  const fetched: CachedResponse = {
    status: response.status(),
    contentType: response.headers()["content-type"] ?? "application/octet-stream",
    body: (await response.body()).toString("base64"),
  };
  cacheBestEffort(path, fetched);
  return fetched;
}

async function fulfillFromCache(route: Route) {
  const digest = createHash("sha256").update(route.request().url()).digest("hex");
  const path = join(cacheDirectory, `${digest}.json`);
  const response = readCache(path) ?? (await fetchAndCache(path, route).catch(() => undefined));
  if (response === undefined) {
    return route.abort("failed");
  }
  await route.fulfill({
    status: response.status,
    contentType: response.contentType,
    headers: { "access-control-allow-origin": "*" },
    body: Buffer.from(response.body, "base64"),
  });
}

type Problems = { errors: string[]; requests: string[] };

export const test = base.extend<{ problems: Problems }>({
  problems: [
    async ({ page }, use) => {
      const problems: Problems = { errors: [], requests: [] };

      await page.route(/^https?:/, (route) => {
        const { hostname } = new URL(route.request().url());
        if (localHosts.has(hostname)) {
          return route.continue();
        }
        return allowedExternalHosts.has(hostname)
          ? fulfillFromCache(route)
          : route.abort("blockedbyclient");
      });

      page.on("console", (message) => {
        if (message.type() === "error") {
          problems.errors.push(message.text());
        }
      });
      page.on("pageerror", (error) => problems.errors.push(error.message));
      page.on("requestfailed", (request) =>
        problems.requests.push(`${request.failure()?.errorText} ${request.url()}`),
      );
      page.on("response", (response) => {
        if (response.status() >= 400) {
          problems.requests.push(`${response.status()} ${response.url()}`);
        }
      });

      await use(problems);

      expect(problems.errors).toEqual([]);
      expect(problems.requests).toEqual([]);
    },
    { auto: true },
  ],
});
