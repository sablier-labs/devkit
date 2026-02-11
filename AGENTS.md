# CLAUDE.md

Shared configuration library (`@sablier/devkit`) for Sablier repositories. Provides reusable Biome, Prettier, TypeScript,
Vitest, and Just configs, plus GitHub Actions and shell scripts.

## Project Structure

```
biome/          Biome v2 configs (base.jsonc, ui.jsonc)
just/           Just recipe modules (base, csv, evm, npm, settings, vercel)
tsconfig/       TypeScript presets (base, build, next)
vitest/         Vitest config factory (base.js)
actions/        GitHub Actions (setup, node-cache)
shell/          Setup scripts for Sablier Labs staff
vscode/         Shared VSCode settings
tests/          BATS tests for CSV/TSV validation
```

## Package Exports

```
@sablier/devkit/biome       → biome/base.jsonc
@sablier/devkit/biome/base  → biome/base.jsonc
@sablier/devkit/biome/ui    → biome/ui.jsonc
@sablier/devkit/prettier    → .prettierrc.js
@sablier/devkit/tsconfig/*  → tsconfig/{base,build,next}.json
@sablier/devkit/vitest      → vitest/base.js
```

## Commands

```bash
just full-check      # Run all checks (prettier, biome, shell)
just full-write      # Run all fixes
just shell-check     # ShellCheck + shfmt
just test            # Run all BATS tests
just test-csv        # Run CSV validation tests
just test-tsv        # Run TSV validation tests
```

## Tech Stack

- **Node.js** >= 20 (ESM)
- **Biome** v2 for linting/formatting JS/TS/JSON
- **Prettier** for Markdown, YAML
- **Just** as task runner
- **BATS** for shell testing
- **ShellCheck** + **shfmt** for shell script quality

## Conventions

- ESM-only (`"type": "module"` in package.json)
- Prettier config: `printWidth: 120`, `trailingComma: "all"`
- Biome formatter: `indentStyle: "space"`, `lineWidth: 100`
- Biome linting: recommended rules with customizations (see `biome/base.jsonc`)
- Just settings: `bash -euo pipefail`, `unstable` mode enabled
- Vitest factory (`defineDevkitConfig`) provides CI-aware defaults (retry, timeout, reporters)
