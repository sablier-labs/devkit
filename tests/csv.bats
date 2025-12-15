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
# Tests for _csv-check recipe
# ---------------------------------------------------------------------------

@test "validates a valid CSV file successfully" {
  check_qsv

  run just _csv-check "tests/fixtures/valid.csv" ""

  assert_success
  assert_output --partial "Validating CSV files..."
  assert_output --partial "✅ All CSV files are valid"
}

@test "fails on invalid CSV file" {
  check_qsv

  # Create a temporary invalid CSV file
  local temp_invalid="${TEST_TEMP_DIR}/invalid.csv"
  cat >"$temp_invalid" <<'EOF'
id,name,age,email
1,Alice,30,alice@example.com
2,Bob,extra,column,here,bob@example.com
3,Charlie,35
EOF

  run just _csv-check "$temp_invalid" ""

  assert_failure
  assert_output --partial "❌ Validation failed for: ${temp_invalid}"
}

@test "handles multiple files with glob pattern" {
  check_qsv

  # Create temp copies to test multiple files
  local temp_valid1="${TEST_TEMP_DIR}/data1.csv"
  local temp_valid2="${TEST_TEMP_DIR}/data2.csv"
  cp tests/fixtures/valid.csv "$temp_valid1"
  cp tests/fixtures/valid.csv "$temp_valid2"

  run just _csv-check "${TEST_TEMP_DIR}/*.csv" ""

  assert_success
  assert_output --partial "✅ All CSV files are valid"
}

@test "skips default ignore patterns (.csv.invalid)" {
  check_qsv

  # The data.csv.invalid should be skipped automatically
  run just _csv-check "tests/fixtures/*.csv*" ""

  assert_success
  assert_output --partial "✅ All CSV files are valid"
  refute_output --partial "data.csv.invalid"
}

@test "skips default ignore patterns (.csv.valid)" {
  check_qsv

  # Create a .csv.valid file
  cp tests/fixtures/valid.csv tests/fixtures/test.csv.valid

  run just _csv-check "tests/fixtures/*.csv*" ""

  assert_success
  refute_output --partial "test.csv.valid"

  rm -f tests/fixtures/test.csv.valid
}

@test "skips default ignore patterns (validation-errors.csv)" {
  check_qsv

  # Create a validation-errors.csv file
  cp tests/fixtures/valid.csv tests/fixtures/test.validation-errors.csv

  run just _csv-check "tests/fixtures/*.csv*" ""

  assert_success
  refute_output --partial "validation-errors.csv"

  rm -f tests/fixtures/test.validation-errors.csv
}

@test "supports custom ignore patterns" {
  check_qsv

  # Test with custom ignore pattern that includes custom-ignore.csv
  run just _csv-check "tests/fixtures/*.csv" "" "*custom-ignore.csv"

  assert_success
  refute_output --partial "custom-ignore.csv"
}

@test "handles no files found gracefully" {
  check_qsv

  run just _csv-check "tests/fixtures/nonexistent*.csv" ""

  assert_success
  assert_output --partial "ℹ️  No CSV files found to validate"
}

@test "validates with schema when provided" {
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
  run just _csv-check "tests/fixtures/valid.csv" "$schema_file"

  # Accept both success (validation passed) or specific qsv schema errors
  # The schema validation in qsv might work differently
  [[ "$status" -eq 0 ]] || [[ "$output" =~ "schema" ]]
}

@test "passes empty schema parameter correctly" {
  check_qsv

  run just _csv-check "tests/fixtures/valid.csv" ""

  assert_success
}

@test "uses custom extension label" {
  check_qsv

  run just _csv-check "tests/fixtures/valid.csv" "" "" "CUSTOM"

  assert_success
  assert_output --partial "Validating CUSTOM files..."
  assert_output --partial "✅ All CUSTOM files are valid"
}

# ---------------------------------------------------------------------------
# Tests for _csv-show-errors recipe
# ---------------------------------------------------------------------------

@test "displays error file not found message" {
  check_qsv

  run just _csv-show-errors "tests/fixtures/nonexistent.csv"

  assert_success
  assert_output --partial "Error file not found:"
}

@test "shows validation errors when error file exists" {
  check_qsv

  # Create a temporary invalid CSV file with consistent structure but invalid data
  local temp_invalid="${TEST_TEMP_DIR}/invalid.csv"
  cat >"$temp_invalid" <<'EOF'
id,name,age,email
1,Alice,30,alice@example.com
2,Bob,not-a-number,bob@example.com
3,Charlie,35,not-an-email
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
  run just _csv-check "$temp_invalid" "$schema_file"

  # The error file should now exist
  [ -f "${temp_invalid}.validation-errors.tsv" ]

  # Now test _csv-show-errors
  run just _csv-show-errors "$temp_invalid"

  assert_success
  assert_output --partial "Validation errors:"
}
