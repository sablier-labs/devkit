/** @type {import("prettier").Config} */
export default {
  overrides: [
    {
      files: "*.md",
      options: {
        proseWrap: "always",
      },
    },
  ],
  printWidth: 120,
  trailingComma: "all",
};
