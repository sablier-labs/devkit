#!/usr/bin/env bash

# Test helpers for TSV validation tests

# Setup function - runs before each test
setup() {
    # Create a temporary directory for test outputs
    TEST_TEMP_DIR="$(mktemp -d)"
    export TEST_TEMP_DIR

    # Store original working directory
    ORIGINAL_DIR="$(pwd)"
    export ORIGINAL_DIR
}

# Teardown function - runs after each test
teardown() {
    # Clean up validation error files in fixtures directory
    rm -f tests/fixtures/*.validation-errors.tsv
    rm -f tests/fixtures/*.tsv.valid
    rm -f tests/fixtures/*.tsv.invalid

    # Clean up temp directory if it exists
    if [ -n "${TEST_TEMP_DIR:-}" ] && [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi

    # Return to original directory
    if [ -n "${ORIGINAL_DIR:-}" ]; then
        cd "$ORIGINAL_DIR" || true
    fi
}

# Check if qsv is available
check_qsv() {
    if ! command -v qsv >/dev/null 2>&1; then
        skip "qsv not installed (install: https://github.com/dathere/qsv)"
    fi
}

# Copy fixture to temp directory
copy_fixture() {
    local fixture_name="$1"
    local dest="${TEST_TEMP_DIR}/${fixture_name}"
    cp "tests/fixtures/${fixture_name}" "$dest"
    echo "$dest"
}
