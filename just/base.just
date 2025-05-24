# See https://just.systems/man/en/imports.html?highlight=override#imports

set allow-duplicate-variables := true
set allow-duplicate-recipes := true
set shell := ["bash", "-euo", "pipefail", "-c"]

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #
# Ni: https://github.com/antfu-collective/ni
# Prettier: https://prettier.io
# ---------------------------------------------------------------------------- #
#                                   CONSTANTS                                  #
# ---------------------------------------------------------------------------- #

GLOBS_PRETTIER := "**/*.{json,json5,jsonc,md,yaml,yml}"

# ---------------------------------------------------------------------------- #
#                                    RECIPES                                   #
# ---------------------------------------------------------------------------- #

# Clean files
[no-cd]
clean +globs:
    nlx rimraf {{ globs }}

# Check Prettier formatting
[no-cd]
prettier-check globs=GLOBS_PRETTIER:
    na prettier --check --cache "{{ globs }}"

# Format using Prettier
[no-cd]
prettier-write globs=GLOBS_PRETTIER:
    na prettier --write --cache "{{ globs }}"
