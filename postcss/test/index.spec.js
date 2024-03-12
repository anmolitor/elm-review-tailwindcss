import { describe, expect, it } from "vitest";
import { selectorToTailwindClassNames } from "../src/index.js";

describe("selector to className", () => {
  it("works for standard class selectors", () => {
    expect(selectorToTailwindClassNames(".p-2")).toEqual(["p-2"]);
  });
  it("filters out html selectors", () => {
    expect(selectorToTailwindClassNames("div")).toEqual([]);
  });
  it("escapes colons", () => {
    expect(selectorToTailwindClassNames(".hover\\:block")).toEqual([
      "hover:block",
    ]);
  });
  it("can deal with :is(wrapper)", () => {
    const classNames = selectorToTailwindClassNames(
      ":is(.dark .dark\\:bg-gray-100)"
    );
    expect(classNames).toEqual(
      expect.arrayContaining(["dark", "dark:bg-gray-100"])
    );
    expect(classNames.length).toBe(2);
  });
  it("can deal with tilde operator", () => {
    const classNames = selectorToTailwindClassNames(
      ".peer[open] ~ .peer-open\\:right-0"
    );
    expect(classNames).toEqual(
      expect.arrayContaining(["peer", "peer-open:right-0"])
    );
    expect(classNames.length).toBe(2);
  });
  it("can deal with tilde operator 2", () => {
    const classNames = selectorToTailwindClassNames(
      ".peer:checked ~ .peer-checked\\:left-0"
    );
    expect(classNames).toEqual(
      expect.arrayContaining(["peer", "peer-checked:left-0"])
    );
    expect(classNames.length).toBe(2);
  });
  it("can deal complex nested construct", () => {
    const classNames = selectorToTailwindClassNames(
      ".peer[open] ~ :is(.dark .peer-open\\:hover\\:dark\\:right-0):hover"
    );
    expect(classNames).toEqual(
      expect.arrayContaining(["peer", "dark", "peer-open:hover:dark:right-0"])
    );
    expect(classNames.length).toBe(3);
  });
});
