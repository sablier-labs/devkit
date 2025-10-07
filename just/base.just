import "./settings.just"

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #

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

# Install the Node.js dependencies; run with --frozen to install the dependencies with the frozen lockfile
[no-cd]
install *args:
    ni {{ args }}

# Build with TypeScript
[no-cd]
tsc-build:
    na tsc -p tsconfig.build.json

# ---------------------------------------------------------------------------- #
#                                     CHECK                                    #
# ---------------------------------------------------------------------------- #

# Check code with Biome
[group("checks")]
[no-cd]
biome-check paths=".":
    na biome check {{ paths }}
alias bc := biome-check

# Fix code with Biome
[group("checks")]
[no-cd]
biome-write paths=".":
    na biome check --write {{ paths }}
    na biome lint --unsafe --write --only correctness/noUnusedImports {{ paths }}
alias bw := biome-write

# Run all code checks
[group("checks")]
[no-cd]
full-check: biome-check prettier-check tsc-check
alias fc := full-check

# Run all code fixes
[group("checks")]
[no-cd]
full-write: biome-write prettier-write
alias fw := full-write

# Run knip checks
[group("checks")]
[no-cd]
knip-check:
    na knip
alias kc := knip-check

# Run knip fix
[group("checks")]
[no-cd]
knip-write:
    na knip --fix
alias kw := knip-write

# Check Prettier formatting
[group("checks")]
[no-cd]
prettier-check globs=GLOBS_PRETTIER:
    na prettier --check --cache "{{ globs }}"
alias pc := prettier-check

# Format using Prettier
[group("checks")]
[no-cd]
prettier-write globs=GLOBS_PRETTIER:
    na prettier --write --cache "{{ globs }}"
alias pw := prettier-write

# Type check with TypeScript
[group("checks")]
[no-cd]
tsc-check:
    na tsc --noEmit
