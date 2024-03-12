import plugin from "tailwindcss/plugin.js";

const someVariantPlugin = plugin(({ addVariant }) => {
  addVariant("bgd", ".bgd &");
});

/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.elm", "index.html"],
  darkMode: "class",
  plugins: [p],
  theme: {
    extend: {
      spacing: {
        "8xl": "96rem",
        "9xl": "128rem",
      },
    },
  },
};
