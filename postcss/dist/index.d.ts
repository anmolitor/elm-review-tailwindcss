/**
 * @typedef {Object} Options
 * @property {string} [outputSourceDir] - defaults to "review/src",
 * @property {string} [outputModuleName] - defaults to "TailwindCss.ClassOrder",
 * @property {import('tailwindcss').Config} [tailwindConfig] - defaults to {},
 *
 * @param {Options} options
 * @returns {import('postcss').Plugin}
 */
export function elmReviewTailwindCssPlugin(options?: Options): import('postcss').Plugin;
export namespace elmReviewTailwindCssPlugin {
    const postcss: boolean;
}
export type Options = {
    /**
     * - defaults to "review/src",
     */
    outputSourceDir?: string | undefined;
    /**
     * - defaults to "TailwindCss.ClassOrder",
     */
    outputModuleName?: string | undefined;
    /**
     * - defaults to {},
     */
    tailwindConfig?: import("tailwindcss/types/config").Config | undefined;
};
//# sourceMappingURL=index.d.ts.map