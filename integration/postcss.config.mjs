import tailwindcss from "tailwindcss";
import { elmReviewTailwindCssPlugin } from "../postcss/dist/index.js";
import tailwindConfig from "./tailwind.config.mjs";

export default {
  plugins: [
    tailwindcss(tailwindConfig),
    elmReviewTailwindCssPlugin({
      tailwindConfig,
    }),
  ],
};
