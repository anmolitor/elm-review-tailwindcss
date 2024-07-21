import { Declaration, Document as PostcssDocument } from "postcss";
import { Config } from "tailwindcss";
interface Options {
    outputSourceDir?: string;
    outputModuleName?: string;
    tailwindConfig?: Config;
}
/**
 * @param {Options} options
 * @returns {import('postcss').Plugin}
 */
declare function plugin(options?: Options): {
    postcssPlugin: string;
    Declaration(decl: Declaration): void;
    Document(document: PostcssDocument): void;
    OnceExit(): void;
};
declare namespace plugin {
    var postcss: boolean;
}
export declare function selectorToTailwindClassNames(selector: string): string[];
export declare const elmReviewTailwindCssPlugin: typeof plugin;
export {};
//# sourceMappingURL=index.d.ts.map