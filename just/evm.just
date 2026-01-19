import "./settings.just"

# See https://just.systems/man/en/modules1190.html
mod base


# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #

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
GLOBS_SOLIDITY := "{scripts,src,tests}/**/*.sol"

# ---------------------------------------------------------------------------- #
#                                    RECIPES                                   #
# ---------------------------------------------------------------------------- #

# Clean directories and files
clean globs=GLOBS_CLEAN:
    nlx del-cli {{ globs }}
alias c := clean

# Clear node_modules recursively
[confirm("Are you sure you want to delete all node_modules, including in subdirectories? Y/n")]
clean-modules:
    just base::clean-modules

# Run all code checks
full-check:
    just base::mdformat-check
    just solhint-check
    just fmt-check
    just prettier-check
alias fc := full-check

# Run all code fixes
full-write:
    just base::mdformat-write
    just solhint-write
    just fmt-write
    just prettier-write
alias fw := full-write

# Install the Node.js dependencies
install *args:
    just base::install {{ args }}
alias i := install

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
    na solhint --cache "{{ globs }}"
alias sc := solhint-check

# Fix code with Solhint
solhint-write globs=GLOBS_SOLIDITY:
    na solhint --cache --fix --noPrompt "{{ globs }}"
alias sw := solhint-write

# ---------------------------------------------------------------------------- #
#                                    FOUNDRY                                   #
# ---------------------------------------------------------------------------- #

# Build contracts
[group("foundry")]
build:
    forge build
alias b := build

# Build using optimized profile
[group("foundry")]
build-optimized:
    FOUNDRY_PROFILE=optimized \
        forge build
alias bo := build-optimized

# Build using optimized profile with optional arguments
[group("foundry")]
build-optimized *args:
    FOUNDRY_PROFILE=optimized \
        forge build --extra-output-files metadata {{ args }}

# Dump code coverage to an html file
[group("foundry"), script("bash")]
coverage:
    if ! command -v genhtml >/dev/null 2>&1; then
        echo "✗ genhtml CLI not found"
        echo "Install it with Homebrew: https://formulae.brew.sh/formula/lcov"
        exit 1
    fi
    forge coverage --report lcov
    genhtml --branch-coverage --ignore-errors inconsistent --output-dir coverage lcov.info
alias cov := coverage

# Check code with Forge formatter
[group("foundry")]
fmt-check:
    forge fmt --check

# Fix code with Forge formatter
[group("foundry")]
fmt-write:
    forge fmt

# Performs a gas report
[group("foundry")]
gas-report:
    forge test --gas-report
alias gr := gas-report

# Run tests with optional arguments
[group("foundry")]
test *args:
    forge test {{ args }}
alias t := test

# Run Bulloak checks
[group("foundry")]
test-bulloak:
    bulloak check --skip-modifiers "./tests/**/*.tree"
alias tb := test-bulloak

# Run tests using lite profile (skipping fork tests)
[group("foundry")]
test-lite:
    FOUNDRY_PROFILE=lite forge test --nmt "testFork"
alias tl := test-lite

# Run tests using lite profile with optional arguments
[group("foundry")]
test-lite *args:
    FOUNDRY_PROFILE=lite forge test {{ args }}

# Run tests using optimized profile
[group("foundry")]
test-optimized: build-optimized
    FOUNDRY_PROFILE=test-optimized forge test
alias to := test-optimized
