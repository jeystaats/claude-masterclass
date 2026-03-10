#!/bin/bash
set -e
set -u

# Claude Code Mastery — Environment Installer
# https://github.com/jeystaats/claude-masterclass
#
# Usage: bash install.sh
#
# This script installs: Homebrew (macOS), Git, jq, nvm, Node.js LTS,
# pnpm, and Claude Code CLI. It backs up existing ~/.claude/ config
# and merges workshop settings without destroying existing hooks.
#
# Safe to re-run — all steps are idempotent.

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
# Backup and merge functions
# =============================================================================

backup_claude_config() {
  if [ ! -d "$HOME/.claude" ]; then
    log_skip "No ~/.claude/ directory to back up"
    return 0
  fi

  local timestamp
  timestamp=$(date +%Y%m%d-%H%M%S)
  local backup_dir="$HOME/.claude/backup-${timestamp}"

  cp -r "$HOME/.claude/" "$backup_dir/"
  # Remove nested backups from the new backup to save space
  find "$backup_dir" -maxdepth 1 -name "backup-*" -type d -exec rm -rf {} + 2>/dev/null || true
  log_done "Backed up ~/.claude/ -> ${backup_dir}"
}

merge_settings() {
  local script_dir
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  local incoming="${script_dir}/config/workshop-settings.json"
  local existing="$HOME/.claude/settings.json"

  if [ ! -f "$incoming" ]; then
    log_skip "No workshop settings to merge (config/workshop-settings.json not found)"
    return 0
  fi

  mkdir -p "$HOME/.claude"

  if [ ! -f "$existing" ]; then
    cp "$incoming" "$existing"
    log_done "Created ~/.claude/settings.json from workshop template"
    return 0
  fi

  local tmp
  tmp=$(mktemp)
  jq -s '
    def deep_merge(a; b):
      if (a|type) == "object" and (b|type) == "object" then
        reduce ((a|keys) + (b|keys) | unique)[] as $k ({};
          .[$k] = deep_merge(a[$k]; b[$k])
        )
      elif (a|type) == "array" and (b|type) == "array" then
        (a + b | unique)
      elif b == null then a
      else b
      end;
    deep_merge(.[0]; .[1])
  ' "$existing" "$incoming" > "$tmp" && mv "$tmp" "$existing"
  log_done "Merged workshop settings into ~/.claude/settings.json"
}

# =============================================================================
# Main
# =============================================================================

install_global_config() {
  local script_dir
  script_dir="$(cd "$(dirname "$0")" && pwd)"

  # --- Skills ---
  if [ -d "$script_dir/global-config/skills" ]; then
    mkdir -p "$HOME/.claude/skills"
    for skill_dir in "$script_dir/global-config/skills"/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_name
      skill_name=$(basename "$skill_dir")
      local dest="$HOME/.claude/skills/$skill_name"
      if [ -d "$dest" ]; then
        log_skip "Skill already installed: $skill_name"
      else
        cp -r "$skill_dir" "$dest"
        log_done "Installed skill: $skill_name"
      fi
    done
  fi

  # --- Agents ---
  if [ -d "$script_dir/global-config/agents" ]; then
    mkdir -p "$HOME/.claude/agents"
    for agent_file in "$script_dir/global-config/agents"/*.md; do
      [ -f "$agent_file" ] || continue
      local agent_name
      agent_name=$(basename "$agent_file")
      local dest="$HOME/.claude/agents/$agent_name"
      if [ -f "$dest" ]; then
        log_skip "Agent already installed: $agent_name"
      else
        cp "$agent_file" "$dest"
        log_done "Installed agent: $agent_name"
      fi
    done
  fi

  # --- Hooks ---
  if [ -d "$script_dir/global-config/hooks" ]; then
    mkdir -p "$HOME/.claude/hooks"
    for hook_file in "$script_dir/global-config/hooks"/lah-*.sh; do
      [ -f "$hook_file" ] || continue
      local hook_name
      hook_name=$(basename "$hook_file")
      local dest="$HOME/.claude/hooks/$hook_name"
      if [ -f "$dest" ]; then
        log_skip "Hook already installed: $hook_name"
      else
        cp "$hook_file" "$dest"
        chmod +x "$dest"
        log_done "Installed hook: $hook_name"
      fi
    done
  fi
}

append_claude_md_snippet() {
  local script_dir
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  local snippet="$script_dir/global-config/CLAUDE.md.snippet"
  local target="$HOME/.claude/CLAUDE.md"

  if [ ! -f "$snippet" ]; then
    log_skip "No CLAUDE.md.snippet found"
    return 0
  fi

  mkdir -p "$HOME/.claude"

  # Idempotent: skip if delimiter already present
  if [ -f "$target" ] && grep -q "LAH-COURSE-START" "$target"; then
    log_skip "CLAUDE.md course section already present"
    return 0
  fi

  # Add a newline separator if file exists and is non-empty
  if [ -f "$target" ] && [ -s "$target" ]; then
    echo "" >> "$target"
  fi

  cat "$snippet" >> "$target"
  log_done "Appended course section to ~/.claude/CLAUDE.md"
}

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

  log_info "Configuring Claude Code settings..."
  backup_claude_config
  merge_settings

  log_info "Installing course skills, agents, and hooks..."
  install_global_config
  append_claude_md_snippet

  echo ""
  echo "=================================="
  echo "  All done!"
  echo "=================================="
  echo ""
  echo "  Installed into ~/.claude/:"
  echo "  ✓ 13 agents  (orchestrator, frontend/backend leads, creative, specialists)"
  echo "  ✓ 5 skills   (/breakdown, /plan, /commit, /review, /debug)"
  echo "  ✓ 5 hooks    (TypeScript, React, cn(), file size, secrets)"
  echo ""
  echo "  Your workspace: $STARTER_DEST"
  echo ""

  # Check if already authenticated — if so, launch directly
  # claude --version exits 0 and shows version, so we check for a running config
  if command_exists claude; then
    echo "  Opening your workspace in Claude Code..."
    echo "  (If this is your first time, you'll be prompted to log in with your Anthropic account)"
    echo ""
    cd "$STARTER_DEST"
    log_info "Installing project dependencies..."
    pnpm install --silent 2>/dev/null || pnpm install
    echo ""
    echo "  Tip: Tell Claude which module you're working on and it will guide you."
    echo "  Tip: Run 'bash start.sh' for a step-by-step module exercise guide."
    echo ""
    exec claude
  else
    log_info "Run these commands to get started:"
    log_info "  cd $STARTER_DEST"
    log_info "  pnpm install"
    log_info "  claude"
    echo ""
  fi
}

main "$@"
