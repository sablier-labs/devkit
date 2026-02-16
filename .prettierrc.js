/** @type {import("prettier").Config} */
export default {
  printWidth: 120,
  trailingComma: "all",
  overrides: [
    {
      files: "*.md",
      options: {
        proseWrap: "always",
      },
    },
  ],
};
