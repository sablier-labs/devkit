set allow-duplicate-variables := true
set allow-duplicate-recipes := true
set shell := ["bash", "-euo", "pipefail", "-c"]
set unstable

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #

# Jq
jq := require("jq")

# Ni: https://github.com/antfu-collective/ni
na := require("na")
ni := require("ni")
nlx := require("nlx")

# ---------------------------------------------------------------------------- #
#                                   CONSTANTS                                  #
# ---------------------------------------------------------------------------- #

GLOBS_PRETTIER := "**/*.{md,mdx,yaml,yml}"

# ---------------------------------------------------------------------------- #
#                                    RECIPES                                   #
# ---------------------------------------------------------------------------- #

# Clean files
[no-cd]
clean +globs:
    nlx del-cli "{{ globs }}"

# Clear node_modules recursively
[confirm("Are you sure you want to delete all node_modules, including in subdirectories? y/n")]
[no-cd]
clean-modules:
    nlx del-cli "node_modules" "**/node_modules"

# Install the Node.js dependencies
[no-cd]
install *args:
    ni {{ args }}

# Install the Node.js dependencies without updating the lockfile
[no-cd]
install-frozen:
    ni --frozen

# Build with TypeScript
[no-cd]
tsc-build:
    na tsc -p tsconfig.build.json

# ---------------------------------------------------------------------------- #
#                                    PUBLISH                                   #
# ---------------------------------------------------------------------------- #

# Publish the npm package, e.g. v1.0.0
[group("publish")]
publish *args:
  npm publish {{ args }}
  @just tag $(jq -r '.version' package.json)

# Publish using the `beta` tag, e.g. v1.0.0-beta.1
[group("publish")]
publish-beta *args:
  @just check-beta-version
  npm publish --tag beta {{ args }}

# Tag the new version
[group("publish")]
tag *version:
  git tag -am "{{ version }}" {{ version }}
  git push origin --tags

# ---------------------------------------------------------------------------- #
#                                     LINT                                     #
# ---------------------------------------------------------------------------- #

# Check code with Biome
[group("lint")]
[no-cd]
biome-check paths=".":
    na biome check {{ paths }}
alias bc := biome-check

# Fix code with Biome
[group("lint")]
[no-cd]
biome-write paths=".":
    na biome check --write {{ paths }}
    na biome lint --unsafe --write --only correctness/noUnusedImports {{ paths }}
alias bw := biome-write

# Run all code checks
[group("lint")]
[no-cd]
full-check: biome-check prettier-check tsc-check
alias fc := full-check

# Run all code fixes
[group("lint")]
[no-cd]
full-write: biome-write prettier-write
alias fw := full-write

# Run knip checks
[group("lint")]
[no-cd]
knip-check:
    na knip
alias kc := knip-check

# Run knip fix
[group("lint")]
[no-cd]
knip-write:
    na knip --fix
alias kw := knip-write

# Check Prettier formatting
[group("lint")]
[no-cd]
prettier-check globs=GLOBS_PRETTIER:
    na prettier --check --cache "{{ globs }}"
alias pc := prettier-check

# Format using Prettier
[group("lint")]
[no-cd]
prettier-write globs=GLOBS_PRETTIER:
    na prettier --write --cache "{{ globs }}"
alias pw := prettier-write

# Type check with TypeScript
[group("lint")]
[no-cd]
tsc-check:
    na tsc --noEmit

# ---------------------------------------------------------------------------- #
#                                PRIVATE HELPERS                               #
# ---------------------------------------------------------------------------- #


# Check that package.json version includes -beta.x suffix
[private]
[script]
@check-beta-version:
  # Extract version from package.json using jq for reliable JSON parsing
  version=$(jq -r '.version' package.json)

  # Check if version contains -beta suffix
  if [[ "$version" =~ -beta\.[0-9]+$ ]]; then
    echo "✓ Version $version includes beta suffix"
  else
    echo "✗ Error: Version $version does not include -beta.x suffix"
    echo "Please update package.json version to include -beta.x (e.g., 1.0.0-beta.1)"
    exit 1
  fi
