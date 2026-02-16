# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[1.13.2]: https://github.com/sablier-labs/devkit/releases/tag/v1.13.2
[1.13.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.13.1
[1.13.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.13.0
[1.12.3]: https://github.com/sablier-labs/devkit/releases/tag/v1.12.3
[1.12.2]: https://github.com/sablier-labs/devkit/releases/tag/v1.12.2
[1.12.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.12.1
[1.12.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.12.0
[1.11.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.11.0
[1.10.3]: https://github.com/sablier-labs/devkit/releases/tag/v1.10.3
[1.10.2]: https://github.com/sablier-labs/devkit/releases/tag/v1.10.2
[1.10.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.10.1
[1.10.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.10.0
[1.9.2]: https://github.com/sablier-labs/devkit/releases/tag/v1.9.2
[1.9.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.9.1
[1.9.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.9.0
[1.8.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.8.1
[1.8.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.8.0
[1.7.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.7.0
[1.6.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.6.1
[1.6.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.6.0
[1.5.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.5.1
[1.5.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.5.0
[1.4.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.4.1
[1.4.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.4.0
[1.3.5]: https://github.com/sablier-labs/devkit/releases/tag/v1.3.5
[1.3.4]: https://github.com/sablier-labs/devkit/releases/tag/v1.3.4
[1.3.3]: https://github.com/sablier-labs/devkit/releases/tag/v1.3.3
[1.3.2]: https://github.com/sablier-labs/devkit/releases/tag/v1.3.2
[1.3.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.3.1
[1.3.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.3.0
[1.2.4]: https://github.com/sablier-labs/devkit/releases/tag/v1.2.4
[1.2.3]: https://github.com/sablier-labs/devkit/releases/tag/v1.2.3
[1.2.2]: https://github.com/sablier-labs/devkit/releases/tag/v1.2.2
[1.2.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.2.1
[1.2.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.2.0
[1.1.3]: https://github.com/sablier-labs/devkit/releases/tag/v1.1.3
[1.1.2]: https://github.com/sablier-labs/devkit/releases/tag/v1.1.2
[1.1.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.1.1
[1.1.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.1.0
[1.0.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.0.0

## [1.13.2] - 2026-02-16

### Changed

- Just: Extract Vercel env resolution into shared `_vercel_helpers.py` module

## [1.13.1] - 2026-02-11

### Changed

- Just: Rename Vercel aliases `b` and `d` to `vb` and `vd`

## [1.13.0] - 2026-02-11

### Added

- Just: Add Vercel module with `build` and `deploy` recipes for Vercel deployment workflows

## [1.12.3] - 2026-02-08

### Changed

- Biome: Disable `useExhaustiveDependencies` in UI config due to React Compiler incompatibility

## [1.12.2] - 2026-01-20

### Fixed

- Just: Specify Python 3.14 for mdformat installation

## [1.12.1] - 2026-01-20

### Fixed

- Just: Fix glob brace expansion in `_csv-check` recipe

## [1.12.0] - 2026-01-20

### Added

- Just: Add mdformat recipes

## [1.11.0] - 2026-01-18

### Changed

- Just: Quiet `clean-modules` and `install` recipes by prefixing with `@`
- Just: Make `publish` recipe's tag creation opt-in via `--tag` flag instead of automatic

### Added

- Prettier: Export JavaScript config as `./prettier` entry point

## [1.10.3] - 2026-01-18

### Changed

- TSConfig: Add `inlineSources` to build config for self-contained sourcemaps

## [1.10.2] - 2026-01-12

### Changed

- Biome: Enable JSON comments and trailing commas in parser to override Ultracite defaults

## [1.10.1] - 2026-01-08

### Changed

- Biome: Disable `useSimplifiedLogicExpression` rule to prevent AI agents from getting stuck in refactoring loops

## [1.10.0] - 2026-01-02

### Changed

- Biome: Disable `noEnum` rule to allow enums for specific use cases (e.g., UI states)

### Added

- Just: Add CLI-style flag arguments to recipes for improved discoverability via `just --list`
  - `tsc-build`: `-p/--project` for tsconfig path
  - `type-check`: `-c/--compiler` for TypeScript compiler, `-p/--project` for tsconfig path
  - `_csv-check`: `-g/--glob`, `-s/--schema`, `-x/--ignore` for validation options

## [1.9.2] - 2025-12-26

### Added

- Biome: Enable `useConsistentTypeDefinitions` rule to enforce `type` keyword over `interface` for type definitions

## [1.9.1] - 2025-12-16

### Changed

- Infer file extension from glob pattern in CSV/TSV validation messages instead of hardcoding "CSV/TSV"

## [1.9.0] - 2025-12-16

### Changed

- Refactored CSV/TSV validation recipes to use extension-agnostic glob patterns, appending the extension at runtime

## [1.8.1] - 2025-12-16

### Fixed

- Use lowercase labels ("csv"/"tsv") and correct error file extension (`.tsv`) in CSV validation recipes

## [1.8.0] - 2025-12-16

### Changed

- Refactored `_csv-check` and `_csv-show-errors` just recipes from bash to inline Python scripts for improved
  maintainability
- Updated `_tsv-check` recipe parameter order to align with `_csv-check` signature

## [1.7.0] - 2025-12-15

### Changed

- Refactored `biome/ui.jsonc` to be a minimal extension config instead of standalone
  - Consumers must now extend both `@sablier/devkit/biome/base` and `@sablier/devkit/biome/ui`
- Generalized TSV validation to support CSV files via new `_csv-check` and `_csv-show-errors` recipes
  - TSV recipes now wrap the CSV recipes with TSV-specific defaults
- Use `Boolean()` constructor over double negation in vitest config

### Added

- Biome: Add rules to resolve conflicts with [Ultracite](https://github.com/haydenbleasel/ultracite) preset
  - Enable `recommended` rules explicitly
  - Disable `noVoid`, `noBarrelFile`, `noDelete`, `noNamespaceImport`, and `useDefaultSwitchClause` rules
  - Enforce filename conventions with `useFilenamingConvention` rule (kebab-case, camelCase, PascalCase, export)
  - Configure JSON formatter line width to 100 characters
  - Add inline documentation comments for rule configurations
- Biome: Enable `useSortedAttributes` in UI config for consistent attribute ordering

### Removed

- Remove `useExhaustiveDependencies` because Ultracite covers it

## [1.6.1] - 2025-12-12

### Fixed

- Convert vitest config from TypeScript to JavaScript for npm compatibility
- Remove deprecated `UserConfig` type annotation

## [1.6.0] - 2025-12-11

### Changed

- Set `noEmit` to `true` in `tsconfig/base.json`

### Added

- Vitest config factory with CI-aware defaults (`defineDevkitConfig`)
  - Configurable environment: `node` (default), `jsdom`, `happy-dom`
  - Optional setup files and coverage
  - CI detection for retry count, timeout, and reporter selection
- Re-export `mergeConfig` from vitest for combining configs

## [1.5.1] - 2025-12-05

### Changed

- Consolidated Just recipe attributes to single-line format for improved readability
- Improved `prettier-check` and `prettier-write` recipes with multi-line formatting and added `--log-level warn` flag
- Simplified `clean-modules` default glob from `node_modules **/node_modules` to `**/node_modules`
- Added explicit `script("bash")` to shell script recipes for clarity

## [1.5.0] - 2025-11-29

### Added

- New `type-check` recipe that uses `tsgo` by default with automatic fallback to `tsc` if unavailable
  - Added `tc` alias for `type-check` and `tsc-check` alias for backward compatibility

## [1.4.1] - 2025-11-25

### Changed

- Make `biome/ui.jsonc` a standalone configuration with expanded linter rules for CSS/Tailwind

## [1.4.0] - 2025-11-25

### Changed

- Restructured Biome configuration: moved from root `biome.jsonc` to `biome/base.jsonc`
  - This is a backward-compatible change because we export the new `biome/base.jsonc` configuration as `./biome`
- Change default `lineWidth` to 100 characters

### Added

- New Bioem config with UI-specific Biome configuration including a11y rules and Tailwind CSS support

## [1.3.5] - 2025-11-17

### Added

- Pass-through `*args` to `_run-with-status` helper recipe for improved flexibility

## [1.3.4] - 2025-11-17

### Added

- CSS modules support in Biome CSS parser configuration

## [1.3.3] - 2025-11-07

### Changed

- Remove glob parameter quoting in check recipes to restore original behavior

## [1.3.2] - 2025-11-06

### Fixed

- Quote glob parameters in check recipes to properly handle paths with special characters

## [1.3.1] - 2025-11-06

### Added

- Cache flag to `solhint-write` recipe for improved linting performance

## [1.3.0] - 2025-11-02

### Changed

- Simplified success messages in `full-check` and `full-write` recipes by removing checkmark emoji

### Added

- New `biome-lint` recipe with `bl` alias for running Biome linter separately from checker

## [1.2.4] - 2025-10-29

### Changed

- Refactored `tsv-check` recipe to extract error display logic into separate `_tsv-show-errors` recipe for better
  maintainability
- Made file ignore patterns configurable via `ignore` parameter in `_tsv-check` recipe (defaults to
  `*.tsv.invalid|*.tsv.valid|*validation-errors.tsv`)

## [1.2.3] - 2025-10-28

### Added

- Tailwind CSS directives support in Biome CSS parser configuration

## [1.2.2] - 2025-10-28

### Changed

- Remove superfluous `@` prefix from `_run-with-status` helper recipe

## [1.2.1] - 2025-10-28

### Changed

- Refactored check recipes for cleaner output with `_run-with-status` helper recipe
- Made check recipes quieter by prefixing with `@` to suppress command echoing

### Added

- Added `project` parameter to `tsc-build` recipe for better flexibility (defaults to `tsconfig.json`)
- Added command aliases: `tb` (tsc-build), `tc` (tsc-check)

## [1.2.0] - 2025-10-28

### Added

- Enhanced `full-check` recipe with colored output and progress indicators for better visibility during check execution
- Improved error reporting in `tsv-check` with detailed validation error display (first 20 errors with total count)

### Changed

- Removed `precompiles` from default Solidity glob patterns in `evm.just`

### Fixed

- Schema argument handling in `tsv-check` to properly validate TSV files with optional schemas

## [1.1.3] - 2025-10-21

### Added

- Support for `--no-error-on-unmatched-pattern` flag in `prettier-check` and `prettier-write` recipes to prevent errors
  when glob patterns don't match any files

## [1.1.2] - 2025-10-20

### Fixed

- Removed unnecessary quotes from glob template variables in `prettier-check` and `prettier-write` recipes

## [1.1.1] - 2025-10-20

### Changed

- Improved `tsc-check` recipe to use `project` parameter instead of `globs`
- Renamed parameters from `paths` to `globs` in `biome-check` and `biome-write` recipes, for consistency
- Runtime dependency validation in `tsv-check

### Fixed

- Corrected quoting for `GLOBS_PRETTIER` constant to properly handle glob patterns

## [1.1.0] - 2025-10-15

### Changed

- Minor formatting improvements in the Just modules

### Added

- Just module with TSV validation
- Private `_clean` function in `base.just`

### Fixed

- Variadic arguments handling in `base.just`

## [1.0.0] - 2025-10-11

### Added

- Initial release with configuration files for Biome, Prettier, and TypeScript
- Reusable Just CLI modules for common development tasks: base, evm, npm
- GitHub Actions setup workflow
- VSCode settings
