import { expect, test } from "@playwright/test";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { docsDirectory } from "./site";

test("typst preamble", () => {
  const source = readFileSync(join(docsDirectory, "pdf", "example.typ"), "utf8");
  const preamble = source.slice(source.indexOf("#let brand-color = ("), source.indexOf("\n= "));
  expect(preamble).toMatchSnapshot("preamble.typ");
});
