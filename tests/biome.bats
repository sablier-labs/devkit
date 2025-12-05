#!/usr/bin/env bats

# Tests to verify ui.jsonc contains all base.jsonc features

load helpers

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

# Get biome rage output for a config
get_rage() {
  local config="$1"
  biome rage --formatter --linter --config-path="biome/${config}"
}

# Extract formatter section from rage output
get_formatter_section() {
  echo "$1" | sed -n '/^Formatter:/,/^JavaScript Formatter:/p' | sed '$d'
}

# Extract enabled rules from rage output
get_enabled_rules() {
  echo "$1" | sed -n '/Enabled rules:/,/Disabled rules:/p' | grep '^\s\+[a-z]' | sort
}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

@test "ui.jsonc contains all base formatter settings" {
  base_rage=$(get_rage "base.jsonc")
  ui_rage=$(get_rage "ui.jsonc")

  base_formatter=$(get_formatter_section "$base_rage")
  ui_formatter=$(get_formatter_section "$ui_rage")

  # Extract non-unset values from base
  while IFS= read -r line; do
    # Skip lines with "unset" or empty lines
    if [[ "$line" =~ unset ]] || [[ -z "$line" ]]; then
      continue
    fi
    # Verify this setting exists in ui with same value
    if ! echo "$ui_formatter" | grep -qF "$line"; then
      echo "Missing or different in ui.jsonc: $line"
      return 1
    fi
  done <<<"$base_formatter"
}

@test "ui.jsonc contains all base linter rules" {
  base_rage=$(get_rage "base.jsonc")
  ui_rage=$(get_rage "ui.jsonc")

  base_rules=$(get_enabled_rules "$base_rage")
  ui_rules=$(get_enabled_rules "$ui_rage")

  # Verify each base rule exists in ui
  while IFS= read -r rule; do
    [[ -z "$rule" ]] && continue
    if ! echo "$ui_rules" | grep -qF "$rule"; then
      echo "Missing rule in ui.jsonc: $rule"
      return 1
    fi
  done <<<"$base_rules"
}

@test "ui.jsonc has linter enabled" {
  ui_rage=$(get_rage "ui.jsonc")
  echo "$ui_rage" | grep -q "Linter enabled:.*true"
}

@test "ui.jsonc has formatter enabled" {
  ui_rage=$(get_rage "ui.jsonc")
  echo "$ui_rage" | grep -q "Formatter enabled:.*true"
}

@test "ui.jsonc has VCS enabled" {
  ui_rage=$(get_rage "ui.jsonc")
  echo "$ui_rage" | grep -q "VCS enabled:.*true"
}
