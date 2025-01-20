import { createParser, } from "css-selector-parser";
import * as fs from "fs";
import { createRequire } from "module";
import * as path from "path";
import * as url from "url";
let localRequire = createRequire(import.meta.url);
const { dependencies, version: pluginVersion } = localRequire("../package.json");
const elmPackageName = "elm-review-tailwindcss";
const __dirname = url.fileURLToPath(new URL(".", import.meta.url));
let pkgFile = localRequire.resolve("tailwindcss/package.json", {
    paths: [__dirname],
});
let pkgDir = path.dirname(pkgFile);
const createContext = localRequire(path.join(pkgDir, "lib/lib/setupContextUtils")).createContext;
const resolveConfig = localRequire(path.join(pkgDir, "resolveConfig"));
/**
 * @param {Options} options
 * @returns {import('postcss').Plugin}
 */
function plugin(options = {}) {
    const { outputSourceDir = "review/src", outputModuleName = "TailwindCss.ClassOrder", tailwindConfig = {}, } = options;
    const outputFileName = path.join(outputSourceDir.replace("/", path.sep), outputModuleName.replace(".", path.sep) + ".elm");
    const tailwindClassesAndAffectedProps = new Map();
    const sourceFiles = new Set();
    return {
        postcssPlugin: "elm-review-tailwind-css-plugin",
        Declaration(decl) {
            if (isProblematicCssForSelectorParser(decl)) {
                return;
            }
            const selector = decl.parent.selector;
            const classNames = selectorToTailwindClassNames(selector);
            for (const className of classNames) {
                const previousProps = tailwindClassesAndAffectedProps.get(className);
                if (previousProps) {
                    previousProps.push(decl.prop);
                    continue;
                }
                tailwindClassesAndAffectedProps.set(className, [decl.prop]);
            }
        },
        Document(document) {
            if (!document.source) {
                return;
            }
            const sourceFile = document.source.input.from;
            sourceFiles.add(document.source.input.from);
        },
        OnceExit() {
            const ctx = createContext(resolveConfig(tailwindConfig));
            const classOrder = ctx.getClassOrder(Array.from(tailwindClassesAndAffectedProps.keys()));
            fs.mkdirSync(path.dirname(outputFileName), { recursive: true });
            fs.writeFileSync(outputFileName, `{- !!! DO NOT EDIT THIS FILE MANUALLY !!! -}


module ${outputModuleName} exposing (classOrder, classProps)

{-| 
  This file was automatically generated by
  - [\`elm-review-tailwindcss-postcss-plugin\`](https://www.npmjs.com/package/elm-review-tailwindcss-postcss-plugin) ${pluginVersion}
  - \`postcss\` ${dependencies.postcssVersion}
  - the following source files: ${Array.from(sourceFiles).join(", ")}
  
  To use it, add the accompanying elm-review rule to your \`review/elm.json\` via  \`elm install ${elmPackageName}\`.
  
  @docs classOrder, classProps

-}

import Dict
import Set


{-| A Dict containing all classes declared in your css files with associated weights for
    the TailwindCSS recommended class order.

    Lower weight means the class needs to be further to the left of the class attribute.
    Classes external to Tailwind (declared manually in a css file) have a weight of 0.
-}
classOrder : Dict.Dict String Int
classOrder = 
    Dict.fromList 
        [ ${classOrder
                .map(([className, weight]) => `( "${className}", ${weight ?? 0} )`)
                .join("\n        , ")}
        ]


{-| A Dict containing all classes declared in your css files with associated css properties for
    conflict detection.
-}
classProps : Dict.Dict String (Set.Set String)
classProps = 
    Dict.fromList 
        [ ${Array.from(tailwindClassesAndAffectedProps.entries())
                .map(([className, cssProps]) => `( "${className}", Set.fromList [ ${[
                ...new Set(cssProps.map((cssProp) => `"${cssProp}"`)),
            ].join(", ")} ] )`)
                .join("\n        , ")}
        ]
`);
        },
    };
}
export function selectorToTailwindClassNames(selector) {
    const parse = createParser({ syntax: "progressive" });
    const tree = parse(selector);
    const items = [];
    function collectItemsFromRule(rule) {
        if (rule.nestedRule) {
            collectItemsFromRule(rule.nestedRule);
        }
        items.push(...rule.items);
        for (const item of rule.items) {
            const nestedItemRules = item.argument?.rules ??
                [];
            collectItemsFromRules(nestedItemRules);
        }
    }
    function collectItemsFromRules(rules) {
        for (const rule of rules) {
            collectItemsFromRule(rule);
        }
    }
    collectItemsFromRules(tree.rules);
    return items
        .filter((item) => item.type === "ClassName")
        .map((item) => item.name);
}
function isProblematicCssForSelectorParser(decl) {
    if (!decl.parent) {
        return false;
    }
    if (decl.parent.type === "atrule" &&
        decl.parent.name === "keyframes") {
        return true;
    }
    return isProblematicCssForSelectorParser(decl.parent);
}
plugin.postcss = true;
export const elmReviewTailwindCssPlugin = plugin;
