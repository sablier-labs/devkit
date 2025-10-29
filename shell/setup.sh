#!/usr/bin/env sh

# setup.sh ─────────────────────────────────────────────────────────
# Portable global tool installer for macOS (POSIX shell)
# Requirements:
#   - homebrew (https://brew.sh)
#   - node v20+
#
# Usage:
#   1. Clone & run locally:
#      git clone https://github.com/sablier-labs/devkit.git
#      cd devkit/shell
#      sh setup.sh
#      # Or make it executable:
#      chmod +x setup.sh
#      ./setup.sh
#
#   2. Directly from GitHub:
#      curl -fsSL https://raw.githubusercontent.com/sablier-labs/devkit/main/shell/setup.sh | sh

# Exit on error or undefined variable
set -eu

LOG_FILE="sablier_devkit_setup.log"

printf "Logging to %s\n" "$LOG_FILE"
# Redirect both stdout and stderr to log file
exec >>"$LOG_FILE" 2>&1

# Check if command exists
check_command() {
  cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "✓ %s is already installed\n" "$cmd"
    return 0
  else
    printf "✗ %s is not installed\n" "$cmd"
    return 1
  fi
}

# OS check
OS="$(uname -s)"
if [ "$OS" != "Darwin" ]; then
  printf "⚠️  Unsupported OS: %s. This script works only on macOS.\n" "$OS" 1>&2
  exit 1
fi

# Ensure Homebrew
if ! command -v brew >/dev/null 2>&1; then
  printf "Homebrew not found. Please install it: https://brew.sh\n" 1>&2
  exit 1
fi

# Check Node.js version
if ! command -v node >/dev/null 2>&1; then
  printf "✗ node is not installed. Install Node.js v20+ and rerun.\n" 1>&2
  exit 1
fi
NODE_VERSION="$(node -v)"
# Extract major version
NODE_MAJOR=$(printf "%s" "$NODE_VERSION" | sed -E 's/^v([0-9]+)\..*/\1/')
case "$NODE_MAJOR" in
'' | *[!0-9]*)
  printf "✗ Could not parse Node.js version: %s\n" "$NODE_VERSION" 1>&2
  exit 1
  ;;
*)
  if [ "$NODE_MAJOR" -lt 20 ]; then
    printf "✗ Node.js v20+ required (found %s)\n" "$NODE_VERSION" 1>&2
    exit 1
  else
    printf "✓ Node.js %s\n" "$NODE_VERSION"
  fi
  ;;
esac

# Installer functions
install_just() {
  if ! check_command just; then
    printf "Installing Just...\n"
    brew install just
  fi
}

install_bun() {
  if ! check_command bun; then
    printf "Installing Bun...\n"
    npm install -g bun
  fi
}

install_ni() {
  if ! check_command ni; then
    printf "Installing Ni...\n"
    npm install -g @antfu/ni
  fi
}

install_foundry() {
  if ! check_command forge; then
    printf "Installing Foundry...\n"
    curl -L https://foundry.paradigm.xyz | sh
    # ensure foundryup in PATH
    if command -v foundryup >/dev/null 2>&1; then
      foundryup
    fi
  fi
}

install_rust() {
  if ! check_command rustc; then
    printf "Installing Rust...\n"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    printf "To use Rust tools, ensure %s/.cargo/bin is in your PATH.\n" "$HOME"
  fi
}

install_bulloak() {
  if ! check_command bulloak; then
    printf "Installing Bulloak...\n"
    cargo install bulloak
  fi
}

# Main installation
printf "=== Starting installation ===\n"
install_bun
install_foundry
install_just
install_ni
install_rust
install_bulloak
printf "=== Installation complete! ===\n"
printf "Ensure your shell PATH includes npm globals and %s/.cargo/bin if not already.\n" "$HOME"
