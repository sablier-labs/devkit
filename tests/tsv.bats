#!/usr/bin/env bats

# Load test helpers
load helpers

# ---------------------------------------------------------------------------
# Helper functions for assertions
# ---------------------------------------------------------------------------

# shellcheck disable=SC2030,SC2031

# Assert command succeeded
assert_success() {
  if [ "$status" -ne 0 ]; then
    echo "Expected success but got status: $status"
    echo "Output: $output"
    return 1
  fi
}

# Assert command failed
assert_failure() {
  if [ "$status" -eq 0 ]; then
    echo "Expected failure but got success"
    echo "Output: $output"
    return 1
  fi
}

# Assert output contains substring
assert_output() {
  local flag="${1:-}"
  local expected="${2:-$1}"

  if [ "$flag" = "--partial" ]; then
    if [[ ! "$output" =~ $expected ]]; then
      echo "Expected output to contain: $expected"
      echo "Actual output: $output"
      return 1
    fi
  else
    if [ "$output" != "$expected" ]; then
      echo "Expected output: $expected"
      echo "Actual output: $output"
      return 1
    fi
  fi
}

# ---------------------------------------------------------------------------
# Tests for TSV validation via _csv-check
# ---------------------------------------------------------------------------

@test "TSV validation validates valid TSV file" {
  check_qsv

  run just _csv-check --glob "tests/fixtures/valid.tsv"

  assert_success
  assert_output --partial "Validating .tsv files..."
  assert_output --partial "✅ All .tsv files are valid"
}

@test "TSV validation fails on invalid TSV file" {
  check_qsv

  local temp_invalid="${TEST_TEMP_DIR}/invalid.tsv"
  cat >"$temp_invalid" <<'EOF'
id	name	age	email
1	Alice	30	alice@example.com
2	Bob	extra	column	here	bob@example.com
EOF

  run just _csv-check --glob "${TEST_TEMP_DIR}/invalid.tsv"

  assert_failure
  assert_output --partial "❌ Validation failed for:"
}

@test "TSV validation handles no files gracefully" {
  check_qsv

  run just _csv-check --glob "tests/fixtures/nonexistent*.tsv"

  assert_success
  assert_output --partial "ℹ️  No .tsv files found to validate"
}

# ---------------------------------------------------------------------------
# Tests for _csv-show-errors with TSV files
# ---------------------------------------------------------------------------

@test "TSV show-errors displays error file not found" {
  check_qsv

  run just _csv-show-errors "tests/fixtures/nonexistent.tsv"

  assert_success
  assert_output --partial "Error file not found:"
}
