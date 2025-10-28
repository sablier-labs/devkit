# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[1.2.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.2.0
[1.1.3]: https://github.com/sablier-labs/devkit/releases/tag/v1.1.3
[1.1.2]: https://github.com/sablier-labs/devkit/releases/tag/v1.1.2
[1.1.1]: https://github.com/sablier-labs/devkit/releases/tag/v1.1.1
[1.1.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.1.0
[1.0.0]: https://github.com/sablier-labs/devkit/releases/tag/v1.0.0

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
