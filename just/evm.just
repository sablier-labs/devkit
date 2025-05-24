mod base

set shell := ["bash", "-euo", "pipefail", "-c"]

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #
# Bulloak: https://github.com/foundry-rs/bulloak
# Forge: https://getfoundry.sh
# Ni: https://github.com/antfu-collective/ni
# Prettier: https://prettier.io
# Solhint: https://protofire.github.io/solhint
# ---------------------------------------------------------------------------- #
#                                   CONSTANTS                                  #
# ---------------------------------------------------------------------------- #

GLOBS_CLEAN := ```
    arr=(
        "artifacts"
        "artifacts-*"
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
GLOBS_PRETTIER := "**/*.{json,md,yaml,yml}"
GLOBS_SOLIDITY := "{precompiles,scripts,src,tests}/**/*.sol"

# ---------------------------------------------------------------------------- #
#                                    RECIPES                                   #
# ---------------------------------------------------------------------------- #

# Build contracts
build:
    forge build

# Build with optimized profile
build-optimized:
    FOUNDRY_PROFILE=optimized forge build

# Build with SMT profile
build-smt:
    FOUNDRY_PROFILE=smt forge build

# Clean directories and files
@clean globs=GLOBS_CLEAN:
    just base:clean "{{ globs }}"

# Check code with Forge formatter
forge-check:
    forge fmt --check

# Fix code with Forge formatter
forge-write:
    forge fmt

# Run all code checks
full-check: solhint-check forge-check prettier-check

# Run all code fixes
full-write: solhint-write forge-write prettier-write

# Install the Node.js dependencies
install:
    ni

# Install the Node.js dependencies without updating the lockfile
install-frozen:
    ni --frozen

# Check Prettier formatting
@prettier-check globs=GLOBS_PRETTIER:
    just base::prettier-check "{{ globs }}"

# Format using Prettier
@prettier-write globs=GLOBS_PRETTIER:
    just base::prettier-write "{{ globs }}"

# Check code with Solhint
solhint-check globs=GLOBS_SOLIDITY:
    na solhint "{{ globs }}"

# Fix code with Solhint
solhint-write globs=GLOBS_SOLIDITY:
    na solhint --fix --noPrompt "{{ globs }}"

# Run all tests
test:
    forge test

# Run Bulloak checks
test-bulloak:
    bulloak check --skip-modifiers "./tests/**/*.tree"

# Run tests with lite profile (skipping fork tests)
test-lite:
    FOUNDRY_PROFILE=lite forge test --no-match-test "testFork"

# Run tests with optimized profile
test-optimized: build-optimized
    FOUNDRY_PROFILE=test-optimized forge test
