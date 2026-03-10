#!/bin/bash
set -e
set -u

# =============================================================================
# Claude Code Mastery — Installer
# Bootstraps a macOS/Linux development environment for the course.
# Compatible with bash 3.2 (macOS default) — no bash 4+ features.
# =============================================================================

# Configuration variables
STARTER_DEST="$HOME/Documents/claude-mastery-starter"
REPO_URL="https://github.com/jeystaats/claude-masterclass.git"
NVM_VERSION="v0.40.3"

# =============================================================================
# Logging functions
# =============================================================================

log_info()  { echo "[info]    $*"; }
log_skip()  { echo "[skip]    $*"; }
log_done()  { echo "[done]    $*"; }
log_error() { echo "[error]   $*" >&2; }
log_warn()  { echo "[warn]    $*"; }

# =============================================================================
# Utility functions
# =============================================================================

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

detect_os() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Darwin)
      if [ "$ARCH" = "arm64" ]; then
        BREW_PREFIX="/opt/homebrew"
      else
        BREW_PREFIX="/usr/local"
      fi
      ;;
    Linux)
      BREW_PREFIX=""
      ;;
    *)
      # Unsupported OS — handled in main()
      BREW_PREFIX=""
      ;;
  esac
}

# =============================================================================
# Install functions
# =============================================================================

install_homebrew() {
  if [ "$OS" = "Linux" ]; then
    log_info "Linux detected — Homebrew not required. Use apt/yum for system packages."
    return 0
  fi

  if command_exists brew; then
    log_skip "Homebrew already installed ($(brew --version | head -1))"
    return 0
  fi

  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Source Homebrew into current shell session immediately
  eval "$($BREW_PREFIX/bin/brew shellenv)"
  log_done "Homebrew installed"
}

install_git() {
  if command_exists git; then
    log_skip "git already installed ($(git --version))"
    return 0
  fi

  log_info "Installing git..."
  case "$OS" in
    Darwin)
      brew install git
      # Ensure Homebrew git takes precedence over Xcode CLT git
      eval "$($BREW_PREFIX/bin/brew shellenv)"
      ;;
    Linux)
      sudo apt-get install -y git 2>/dev/null || \
        sudo yum install -y git 2>/dev/null || {
          log_error "Could not install git. Please install manually and re-run."
          exit 1
        }
      ;;
  esac
  log_done "git installed ($(git --version))"
}

install_jq() {
  if command_exists jq; then
    log_skip "jq already installed ($(jq --version))"
    return 0
  fi

  log_info "Installing jq..."
  case "$OS" in
    Darwin)
      brew install jq
      ;;
    Linux)
      sudo apt-get install -y jq 2>/dev/null || \
        sudo yum install -y jq 2>/dev/null || {
          log_error "Could not install jq. Please install manually and re-run."
          exit 1
        }
      ;;
  esac
  log_done "jq installed ($(jq --version))"
}

install_nvm_and_node() {
  export NVM_DIR="$HOME/.nvm"

  # nvm is a shell function, not a binary — source it explicitly
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  if command_exists nvm; then
    log_skip "nvm already installed"
    log_info "Ensuring Node.js LTS is active..."
    nvm install --lts
    nvm use --lts
    nvm alias default "lts/*"
    return 0
  fi

  log_info "Installing nvm $NVM_VERSION..."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash

  # Source nvm immediately for current session
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  log_info "Installing Node.js LTS..."
  nvm install --lts
  nvm use --lts
  nvm alias default "lts/*"
  log_done "nvm and Node.js LTS installed"
}

install_pnpm() {
  if command_exists pnpm; then
    log_skip "pnpm already installed ($(pnpm --version))"
    return 0
  fi

  log_info "Installing pnpm..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -

  # Export PNPM_HOME and add to PATH for current session
  export PNPM_HOME="$HOME/.local/share/pnpm"
  export PATH="$PNPM_HOME:$PATH"
  log_done "pnpm installed"
}

install_claude_code() {
  if command_exists claude; then
    log_skip "Claude Code already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
    return 0
  fi

  log_info "Installing Claude Code CLI..."
  curl -fsSL https://claude.ai/install.sh | bash
  log_done "Claude Code installed"
  log_info "NEXT STEP: Run 'claude' and follow the browser prompts to authenticate."
}

# =============================================================================
# Clone function
# =============================================================================

clone_starter_kit() {
  if [ -d "$STARTER_DEST/.git" ]; then
    log_skip "Starter kit already cloned at $STARTER_DEST"
    return 0
  fi

  log_info "Cloning starter kit to $STARTER_DEST..."
  git clone "$REPO_URL" "$STARTER_DEST"
  log_done "Starter kit cloned to $STARTER_DEST"
}

# =============================================================================
# Main
# =============================================================================

main() {
  echo ""
  echo "=================================="
  echo "  Claude Code Mastery — Installer"
  echo "=================================="
  echo ""

  detect_os

  # Exit on unsupported OS
  if [ "$OS" != "Darwin" ] && [ "$OS" != "Linux" ]; then
    log_error "Unsupported OS: $OS"
    log_info  "Windows users: Install WSL2, then re-run this script inside WSL."
    log_info  "See: https://learn.microsoft.com/en-us/windows/wsl/install"
    exit 1
  fi

  install_homebrew
  install_git
  install_jq
  install_nvm_and_node
  install_pnpm
  install_claude_code
  clone_starter_kit
  # backup_and_merge will be added by Plan 03

  echo ""
  echo "=================================="
  echo "  Installation complete!"
  echo "=================================="
  echo ""
  log_info "Next steps:"
  log_info "  1. Run 'claude' to authenticate via browser"
  log_info "  2. cd $STARTER_DEST"
  log_info "  3. pnpm install"
  log_info "  4. pnpm dev"
  echo ""
}

main "$@"
