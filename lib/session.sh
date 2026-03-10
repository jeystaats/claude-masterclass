#!/bin/bash
# lib/session.sh — Session context functions for start.sh
# Source this file: source "$(dirname "$0")/lib/session.sh"
# Compatible with bash 3.2 (macOS default) — no bash 4+ features.
# shellcheck shell=bash
#
# Functions defined here:
#   get_skills_for_module  <module_num>              → markdown bullet list of skills
#   get_agents_for_module  <module_num>              → markdown bullet list of agents
#   write_session_context  <module_num> <module_dir> <module_title>  → writes session.md
#   ensure_session_import  <module_dir>              → idempotent @session.md in CLAUDE.md
#
# Progressive disclosure mapping (SESS-03):
#   Module 1: 1 skill,  1 agent
#   Module 2: 2 skills, 2 agents
#   Module 3: 3 skills, 3 agents
#   Module 4: 4 skills, 4 agents
#   Modules 5-9: all 5 skills, all 4 agents

# ---------------------------------------------------------------------------
# get_skills_for_module <module_num>
#
# Accepts a module number 1-9 (NOT zero-padded, e.g. pass "4" not "04").
# Prints a newline-separated markdown bullet list of skills available for
# that module. Each line has the slash command and a short description.
# ---------------------------------------------------------------------------
get_skills_for_module() {
  local module_num="$1"
  # Strip any leading zero so numeric comparison works (e.g. "04" -> "4")
  module_num="${module_num#0}"

  case "$module_num" in
    1)
      printf '%s\n' \
        '- `/lah-explain-code`   -- Explain any code with analogies and step-by-step breakdowns'
      ;;
    2)
      printf '%s\n' \
        '- `/lah-explain-code`   -- Explain any code with analogies and step-by-step breakdowns' \
        '- `/lah-commit-message` -- Write conventional commit messages from staged changes'
      ;;
    3)
      printf '%s\n' \
        '- `/lah-explain-code`   -- Explain any code with analogies and step-by-step breakdowns' \
        '- `/lah-commit-message` -- Write conventional commit messages from staged changes' \
        '- `/lah-plan-task`      -- Decompose a task into steps before writing any code'
      ;;
    4)
      printf '%s\n' \
        '- `/lah-explain-code`   -- Explain any code with analogies and step-by-step breakdowns' \
        '- `/lah-commit-message` -- Write conventional commit messages from staged changes' \
        '- `/lah-plan-task`      -- Decompose a task into steps before writing any code' \
        '- `/lah-review-code`    -- Review code for quality, patterns, and improvements'
      ;;
    5|6|7|8|9)
      printf '%s\n' \
        '- `/lah-explain-code`   -- Explain any code with analogies and step-by-step breakdowns' \
        '- `/lah-commit-message` -- Write conventional commit messages from staged changes' \
        '- `/lah-plan-task`      -- Decompose a task into steps before writing any code' \
        '- `/lah-review-code`    -- Review code for quality, patterns, and improvements' \
        '- `/lah-debug-it`       -- Diagnose errors with structured root cause analysis'
      ;;
    *)
      # Unknown module -- return all skills as a safe fallback
      printf '%s\n' \
        '- `/lah-explain-code`   -- Explain any code with analogies and step-by-step breakdowns' \
        '- `/lah-commit-message` -- Write conventional commit messages from staged changes' \
        '- `/lah-plan-task`      -- Decompose a task into steps before writing any code' \
        '- `/lah-review-code`    -- Review code for quality, patterns, and improvements' \
        '- `/lah-debug-it`       -- Diagnose errors with structured root cause analysis'
      ;;
  esac
}

# ---------------------------------------------------------------------------
# get_agents_for_module <module_num>
#
# Accepts a module number 1-9 (NOT zero-padded).
# Prints a newline-separated markdown bullet list of agents available for
# that module. Each line has the @mention and a short description.
# ---------------------------------------------------------------------------
get_agents_for_module() {
  local module_num="$1"
  # Strip any leading zero so numeric comparison works
  module_num="${module_num#0}"

  case "$module_num" in
    1)
      printf '%s\n' \
        '- `@lah-explainer`     -- Explains code and concepts, never writes new code'
      ;;
    2)
      printf '%s\n' \
        '- `@lah-explainer`     -- Explains code and concepts, never writes new code' \
        '- `@lah-planner`       -- Plans architecture and tasks, never edits files'
      ;;
    3)
      printf '%s\n' \
        '- `@lah-explainer`     -- Explains code and concepts, never writes new code' \
        '- `@lah-planner`       -- Plans architecture and tasks, never edits files' \
        '- `@lah-code-reviewer` -- Reviews code for quality and patterns'
      ;;
    4|5|6|7|8|9)
      printf '%s\n' \
        '- `@lah-explainer`     -- Explains code and concepts, never writes new code' \
        '- `@lah-planner`       -- Plans architecture and tasks, never edits files' \
        '- `@lah-code-reviewer` -- Reviews code for quality and patterns' \
        '- `@lah-debugger`      -- Diagnoses errors and proposes targeted fixes'
      ;;
    *)
      # Unknown module -- return all agents as a safe fallback
      printf '%s\n' \
        '- `@lah-explainer`     -- Explains code and concepts, never writes new code' \
        '- `@lah-planner`       -- Plans architecture and tasks, never edits files' \
        '- `@lah-code-reviewer` -- Reviews code for quality and patterns' \
        '- `@lah-debugger`      -- Diagnoses errors and proposes targeted fixes'
      ;;
  esac
}

# ---------------------------------------------------------------------------
# write_session_context <module_num> <module_dir> <module_title>
#
# Creates <module_dir>/.claude/session.md with session context for Claude.
# module_num   -- zero-padded number as used in the directory name (e.g. "04")
# module_dir   -- absolute path to the module directory
# module_title -- human-readable title (e.g. "Plan Your Product")
# ---------------------------------------------------------------------------
write_session_context() {
  # Provide a log_done fallback for standalone/test usage.
  # When sourced into start.sh, start.sh's log_done takes precedence.
  command -v log_done >/dev/null 2>&1 || log_done() { echo "[done]    $*"; }

  local module_num="$1"
  local module_dir="$2"
  local module_title="$3"
  local session_file="$module_dir/.claude/session.md"
  local start_date
  start_date=$(date "+%Y-%m-%d %H:%M")

  mkdir -p "$module_dir/.claude"

  cat > "$session_file" << HEREDOC
<!-- SESSION: written by start.sh -- do not edit manually -->
<!-- Module: ${module_num} | Started: ${start_date} -->

## Your Session Context

You are helping a student working on **Module ${module_num}: ${module_title}**.

**Working directory:** $(basename "$module_dir")/

## Skills available this module

$(get_skills_for_module "${module_num}")
## Agents available this module

$(get_agents_for_module "${module_num}")
HEREDOC

  log_done "Session context written to $(basename "$module_dir")/.claude/session.md"
}

# ---------------------------------------------------------------------------
# ensure_session_import <module_dir>
#
# Idempotently ensures that <module_dir>/.claude/CLAUDE.md imports @session.md.
# - If CLAUDE.md does not exist, creates it with "@session.md" as the sole line.
# - If CLAUDE.md exists but lacks @session.md, appends the import.
# - If CLAUDE.md already contains @session.md, does nothing (skip).
# ---------------------------------------------------------------------------
ensure_session_import() {
  # Provide log_done / log_skip fallbacks for standalone/test usage.
  command -v log_done >/dev/null 2>&1 || log_done() { echo "[done]    $*"; }
  command -v log_skip >/dev/null 2>&1 || log_skip() { echo "[skip]    $*"; }

  local module_dir="$1"
  local claude_md="$module_dir/.claude/CLAUDE.md"

  mkdir -p "$module_dir/.claude"

  if [ ! -f "$claude_md" ]; then
    echo "@session.md" > "$claude_md"
    log_done "Created $(basename "$module_dir")/.claude/CLAUDE.md with @session.md import"
  elif ! grep -q "@session.md" "$claude_md"; then
    printf '\n@session.md\n' >> "$claude_md"
    log_done "Added @session.md import to $(basename "$module_dir")/.claude/CLAUDE.md"
  else
    log_skip "$(basename "$module_dir")/.claude/CLAUDE.md already imports session.md"
  fi
}
