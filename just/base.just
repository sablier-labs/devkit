set allow-duplicate-variables := true
set allow-duplicate-recipes := true
set shell := ["bash", "-euo", "pipefail", "-c"]

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

# Check code with Biome
[no-cd]
biome-check paths=".":
    na biome check {{ paths }}
alias bc := biome-check

# Fix code with Biome
[no-cd]
biome-write paths=".":
    na biome check --write {{ paths }}
    na biome lint --write --only correctness/noUnusedImports {{ paths }}
alias bw := biome-write

# Clean files
[no-cd]
clean +globs:
    nlx del-cli "{{ globs }}"

# Clear node_modules recursively
[confirm("Are you sure you want to delete all node_modules, including in subdirectories? y/n")]
[no-cd]
clean-modules:
    nlx del-cli "node_modules" "**/node_modules"

# Run all code checks
[no-cd]
full-check: biome-check prettier-check tsc-check
alias fc := full-check

# Run all code fixes
[no-cd]
full-write: biome-write prettier-write
alias fw := full-write

# Install the Node.js dependencies
install *args:
    ni install {{ args }}

# Install the Node.js dependencies without updating the lockfile
install-frozen:
    ni --frozen

# Check Prettier formatting
[no-cd]
prettier-check globs=GLOBS_PRETTIER:
    na prettier --check --cache "{{ globs }}"
alias pc := prettier-check

# Format using Prettier
[no-cd]
prettier-write globs=GLOBS_PRETTIER:
    na prettier --write --cache "{{ globs }}"
alias pw := prettier-write

# Type check with TypeScript
[no-cd]
tsc-check:
    na tsc --noEmit
