export const fonts = {
  base: "Domine",
  headings: "Valley Sans",
  monospace: "CommitMono",
};

export const palette = {
  light: {
    background: "#F6EFE1",
    foreground: "#1E1512",
    primary: "#380C12",
    link: "#A8283A",
    code: "#A8283A",
  },
  dark: {
    background: "#0A0A0A",
    foreground: "#F2E8DE",
    primary: "#B0293A",
    link: "#D25668",
    code: "#D25668",
  },
};

export type Scheme = keyof typeof palette;

export const schemes = Object.keys(palette) as Scheme[];

export const navbar = {
  background: {
    pkgdown: { light: palette.light.primary, dark: palette.light.primary },
    quarto: { light: palette.light.primary, dark: palette.dark.primary },
  },
  foreground: palette.dark.foreground,
};

export function rgb(hex: string) {
  const channels = hex
    .replace("#", "")
    .match(/../g)!
    .map((channel) => Number.parseInt(channel, 16));
  return `rgb(${channels.join(", ")})`;
}

export function fontFamily(family: string) {
  return new RegExp(`^"?${family}"?`);
}
