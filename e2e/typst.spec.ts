import { expect, test } from "@playwright/test";
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { docsDirectory } from "./site";

const pdfDirectory = join(docsDirectory, "pdf");

for (const file of readdirSync(pdfDirectory).filter((name) => name.endsWith(".typ"))) {
  test(`typst preamble of ${file}`, () => {
    const source = readFileSync(join(pdfDirectory, file), "utf8");
    const preamble = source.slice(source.indexOf("#let brand-color = ("), source.indexOf("\n= "));
    expect(preamble).toMatchSnapshot(`${file.replace(/\.typ$/, "")}-preamble.typ`);
  });
}
