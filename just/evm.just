
# See https://just.systems/man/en/modules1190.html
mod base

set allow-duplicate-recipes := true
set allow-duplicate-variables := true
set shell := ["bash", "-euo", "pipefail", "-c"]

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #

# Bulloak: https://github.com/foundry-rs/bulloak
na := require("bulloak")
# Foundry: https://getfoundry.sh
forge := require("forge")
# Ni: https://github.com/antfu-collective/ni
na := require("na")
nlx := require("nlx")

# ---------------------------------------------------------------------------- #
#                                   CONSTANTS                                  #
# ---------------------------------------------------------------------------- #

GLOBS_CLEAN := ```
    arr=(
        "artifacts"
        "artifacts-*"
        "broadcast"
        "cache"
        "cache_hardhat-zk"
        "coverage"
        "docs"
        "out"
        "out-*"
        "typechain-types"
        "lcov.info"
    )
    echo "${arr[*]}"
```
GLOBS_PRETTIER := "**/*.{md,mdx,yaml,yml}"
GLOBS_SOLIDITY := "{precompiles,scripts,src,tests}/**/*.sol"

# ---------------------------------------------------------------------------- #
#                                    RECIPES                                   #
# ---------------------------------------------------------------------------- #

# Build contracts
build:
    forge build

# Build using optimized profile
build-optimized:
    FOUNDRY_PROFILE=optimized forge build

# Build using optimized profile with optional arguments
build-optimized *args:
    FOUNDRY_PROFILE=optimized forge build {{ args }}

# Build with SMT profile
build-smt:
    FOUNDRY_PROFILE=smt forge build

# Clean directories and files
@clean globs=GLOBS_CLEAN:
    just base:clean "{{ globs }}"

# Clean directories and files
clean globs=GLOBS_CLEAN:
    nlx del-cli "{{ globs }}"

# Check code with Forge formatter
forge-check:
    forge fmt --check

# Fix code with Forge formatter
forge-write:
    forge fmt

# Run all code checks
full-check: solhint-check forge-check prettier-check
alias fc := full-check

# Run all code fixes
full-write: solhint-write forge-write prettier-write
alias fw := full-write

# Install the Node.js dependencies
install *args:
    just base::install {{ args }}

# Install the Node.js dependencies without updating the lockfile
install-frozen:
    just base::install-frozen

# Check Prettier formatting
@prettier-check globs=GLOBS_PRETTIER:
    just base::prettier-check "{{ globs }}"
alias pc := prettier-check

# Format using Prettier
@prettier-write globs=GLOBS_PRETTIER:
    just base::prettier-write "{{ globs }}"
alias pw := prettier-write

# Check code with Solhint
solhint-check globs=GLOBS_SOLIDITY:
    na solhint "{{ globs }}"
alias sc := solhint-check

# Fix code with Solhint
solhint-write globs=GLOBS_SOLIDITY:
    na solhint --fix --noPrompt "{{ globs }}"
alias sw := solhint-write

# Run all tests
test:
    forge test

# Run tests with optional arguments
test *args:
    forge test {{ args }}

# Run Bulloak checks
test-bulloak:
    bulloak check --skip-modifiers "./tests/**/*.tree"

# Run tests using lite profile (skipping fork tests)
test-lite:
    FOUNDRY_PROFILE=lite forge test --nmt "testFork"

# Run tests using lite profile with optional arguments
test-lite *args:
    FOUNDRY_PROFILE=lite forge test {{ args }}

# Run tests using optimized profile
test-optimized: build-optimized
    FOUNDRY_PROFILE=test-optimized forge test
