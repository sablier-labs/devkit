# 🛠️ Sablier Devkit

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![npm](https://img.shields.io/npm/v/@sablier/devkit)](https://www.npmjs.com/package/@sablier/devkit)

Configuration files and reusable scripts for Sablier repositories. Designed to be extended and customized as needed.

## 📦 Installation

```bash
npm install @sablier/devkit
```

Or with other package managers:

```bash
pnpm add @sablier/devkit
bun add @sablier/devkit
```

## 🚀 Usage

### Biome

Extend the base Biome configuration in your `biome.jsonc`:

```jsonc
{
  "$schema": "https://biomejs.dev/schemas/latest/schema.json",
  "extends": ["@sablier/devkit/biome"],
}
```

For UI projects, use the UI variant:

```jsonc
{
  "extends": ["@sablier/devkit/biome/ui"],
}
```

### Prettier

Reference the Prettier config in your `package.json`:

```json
{
  "prettier": "@sablier/devkit/prettier"
}
```

### TypeScript

Extend TSConfig presets in your `tsconfig.json`:

```json
{
  "extends": "@sablier/devkit/tsconfig/base"
}
```

Available presets:

- `@sablier/devkit/tsconfig/base` — Base TypeScript configuration
- `@sablier/devkit/tsconfig/build` — Build-optimized configuration
- `@sablier/devkit/tsconfig/next` — Next.js configuration

### Vitest

Use the devkit vitest config factory in your `vitest.config.ts`:

```typescript
import { defineDevkitConfig } from "@sablier/devkit/vitest";

export default defineDevkitConfig({
  environment: "jsdom", // or "node" (default), "happy-dom"
  setupFiles: ["./tests/setup.ts"],
  coverage: true,
});
```

The config provides CI-aware defaults:

- `globals: true`
- `retry: 2` in CI, `0` locally
- `testTimeout: 30s` in CI, `10s` locally
- `reporters: ["basic"]` in CI, `["verbose"]` locally

For merging with existing Vite configs:

```typescript
import { defineDevkitConfig, mergeConfig } from "@sablier/devkit/vitest";
import { defineConfig } from "vitest/config";

export default mergeConfig(
  defineDevkitConfig({ environment: "jsdom" }),
  defineConfig({
    test: {
      alias: { "@": "./src" },
    },
  }),
);
```

### Just

Import Just recipes in your `justfile`:

```just
import "@sablier/devkit/just/base.just"
import "@sablier/devkit/just/npm.just"
```

Available modules:

| Module          | Description                     |
| --------------- | ------------------------------- |
| `base.just`     | Common development recipes      |
| `csv.just`      | CSV/TSV validation with qsv     |
| `evm.just`      | EVM/Foundry tooling             |
| `npm.just`      | NPM package management          |
| `settings.just` | Just settings and configuration |
| `vercel.just`   | Vercel build and deploy         |

## ⚙️ Available Configs

| Tool            | Config File/Directory                    |
| --------------- | ---------------------------------------- |
| 🔍 Biome        | [`biome/`](./biome/)                     |
| 🛠 Just         | [`just/`](./just/)                       |
| ✨ Prettier     | [`.prettierrc.json`](./.prettierrc.json) |
| 📦 TSConfig     | [`tsconfig/`](./tsconfig/)               |
| 🧪 Vitest       | [`vitest/`](./vitest/)                   |
| 💻 VSCode       | [`vscode/`](./vscode/)                   |

## 🐈‍⬛ GitHub Actions

Reusable composite actions for GitHub CI workflows.

| Action                                    | Description                              |
| ----------------------------------------- | ---------------------------------------- |
| [`actions/setup`](./actions/setup/)       | Install dependencies (Node.js, Just, etc.) |
| [`actions/node-cache`](./actions/node-cache/) | Cache Node.js dependencies               |

```yaml
- uses: sablier-labs/devkit/actions/setup@main
```

## 🖥️ Setup Script

For Sablier Labs employees and staff, see [`shell/setup.sh`](./shell/setup.sh).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under MIT — see the [LICENSE](LICENSE.md) file for details.
