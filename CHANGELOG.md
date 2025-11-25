# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
