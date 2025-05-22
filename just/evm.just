import "./base.just"

# ---------------------------------------------------------------------------- #
#                                  ENVIRONMENT                                 #
# ---------------------------------------------------------------------------- #

# Bun is the default package manager. The user can override this by setting the
# PM environment variable.
export PM := "bun"

# ---------------------------------------------------------------------------- #
#                                   VARIABLES                                  #
# ---------------------------------------------------------------------------- #

globs_clean := "artifacts artifacts-* cache cache_hardhat-zk coverage docs out out-* typechain-types lcov.info"
globs_prettier := "**/*.{json,md,yaml,yml}"
globs_solidity := "{precompiles,scripts,src,tests}/**/*.sol"

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
@clean globs=globs_clean:
    @just _clean "{{ globs }}"

# Check files using Forge formatter
forge-check:
    forge fmt --check

# Run Forge formatter
forge-write:
    forge fmt

# Run all checks
full-check: solhint-check forge-check prettier-check

# Run all formatters
full-write: solhint-write forge-write prettier-write

# Install the Node.js dependencies
install *ARGS:
    {{ PM }} install {{ ARGS }}

# Check Prettier formatting
@prettier-check globs=globs_prettier:
    just _prettier-check "{{ globs }}"

# Format using Prettier
@prettier-write globs=globs_prettier:
    just _prettier-write "{{ globs }}"

# Check Solidity linting
solhint-check globs=globs_solidity:
    {{ PM }} solhint "{{ globs }}"

# Fix Solidity linting issues
solhint-write globs=globs_solidity:
    {{ PM }} solhint --fix --noPrompt "{{ globs }}"

# Run all tests
test:
    forge test

# Run Bulloak tests
test-bulloak:
    bulloak check --skip-modifiers "./tests/**/*.tree"

# Run lite tests (skip fork tests)
test-lite:
    FOUNDRY_PROFILE=lite forge test --no-match-test "testFork"

# Run tests with optimized profile
test-optimized: build-optimized
    FOUNDRY_PROFILE=test-optimized forge test
