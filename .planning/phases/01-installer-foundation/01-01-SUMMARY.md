---
phase: 01-installer-foundation
plan: 01
subsystem: infra
tags: [bash, installer, homebrew, nvm, nodejs, pnpm, claude-code, shellcheck]

# Dependency graph
requires: []
provides:
  - "install.sh — idempotent macOS/Linux bootstrapper for Homebrew, git, jq, nvm, Node.js LTS, pnpm, Claude Code CLI, and starter kit clone"
affects: [01-02, 01-03]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "guard-check-install: every tool wrapped in command_exists() check before install"
    - "immediate PATH propagation: eval brew shellenv / source nvm.sh / export PNPM_HOME after each install"
    - "nvm-as-function: nvm sourced explicitly in script because it is a shell function, not a binary"
    - "no bash 4+: no declare -A, no ${var,,}, targets bash 3.2 (macOS default)"

key-files:
  created:
    - "install.sh — root-level installer script, executable, 241 lines"
  modified: []

key-decisions:
  - "install_jq() included in 01-01 (not 01-03) because jq is a prerequisite for the settings.json merge in Plan 03"
  - "nvm-as-function detection: guard uses command_exists nvm after sourcing nvm.sh, not before — avoids false-negative when nvm.sh exists but has not been sourced"
  - "Claude Code install guarded with command_exists claude to avoid known lock file bug (GitHub #13599)"
  - "No bash 4+ features: script targets bash 3.2 (macOS ships 3.2 due to GPLv3); verified with shellcheck"

patterns-established:
  - "Pattern: Every install function follows guard → log_info → install → log_done structure"
  - "Pattern: log_* functions use bracketed prefix labels ([info], [skip], [done], [error], [warn]) for scannable output"

# Metrics
duration: 2min
completed: 2026-03-10
---

# Phase 01 Plan 01: Installer Foundation Summary

**Idempotent bash installer for macOS/Linux that bootstraps Homebrew, git, jq, nvm, Node.js LTS, pnpm, and Claude Code CLI with skip-if-present guards on every step**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-03-10T19:21:09Z
- **Completed:** 2026-03-10T19:22:33Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Created `install.sh` with 7 install/clone functions, all idempotent
- Added OS detection for macOS (Apple Silicon + Intel) and Linux, with graceful exit + WSL2 message for unsupported OS
- Script passes `bash -n` syntax check and `shellcheck` with zero warnings
- Claude Code install guarded to avoid known lock file bug; post-install message instructs students to run `claude` manually

## Task Commits

Each task was committed atomically:

1. **Task 1: Create install.sh with OS detection, logging, and all dependency install functions** - `7e6a56f` (feat)

## Files Created/Modified

- `/tmp/claude-masterclass/install.sh` — Core installer: logging helpers, command_exists(), detect_os(), 6 install functions, clone_starter_kit(), main()

## Decisions Made

- `install_jq()` included in this plan (not deferred to 01-03) because jq is a prerequisite for the settings.json merge plan; pulling it forward avoids a Plan 03 dependency gap
- nvm guard sources `nvm.sh` first before calling `command_exists nvm` — because nvm is a shell function, not a binary; checking before sourcing would always return "not found" even when nvm is installed
- `install_claude_code()` uses `command_exists claude` as idempotency guard to avoid the native installer's lock file bug (GitHub issue #13599)

## Deviations from Plan

None — plan executed exactly as written. shellcheck was not pre-installed; installed via `brew install shellcheck` during verification (tool setup, not a code deviation).

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- `install.sh` is ready; Plan 01-02 can add `.env.example` and `.gitignore` scaffolding files
- Plan 01-03 can add `backup_claude_config()` and `merge_settings()` functions — the `# backup_and_merge will be added by Plan 03` comment in `main()` marks the insertion point
- jq dependency already installed by this plan, so Plan 03's JSON merge can rely on it

---
*Phase: 01-installer-foundation*
*Completed: 2026-03-10*
