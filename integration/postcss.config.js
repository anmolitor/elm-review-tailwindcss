import tailwindcss from "tailwindcss";
import { elmReviewTailwindCssPlugin } from "../postcss/src/index.js";
import tailwindConfig from "./tailwind.config.js";

export default {
  plugins: [
    tailwindcss("./tailwind.config.js"),
    elmReviewTailwindCssPlugin({
      tailwindConfig,
    }),
  ],
};
