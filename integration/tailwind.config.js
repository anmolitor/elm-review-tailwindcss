/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.elm", "index.html"],
  theme: {
    extend: {
      spacing: {
        "8xl": "96rem",
        "9xl": "128rem",
      },
    },
  },
  plugins: [],
};
