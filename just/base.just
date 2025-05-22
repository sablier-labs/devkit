# See https://just.systems/man/en/imports.html?highlight=override#imports
set allow-duplicate-variables := true
set allow-duplicate-recipes := true

# ---------------------------------------------------------------------------- #
#                                  ENVIRONMENT                                 #
# ---------------------------------------------------------------------------- #

# Bun is the default package manager. The user can override this by setting the
# PM environment variable.
export PM := "bun"

# ---------------------------------------------------------------------------- #
#                                   VARIABLES                                  #
# ---------------------------------------------------------------------------- #

globs_prettier := "**/*.{json,json5,jsonc,md,yaml,yml}"

# ---------------------------------------------------------------------------- #
#                                    RECIPES                                   #
# ---------------------------------------------------------------------------- #

# Clean files
_clean +globs:
    rm -rf {{ globs }}

# Check Prettier formatting
_prettier-check globs=globs_prettier:
    {{ PM }} prettier --cache --check "{{ globs }}"

# Format using Prettier
_prettier-write globs=globs_prettier:
    {{ PM }} prettier --cache --write "{{ globs }}"
