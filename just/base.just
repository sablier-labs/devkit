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

GLOBS_PRETTIER := "\"**/*.{md,mdx,yaml,yml}\""

# ---------------------------------------------------------------------------- #
#                                    RECIPES                                   #
# ---------------------------------------------------------------------------- #

# Clean files
[no-cd]
clean:
    just _clean ".DS_Store"
[no-cd]
_clean +globs:
    nlx del-cli "{{ globs }}"

# Clear node_modules recursively
[confirm("Are you sure you want to delete all node_modules, including in subdirectories? Y/n")]
[no-cd]
clean-modules +globs="node_modules **/node_modules":
    nlx del-cli {{ globs }}

# Install the Node.js dependencies; run with --frozen to install the dependencies with the frozen lockfile
[no-cd]
install *args:
    ni {{ args }}

# Build with TypeScript
[no-cd]
tsc-build project="tsconfig.json":
    na tsc -p {{ project }}
alias tb := tsc-build

# ---------------------------------------------------------------------------- #
#                                    CHECKS                                    #
# ---------------------------------------------------------------------------- #

# Check code with Biome
[group("checks")]
[no-cd]
@biome-check +globs=".":
    na biome check {{ globs }}
alias bc := biome-check

# Fix code with Biome
# The `noUnusedImports` rule is disabled by default to allow unused imports during development
[group("checks")]
[no-cd]
@biome-write +globs=".":
    na biome check --write {{ globs }}
    na biome lint --unsafe --write --only correctness/noUnusedImports {{ globs }}
alias bw := biome-write

# Run all code checks
[group("checks")]
[no-cd]
@full-check:
    just _run-with-status biome-check
    just _run-with-status prettier-check
    just _run-with-status tsc-check
    echo ""
    echo '{{ GREEN }}✓ All code checks passed!{{ NORMAL }}'
alias fc := full-check

# Run all code fixes
[group("checks")]
[no-cd]
@full-write:
    just _run-with-status biome-write
    just _run-with-status prettier-write
    echo ""
    echo '{{ GREEN }}✓ All code fixes applied!{{ NORMAL }}'
alias fw := full-write

# Run knip checks
[group("checks")]
[no-cd]
@knip-check:
    na knip
alias kc := knip-check

# Run knip fix
[group("checks")]
[no-cd]
@knip-write:
    na knip --fix
alias kw := knip-write

# Check Prettier formatting
[group("checks")]
[no-cd]
@prettier-check +globs=GLOBS_PRETTIER:
    na prettier --check --cache --no-error-on-unmatched-pattern {{ globs }}
alias pc := prettier-check

# Format using Prettier
[group("checks")]
[no-cd]
@prettier-write +globs=GLOBS_PRETTIER:
    na prettier --write --cache --no-error-on-unmatched-pattern {{ globs }}
alias pw := prettier-write

# Type check with TypeScript
[group("checks")]
[no-cd]
@tsc-check project="tsconfig.json":
    na tsc --noEmit --project {{ project }}
alias tc := tsc-check

# Private recipe to run a check with formatted output
[no-cd]
@_run-with-status recipe:
    echo ""
    echo '{{ CYAN }}→ Running {{ recipe }}...{{ NORMAL }}'
    just {{ recipe }}
    echo '{{ GREEN }}✓ {{ recipe }} completed{{ NORMAL }}'
alias rws := _run-with-status
