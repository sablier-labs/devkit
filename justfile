import "./just/base.just"

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #

# ShellCheck: https://github.com/koalaman/shellcheck
shellcheck := require("shellcheck")

# shfmt: https://github.com/mvdan/sh
shfmt := require("shfmt")

# ---------------------------------------------------------------------------- #
#                                   CONSTANTS                                  #
# ---------------------------------------------------------------------------- #

GLOBS_SHELL := ```
    shopt -s globstar nullglob
    arr=(
        **/*.bats
        **/*.sh
    )
    echo "${arr[@]}"
```

# ---------------------------------------------------------------------------- #
#                                    SCRIPTS                                   #
# ---------------------------------------------------------------------------- #

[group("checks")]
@full-check:
    just _run-with-status prettier-check
    just _run-with-status biome-check
    just _run-with-status shell-check
    echo ""
    echo '{{ GREEN }}✓ All code checks passed!{{ NORMAL }}'

@full-write:
    just _run-with-status prettier-write
    just _run-with-status biome-write
    just _run-with-status shell-write
    echo ""
    echo '{{ GREEN }}✓ All code fixes applied!{{ NORMAL }}'

# Check shell scripts with ShellCheck and shfmt
[group("checks")]
@shell-check:
    shellcheck -x {{ GLOBS_SHELL }}
    shfmt -d {{ GLOBS_SHELL }}

# Format shell scripts with shfmt
[group("checks")]
@shell-write:
    shfmt -w {{ GLOBS_SHELL }}

# Run TSV validation tests using BATS
[group("tests")]
test-tsv:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! command -v bats >/dev/null 2>&1; then
        echo "✗ BATS not installed"
        echo "Install it:"
        echo "  macOS:  brew install bats-core"
        echo "  Linux:  apt install bats (or use package manager)"
        echo "  GitHub: https://github.com/bats-core/bats-core"
        exit 1
    fi

    echo "Running TSV validation tests..."
    bats tests/tsv.bats

# Run all tests
[group("tests")]
test-all: test-tsv

# Alias for running all tests
[group("tests")]
test: test-all
