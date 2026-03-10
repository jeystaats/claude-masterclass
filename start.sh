#!/bin/bash
set -e
set -u

# Claude Code Mastery — Session Launcher
# Usage: bash start.sh [module-number]
# Compatible with bash 3.2 (macOS default) — no bash 4+ features.
#
# What it does:
#   1. Lists available modules (titles read from README.md)
#   2. Prompts for or accepts a module number
#   3. Resolves the module directory via zero-padded glob (self-healing)
#   4. Writes a session context file to modules/XX/.claude/session.md
#   5. Ensures modules/XX/.claude/CLAUDE.md imports @session.md
#   6. Launches Claude Code in the selected module directory

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# =============================================================================
# Logging functions (same style as install.sh)
# =============================================================================

log_info()  { echo "[info]    $*"; }
log_skip()  { echo "[skip]    $*"; }
log_done()  { echo "[done]    $*"; }
log_error() { echo "[error]   $*" >&2; }

# =============================================================================
# Prereq check
# =============================================================================

if ! command -v claude >/dev/null 2>&1; then
  log_error "Claude Code CLI not found. Run bash install.sh first."
  exit 1
fi

# =============================================================================
# Module listing
# =============================================================================

list_modules() {
  echo ""
  echo "  Claude Code Mastery — Module Selector"
  echo "  ────────────────────────────────────"
  echo ""
  local i=0
  for dir in "$MODULES_DIR"/[0-9][0-9]-*/; do
    [ -d "$dir" ] || continue
    i=$((i + 1))
    name=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^# //')
    printf "  %d. %s\n" "$i" "$name"
  done
  echo ""
}

# =============================================================================
# Progressive skill disclosure
# Mapping based on module learning objectives (Finding 6 from 04-RESEARCH.md)
# =============================================================================

get_skills_for_module() {
  case "$1" in
    1)
      printf '%s\n' \
        "- \`/lah-explain-code\` — Explain any code with analogies and step-by-step breakdowns"
      ;;
    2)
      printf '%s\n' \
        "- \`/lah-explain-code\` — Explain any code with analogies and step-by-step breakdowns" \
        "- \`/lah-plan-task\` — Decompose a task before writing any code"
      ;;
    3)
      printf '%s\n' \
        "- \`/lah-explain-code\` — Explain any code with analogies and step-by-step breakdowns" \
        "- \`/lah-plan-task\` — Decompose a task before writing any code" \
        "- \`/lah-commit-message\` — Write conventional commit messages automatically"
      ;;
    4)
      printf '%s\n' \
        "- \`/lah-plan-task\` — Decompose a task before writing any code" \
        "- \`/lah-explain-code\` — Explain any code with analogies and step-by-step breakdowns"
      ;;
    5)
      printf '%s\n' \
        "- \`/lah-explain-code\` — Explain any code with analogies and step-by-step breakdowns" \
        "- \`/lah-review-code\` — Review code for quality, style, and correctness"
      ;;
    6)
      printf '%s\n' \
        "- \`/lah-explain-code\` — Explain any code with analogies and step-by-step breakdowns" \
        "- \`/lah-commit-message\` — Write conventional commit messages automatically" \
        "- \`/lah-plan-task\` — Decompose a task before writing any code" \
        "- \`/lah-review-code\` — Review code for quality, style, and correctness" \
        "- \`/lah-debug-it\` — Systematic debugging with root cause analysis"
      ;;
    7)
      printf '%s\n' \
        "- \`/lah-commit-message\` — Write conventional commit messages automatically" \
        "- \`/lah-review-code\` — Review code for quality, style, and correctness" \
        "- \`/lah-debug-it\` — Systematic debugging with root cause analysis"
      ;;
    8|9)
      printf '%s\n' \
        "- \`/lah-explain-code\` — Explain any code with analogies and step-by-step breakdowns" \
        "- \`/lah-commit-message\` — Write conventional commit messages automatically" \
        "- \`/lah-plan-task\` — Decompose a task before writing any code" \
        "- \`/lah-review-code\` — Review code for quality, style, and correctness" \
        "- \`/lah-debug-it\` — Systematic debugging with root cause analysis"
      ;;
    *)
      printf '%s\n' \
        "- \`/lah-explain-code\` — Explain any code with analogies and step-by-step breakdowns" \
        "- \`/lah-commit-message\` — Write conventional commit messages automatically" \
        "- \`/lah-plan-task\` — Decompose a task before writing any code" \
        "- \`/lah-review-code\` — Review code for quality, style, and correctness" \
        "- \`/lah-debug-it\` — Systematic debugging with root cause analysis"
      ;;
  esac
}

get_agents_for_module() {
  case "$1" in
    1)
      printf '%s\n' \
        "- \`@lah-explainer\` — Explains concepts in plain language, no code writing"
      ;;
    2)
      printf '%s\n' \
        "- \`@lah-explainer\` — Explains concepts in plain language, no code writing" \
        "- \`@lah-planner\` — Architecture and task planning, no code writes"
      ;;
    3)
      printf '%s\n' \
        "- \`@lah-explainer\` — Explains concepts in plain language, no code writing" \
        "- \`@lah-planner\` — Architecture and task planning, no code writes" \
        "- \`@lah-code-reviewer\` — Reviews code for quality and correctness" \
        "- \`@lah-debugger\` — Systematic bug investigation and root cause analysis"
      ;;
    4)
      printf '%s\n' \
        "- \`@lah-planner\` — Architecture and task planning, no code writes"
      ;;
    5)
      printf '%s\n' \
        "- \`@lah-code-reviewer\` — Reviews code for quality and correctness" \
        "- \`@lah-explainer\` — Explains concepts in plain language, no code writing"
      ;;
    6|7|8|9)
      printf '%s\n' \
        "- \`@lah-explainer\` — Explains concepts in plain language, no code writing" \
        "- \`@lah-planner\` — Architecture and task planning, no code writes" \
        "- \`@lah-code-reviewer\` — Reviews code for quality and correctness" \
        "- \`@lah-debugger\` — Systematic bug investigation and root cause analysis"
      ;;
    *)
      printf '%s\n' \
        "- \`@lah-explainer\` — Explains concepts in plain language, no code writing" \
        "- \`@lah-planner\` — Architecture and task planning, no code writes" \
        "- \`@lah-code-reviewer\` — Reviews code for quality and correctness" \
        "- \`@lah-debugger\` — Systematic bug investigation and root cause analysis"
      ;;
  esac
}

# =============================================================================
# Session context writer
# Writes to modules/XX/.claude/session.md — never touches CLAUDE.md
# =============================================================================

write_session_context() {
  local module_num="$1"
  local module_dir="$2"
  local module_title="$3"
  local session_file="$module_dir/.claude/session.md"
  local today
  today=$(date "+%Y-%m-%d %H:%M")
  local skills
  skills=$(get_skills_for_module "$module_num")
  local agents
  agents=$(get_agents_for_module "$module_num")
  local workdir
  workdir=$(basename "$module_dir")

  mkdir -p "$module_dir/.claude"

  cat > "$session_file" << HEREDOC
<!-- SESSION: written by start.sh — do not edit manually -->
<!-- Module: ${module_num} | Started: ${today} -->

## Your Session Context

You are helping a student working on **Module ${module_num}: ${module_title}**.

**Working directory:** ${workdir}/

## Skills available this module

${skills}

## Agents available this module

${agents}
HEREDOC

  log_done "Session context written to $(basename "$module_dir")/.claude/session.md"
}

# =============================================================================
# Ensure @session.md is imported in the module's CLAUDE.md
# Never overwrites existing CLAUDE.md — only appends if needed
# =============================================================================

ensure_session_import() {
  local module_dir="$1"
  local claude_md="$module_dir/.claude/CLAUDE.md"

  mkdir -p "$module_dir/.claude"

  if [ ! -f "$claude_md" ]; then
    echo "@session.md" > "$claude_md"
    log_done "Created $(basename "$module_dir")/.claude/CLAUDE.md"
  elif ! grep -q "@session.md" "$claude_md"; then
    echo "" >> "$claude_md"
    echo "@session.md" >> "$claude_md"
    log_done "Added @session.md import to $(basename "$module_dir")/.claude/CLAUDE.md"
  else
    log_skip "@session.md already imported"
  fi
}

# =============================================================================
# Main
# =============================================================================

# --- Argument handling ---
if [ $# -ge 1 ]; then
  MODULE_NUM="$1"
else
  list_modules
  printf "  Module [1-9]: "
  read -r MODULE_NUM
fi

# --- Validate input is a digit 1-9 ---
case "$MODULE_NUM" in
  [1-9]) ;;
  *)
    log_error "Invalid module number: $MODULE_NUM. Enter a number 1-9."
    exit 1
    ;;
esac

# --- Resolve module directory via zero-padded glob ---
NUM_PADDED=$(printf '%02d' "$MODULE_NUM")
MODULE_DIR=$(ls -d "$MODULES_DIR/${NUM_PADDED}-"* 2>/dev/null | head -1)

if [ -z "$MODULE_DIR" ]; then
  log_error "Module $MODULE_NUM not found in $MODULES_DIR"
  exit 1
fi

# --- Extract module title from README.md ---
# Strip leading "# " and also optional "Module XX: " prefix so we get just the title
MODULE_TITLE=$(head -1 "$MODULE_DIR/README.md" 2>/dev/null | sed 's/^# //' | sed 's/^Module [0-9]*: //')
if [ -z "$MODULE_TITLE" ]; then
  MODULE_TITLE="Module $MODULE_NUM"
fi

# --- Write session context ---
log_info "Preparing session for: $MODULE_TITLE"
write_session_context "$MODULE_NUM" "$MODULE_DIR" "$MODULE_TITLE"
ensure_session_import "$MODULE_DIR"

# --- Launch Claude Code ---
log_info "Launching Claude Code in modules/${NUM_PADDED}-*/ ..."
echo ""
cd "$MODULE_DIR" && exec claude
