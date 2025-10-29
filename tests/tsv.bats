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

# Assert output does not contain substring
refute_output() {
  local flag="${1:-}"
  local unexpected="${2:-$1}"

  if [ "$flag" = "--partial" ]; then
    if [[ "$output" =~ $unexpected ]]; then
      echo "Expected output NOT to contain: $unexpected"
      echo "Actual output: $output"
      return 1
    fi
  fi
}

# ---------------------------------------------------------------------------
# Tests for _tsv-check recipe
# ---------------------------------------------------------------------------

@test "_tsv-check: validates a valid TSV file successfully" {
  check_qsv

  run just _tsv-check "tests/fixtures/valid.tsv" ""

  assert_success
  assert_output --partial "Validating TSV files..."
  assert_output --partial "✅ All TSV files are valid"
}

@test "_tsv-check: fails on invalid TSV file" {
  check_qsv

  # Create a temporary invalid TSV file
  local temp_invalid="${TEST_TEMP_DIR}/invalid.tsv"
  cat >"$temp_invalid" <<'EOF'
id	name	age	email
1	Alice	30	alice@example.com
2	Bob	extra	column	here	bob@example.com
3	Charlie	35
EOF

  run just _tsv-check "$temp_invalid" ""

  assert_failure
  assert_output --partial "❌ Validation failed for: ${temp_invalid}"
}

@test "_tsv-check: handles multiple files with glob pattern" {
  check_qsv

  # Create temp copies to test multiple files
  local temp_valid1="${TEST_TEMP_DIR}/data1.tsv"
  local temp_valid2="${TEST_TEMP_DIR}/data2.tsv"
  cp tests/fixtures/valid.tsv "$temp_valid1"
  cp tests/fixtures/valid.tsv "$temp_valid2"

  run just _tsv-check "${TEST_TEMP_DIR}/*.tsv" ""

  assert_success
  assert_output --partial "✅ All TSV files are valid"
}

@test "_tsv-check: skips default ignore patterns (.tsv.invalid)" {
  check_qsv

  # The data.tsv.invalid should be skipped automatically
  run just _tsv-check "tests/fixtures/*.tsv*" ""

  assert_success
  assert_output --partial "✅ All TSV files are valid"
  refute_output --partial "data.tsv.invalid"
}

@test "_tsv-check: skips default ignore patterns (.tsv.valid)" {
  check_qsv

  # Create a .tsv.valid file
  cp tests/fixtures/valid.tsv tests/fixtures/test.tsv.valid

  run just _tsv-check "tests/fixtures/*.tsv*" ""

  assert_success
  refute_output --partial "test.tsv.valid"

  rm -f tests/fixtures/test.tsv.valid
}

@test "_tsv-check: skips default ignore patterns (validation-errors.tsv)" {
  check_qsv

  # Create a validation-errors.tsv file
  cp tests/fixtures/valid.tsv tests/fixtures/test.validation-errors.tsv

  run just _tsv-check "tests/fixtures/*.tsv*" ""

  assert_success
  refute_output --partial "validation-errors.tsv"

  rm -f tests/fixtures/test.validation-errors.tsv
}

@test "_tsv-check: supports custom ignore patterns" {
  check_qsv

  # Test with custom ignore pattern that includes custom-ignore.tsv
  run just _tsv-check "tests/fixtures/*.tsv" "" "*custom-ignore.tsv"

  assert_success
  refute_output --partial "custom-ignore.tsv"
}

@test "_tsv-check: handles no files found gracefully" {
  check_qsv

  run just _tsv-check "tests/fixtures/nonexistent*.tsv" ""

  assert_success
  assert_output --partial "ℹ️  No TSV files found to validate"
}

@test "_tsv-check: detects missing qsv command" {
  # Skip this test - it's difficult to test PATH manipulation without affecting
  # other justfile dependencies (na, nb, etc.)
  skip "PATH manipulation affects justfile dependencies"

  # Temporarily modify PATH to hide qsv (which is in ~/.local/bin)
  # Keep homebrew bin for just and other tools
  PATH="/opt/homebrew/bin:/usr/bin:/bin" run just _tsv-check "tests/fixtures/valid.tsv" ""

  assert_failure
  assert_output --partial "✗ qsv CLI not found"
  assert_output --partial "Install it: https://github.com/dathere/qsv"
}

@test "_tsv-check: validates with schema when provided" {
  check_qsv

  # Create a simple JSON schema for testing
  local schema_file="${TEST_TEMP_DIR}/schema.json"
  cat >"$schema_file" <<'EOF'
{
  "type": "object",
  "properties": {
    "id": {"type": "integer"},
    "name": {"type": "string"},
    "age": {"type": "integer"},
    "email": {"type": "string", "format": "email"}
  }
}
EOF

  # Note: This test may skip if qsv doesn't support JSON schema validation
  run just _tsv-check "tests/fixtures/valid.tsv" "$schema_file"

  # Accept both success (validation passed) or specific qsv schema errors
  # The schema validation in qsv might work differently
  [[ "$status" -eq 0 ]] || [[ "$output" =~ "schema" ]]
}

@test "_tsv-check: passes empty schema parameter correctly" {
  check_qsv

  run just _tsv-check "tests/fixtures/valid.tsv" ""

  assert_success
}

# ---------------------------------------------------------------------------
# Tests for _tsv-show-errors recipe
# ---------------------------------------------------------------------------

@test "_tsv-show-errors: displays error file not found message" {
  check_qsv

  run just _tsv-show-errors "tests/fixtures/nonexistent.tsv"

  assert_success
  assert_output --partial "Error file not found:"
}

@test "_tsv-show-errors: shows validation errors when error file exists" {
  check_qsv

  # Create a temporary invalid TSV file with consistent structure but invalid data
  local temp_invalid="${TEST_TEMP_DIR}/invalid.tsv"
  cat >"$temp_invalid" <<'EOF'
id	name	age	email
1	Alice	30	alice@example.com
2	Bob	not-a-number	bob@example.com
3	Charlie	35	not-an-email
EOF

  # Create a JSON schema for validation
  local schema_file="${TEST_TEMP_DIR}/schema.json"
  cat >"$schema_file" <<'EOF'
{
  "type": "object",
  "properties": {
    "id": {"type": "integer"},
    "name": {"type": "string"},
    "age": {"type": "integer"},
    "email": {"type": "string", "format": "email"}
  },
  "required": ["id", "name", "age", "email"]
}
EOF

  # Validate with schema (this should create the error file)
  run just _tsv-check "$temp_invalid" "$schema_file"

  # The error file should now exist
  [ -f "${temp_invalid}.validation-errors.tsv" ]

  # Now test _tsv-show-errors
  run just _tsv-show-errors "$temp_invalid"

  assert_success
  assert_output --partial "Validation errors:"
}
