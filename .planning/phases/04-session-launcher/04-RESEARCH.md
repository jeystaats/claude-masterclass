# Phase 4: Session Launcher - Research

**Researched:** 2026-03-10
**Domain:** Bash 3.2 scripting, Claude CLI invocation, CLAUDE.md session injection, progressive skill disclosure
**Confidence:** HIGH

---

## Summary

Phase 4 creates `start.sh`, the entry point students run before every learning session. The script must list 9 modules, accept a numeric selection, resolve the module directory, write a session-scoped CLAUDE.md, and launch Claude Code in that directory — all in bash 3.2 (macOS default).

The two critical design questions are answered by prior research and direct CLI inspection:

1. **How to launch Claude Code in a specific directory:** The `claude` CLI has no `--cwd` flag. The correct pattern is `cd "$MODULE_DIR" && claude` — or using `exec` to replace the shell process. This has been confirmed against the actual `claude --help` output (version 2.1.72).

2. **Where the session CLAUDE.md goes:** Three .claude/CLAUDE.md files already exist in the codebase (`modules/01`, `04`, `09`). Claude loads the CLAUDE.md nearest to the cwd, walking up the directory tree. Writing the session context to `modules/XX/.claude/CLAUDE.md` will cause Claude to load it automatically when started in that directory — no flags required.

**Primary recommendation:** Write `start.sh` as a single-file bash 3.2 script that uses a `case` statement for module-number-to-directory lookup (no associative arrays), writes a purpose-built session CLAUDE.md into the target module's `.claude/` directory, and uses `cd` + `exec claude` to hand off control. Keep the session CLAUDE.md under 60 lines with `@` imports for sub-content.

---

## Key Research Findings

### Finding 1: Claude CLI Invocation — No --cwd Flag

**Source:** Direct `claude --help` output (Claude Code 2.1.72, verified 2026-03-10)

The `claude` CLI has no `--cwd`, `--directory`, or `--chdir` flag. To launch in a specific directory:

```bash
# Correct pattern — cd first, then exec claude
cd "$MODULE_DIR" && exec claude

# Why exec instead of just claude:
# exec replaces the current process — start.sh exits, claude takes its place.
# Without exec: start.sh waits for claude to exit, then exits itself.
# Both work; exec is cleaner for a session launcher.
```

Relevant flags discovered in `--help` that may be useful:

| Flag | Relevance |
|------|-----------|
| `--append-system-prompt <prompt>` | Can inject text, but not a file — use physical CLAUDE.md instead |
| `--add-dir <directories...>` | Grants tool access to extra dirs — NOT for CLAUDE.md loading |
| `--continue` | Continues last conversation in cwd — not needed for fresh sessions |
| `--resume` | Resumes by session ID — useful for future "resume last session" feature |
| `--permission-mode` | Could set `acceptEdits` for hands-free modules — worth noting |

### Finding 2: CLAUDE.md Loading Hierarchy

**Source:** Prior research (03-RESEARCH.md), verified against official docs pattern, confirmed by 3 existing module .claude/CLAUDE.md files in the codebase.

When `claude` starts in a directory, it loads CLAUDE.md files in this order (all stacked, not overriding):

```
~/.claude/CLAUDE.md          (global — student's personal config)
     +
[repo-root]/CLAUDE.md        (project — stack, teaching rules)
     +
modules/XX/.claude/CLAUDE.md (module — lesson-specific context, already exists for 01, 04, 09)
```

The session CLAUDE.md written by `start.sh` should go to `modules/XX/.claude/CLAUDE.md`. This file is already present for modules 01, 04, and 09 with module-specific content. For modules 02, 03, 05, 06, 07, 08: the `.claude/` directory does not exist yet — `start.sh` must `mkdir -p`.

**IMPORTANT:** The existing `modules/04-plan-your-product/.claude/CLAUDE.md` has 40+ lines of carefully crafted module-specific rules. `start.sh` must NOT overwrite these — it should write a session CLAUDE.md to a different location OR skip writing if a CLAUDE.md already exists in the module's `.claude/` directory.

**Recommended solution:** Start.sh writes to `modules/XX/.claude/session.md`, not `CLAUDE.md`. The existing module CLAUDE.md files stay intact. `session.md` is NOT loaded automatically — it needs to be referenced from the module CLAUDE.md via `@session.md`. Alternatively, start.sh appends only if a session section delimiter is absent (same pattern as `append_claude_md_snippet` in `install.sh`).

**Second recommended solution (simpler):** Start.sh writes a standalone `modules/XX/SESSION.md` in the module root (not in .claude/). Then uses `--append-system-prompt "$(cat SESSION.md)"` to inject it. This avoids touching any .claude/CLAUDE.md files but the prompt text is not persisted across session resume.

**Best solution for this kit:** Write session context to `modules/XX/.claude/session.md` as a separate file, then add a single-line `@.claude/session.md` reference at the bottom of each module's CLAUDE.md (if not already there). This keeps module-authored rules intact and adds dynamic session context cleanly.

### Finding 3: Bash 3.2 Compatible Module Lookup

**Source:** Direct bash 3.2 testing (GNU bash 3.2.57, macOS arm64, 2026-03-10)

`declare -A` (associative arrays) requires bash 4+. macOS ships bash 3.2 by default. Three patterns work in bash 3.2:

**Pattern A: case statement (most readable)**
```bash
get_module_dir() {
  case "$1" in
    1|01) echo "01-getting-started" ;;
    2|02) echo "02-think-like-an-engineering-lead" ;;
    3|03) echo "03-ai-agents-and-automation" ;;
    4|04) echo "04-plan-your-product" ;;
    5|05) echo "05-design-and-components" ;;
    6|06) echo "06-build-your-app" ;;
    7|07) echo "07-deploy-and-ship" ;;
    8|08) echo "08-expert-pro" ;;
    9|09) echo "09-commands-and-resources" ;;
    *)    echo "" ;;
  esac
}
```

**Pattern B: glob expansion (zero hardcoding — self-healing)**
```bash
# Tested in bash 3.2: works correctly
MODULE_NUM="04"
MODULES_DIR="$SCRIPT_DIR/modules"
MODULE_DIR=$(ls -d "$MODULES_DIR/${MODULE_NUM}-"* 2>/dev/null | head -1)
# MODULE_DIR = "/path/to/modules/04-plan-your-product"
```

**Pattern C: dynamic listing from filesystem**
```bash
# List all modules dynamically, display name from README.md
i=0
for dir in "$MODULES_DIR"/[0-9][0-9]-*/; do
  [ -d "$dir" ] || continue
  i=$((i + 1))
  name=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^# Module [0-9]*: //')
  printf "  %2d. %s\n" "$i" "$name"
done
```

**Recommended:** Use Pattern B (glob expansion) for directory resolution — it is self-healing if a folder is renamed. Use Pattern C for the interactive listing (reads titles from README.md, stays in sync with actual content). Use Pattern A only as a fallback if glob fails.

### Finding 4: Self-Directory Resolution

**Source:** install.sh in the codebase (established pattern)

```bash
# From install.sh — the established pattern for this repo
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
```

Use this exact pattern at the top of `start.sh`. Do NOT use `$0` alone (breaks when script is called with a path). Do NOT use `readlink -f` (not available on stock macOS without GNU coreutils).

### Finding 5: Existing Module .claude/CLAUDE.md Content

Three modules already have module-scoped CLAUDE.md files (verified by filesystem inspection):

| Module | Has .claude/CLAUDE.md | Content summary |
|--------|----------------------|-----------------|
| 01-getting-started | YES | Beginner rules: explain before fix, no advanced TS, 50-line component limit |
| 04-plan-your-product | YES | Planning workflow, TypeScript patterns, PRD-first rules |
| 09-commands-and-resources | YES | Production-grade full TypeScript + React standards (capstone reference) |
| All others | NO | .claude/ directory does not exist yet |

The session CLAUDE.md must NOT overwrite these files. Write session context elsewhere (see Finding 2 above).

### Finding 6: Progressive Skill Disclosure Mapping

**Source:** Analysis of skill/agent names + module README content (2026-03-10)

Available skills: `lah-explain-code`, `lah-commit-message`, `lah-plan-task`, `lah-review-code`, `lah-debug-it`
Available agents: `lah-code-reviewer`, `lah-planner`, `lah-debugger`, `lah-explainer`

| Module | Skills to surface | Agents to surface | Rationale |
|--------|------------------|-------------------|-----------|
| 01 Getting Started | `lah-explain-code` | `lah-explainer` | First session: explain only, nothing that writes code |
| 02 Engineering Lead | `lah-explain-code`, `lah-plan-task` | `lah-explainer`, `lah-planner` | Introduces CLAUDE.md mastery and PRD thinking |
| 03 AI Agents | `lah-explain-code`, `lah-plan-task`, `lah-commit-message` | all 4 | Module IS about agents — show all agents, add commit skill |
| 04 Plan Product | `lah-plan-task`, `lah-explain-code` | `lah-planner` | Planning module — planner agent most relevant |
| 05 Design | `lah-explain-code`, `lah-review-code` | `lah-code-reviewer`, `lah-explainer` | Design review focus |
| 06 Build App | all 5 skills | all 4 agents | Main build phase — full access |
| 07 Deploy | `lah-commit-message`, `lah-review-code`, `lah-debug-it` | `lah-debugger`, `lah-code-reviewer` | Shipping: debug + review + commit quality |
| 08 Expert Pro | all 5 skills | all 4 agents | Advanced module — full access |
| 09 Commands | all 5 skills | all 4 agents | Reference module — list everything |

### Finding 7: Session CLAUDE.md Template Design

Based on the existing module CLAUDE.md files and the global CLAUDE.md.snippet, the session CLAUDE.md should follow this structure:

```markdown
<!-- SESSION: written by start.sh — do not edit manually -->
<!-- Module: XX | Started: YYYY-MM-DD HH:MM -->

## Your Session Context

You are helping a student working on **Module XX: [Title]**.

**Working directory:** modules/XX-slug/
**What this module covers:** [one sentence from README]

## Skills available this module

- `/lah-skill-name` — [description]

## Agents available this module

- `@lah-agent-name` — [description]

## Teaching focus for this module

[1-3 specific behavioral rules relevant to this module's learning objectives]
```

The session file must be lean: under 40 lines. The heavy behavioral rules live in the module's own `.claude/CLAUDE.md` (already written in Phase 3). The session file only adds the dynamic context (current date, module title, which skills/agents are activated).

---

## Architecture Patterns

### Recommended File Layout

```
[repo-root]/
├── start.sh                    # The script (this phase)
└── modules/
    ├── 01-getting-started/
    │   └── .claude/
    │       ├── CLAUDE.md       # existing — module behavioral rules
    │       └── session.md      # written by start.sh (new, gitignored)
    ├── 04-plan-your-product/
    │   └── .claude/
    │       ├── CLAUDE.md       # existing — must not be overwritten
    │       └── session.md      # written by start.sh
    └── [other modules]/
        └── .claude/
            └── session.md      # .claude/ dir created by start.sh if needed
```

`.claude/session.md` files should be gitignored. Add `.claude/session.md` to `.gitignore`.

### Pattern: Reference session.md from module CLAUDE.md

For modules that already have `.claude/CLAUDE.md`, add one line at the bottom:

```markdown
@session.md
```

For modules that don't have `.claude/CLAUDE.md` yet, start.sh creates it with only that import line.

This way the session context always loads when Claude opens in that module's directory.

### start.sh Execution Flow

```
bash start.sh [optional-module-number]
    │
    ├── Resolve SCRIPT_DIR with cd+dirname pattern
    ├── Check prereqs: claude installed? (command -v claude)
    │
    ├── If arg provided: use it as MODULE_NUM
    │   If no arg: display module list + prompt "Select module [1-9]:"
    │       └── Read user input, validate 1-9
    │
    ├── Resolve MODULE_DIR via glob: ${MODULES_DIR}/${NUM_PADDED}-*
    │       └── If no match: log_error "Module not found" + exit 1
    │
    ├── Extract module title from README.md line 1
    │
    ├── Build session.md content (heredoc) with:
    │       - Module number, title, date
    │       - Skills list for this module (from case statement)
    │       - Agents list for this module (from case statement)
    │       - Teaching focus (from case statement)
    │
    ├── mkdir -p "${MODULE_DIR}/.claude"
    ├── Write session.md to "${MODULE_DIR}/.claude/session.md"
    │
    ├── Ensure module .claude/CLAUDE.md exists (or create minimal one with @session.md)
    │
    ├── log_info "Launching Claude Code in modules/XX-slug/..."
    │
    └── cd "$MODULE_DIR" && exec claude
```

### Anti-Patterns to Avoid

- **Overwriting existing .claude/CLAUDE.md:** Modules 01, 04, 09 have hand-crafted rules. `start.sh` must never `>` to CLAUDE.md. Use `session.md` as a separate file.
- **Using `declare -A` for module lookup:** Requires bash 4+; fails silently or errors on macOS. Use `case` or glob.
- **Using `--append-system-prompt`:** Prompt text is not persisted if session is resumed. A physical file is the right mechanism.
- **Launching without cd:** Writing the session file to a temp location and passing `--add-dir` does NOT make Claude load a CLAUDE.md from that temp path. The CLAUDE.md must be in the directory Claude is started in.
- **Using `readlink -f`:** Not available on macOS without `brew install coreutils`. Stick to `cd "$(dirname "$0")" && pwd`.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead |
|---------|-------------|-------------|
| Module number validation | Custom regex checker | POSIX `case` with `*) log_error` fallback |
| Date formatting for session header | Custom date parser | `date "+%Y-%m-%d %H:%M"` (POSIX, works on macOS) |
| JSON for skill/agent mapping | jq parsing | Shell `case` statement — simpler, no dependency |
| Launching Claude in subdirectory | Child process management | `cd "$dir" && exec claude` |

---

## Common Pitfalls

### Pitfall 1: Overwriting Hand-Crafted Module CLAUDE.md Files

**What goes wrong:** `start.sh` writes directly to `.claude/CLAUDE.md`, destroying the Module 01 beginner rules, Module 04 planning workflow, and Module 09 production standards written in Phase 3.

**Why it happens:** Treating `.claude/CLAUDE.md` as a session scratch file rather than a committed teaching artifact.

**How to avoid:** Always write to `.claude/session.md`. Add `.claude/session.md` to `.gitignore`. Never touch `CLAUDE.md` from `start.sh`.

**Warning signs:** If `git diff` after running `start.sh` shows changes to `.claude/CLAUDE.md`, the script is doing the wrong thing.

### Pitfall 2: Bash 4+ Features on macOS

**What goes wrong:** Script crashes with `declare: -A: invalid option` or associative array syntax errors.

**Why it happens:** Developer tests on Linux (bash 5.x) or on a macOS machine with `brew install bash`. Students run on stock macOS with bash 3.2.

**How to avoid:** Use `case` statements and glob expansion. Run `bash --version` at start of script development to confirm you're testing against 3.2. Add `#!/bin/bash` (not `#!/usr/bin/env bash`) and explicitly test on macOS.

**Warning signs:** Any `declare -A`, `${array[@]}` patterns, or `(( ))` arithmetic with `**` (exponentiation).

### Pitfall 3: Module Directory Not Found

**What goes wrong:** Glob expansion `${MODULES_DIR}/${NUM}-*` returns empty if the number doesn't match (e.g., student types "4" and the directory is `04-`).

**Why it happens:** Shell glob doesn't zero-pad automatically.

**How to avoid:** Always zero-pad before glob: `NUM_PADDED=$(printf '%02d' "$MODULE_NUM")`. Then glob as `${NUM_PADDED}-*`.

### Pitfall 4: Session Context Not Loading

**What goes wrong:** Student launches Claude in the module directory but session.md content doesn't appear in Claude's context.

**Why it happens:** `session.md` is written but no `.claude/CLAUDE.md` exists to import it, OR the `.claude/CLAUDE.md` doesn't have the `@session.md` line.

**How to avoid:** `start.sh` must ensure the `@session.md` import line exists in `.claude/CLAUDE.md` before launching. If no CLAUDE.md exists, create one with just `@session.md`. If one exists, grep for the import line and append if absent.

### Pitfall 5: exec Prevents Cleanup

**What goes wrong:** Using `exec claude` means any post-session cleanup (e.g., deleting session.md) never runs, because exec replaces the process.

**Why it happens:** `exec` is attractive for clean process semantics but prevents deferred cleanup.

**How to avoid:** For this use case, exec is correct — there is no cleanup needed after session. If future versions need post-session actions, switch from `exec claude` to `claude; then_cleanup`.

---

## Code Examples

### Self-Directory Resolution (established pattern from install.sh)

```bash
# Source: install.sh in this codebase
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"
```

### Zero-Padding and Glob Resolution (bash 3.2, tested)

```bash
# Tested against bash 3.2.57 on macOS arm64
NUM_PADDED=$(printf '%02d' "$MODULE_NUM")
MODULE_DIR=$(ls -d "$MODULES_DIR/${NUM_PADDED}-"* 2>/dev/null | head -1)

if [ -z "$MODULE_DIR" ]; then
  log_error "Module $MODULE_NUM not found in $MODULES_DIR"
  exit 1
fi
```

### Dynamic Module Listing from Filesystem (bash 3.2)

```bash
echo ""
echo "  Select a module:"
echo ""
for dir in "$MODULES_DIR"/[0-9][0-9]-*/; do
  [ -d "$dir" ] || continue
  num=$(basename "$dir" | cut -c1-2)
  title=$(head -1 "$dir/README.md" 2>/dev/null | sed 's/^# Module [0-9]*: //')
  printf "  %s. %s\n" "$num" "$title"
done
echo ""
printf "  Module [1-9]: "
read -r MODULE_NUM
```

### Skill/Agent Case Statement

```bash
get_skills_for_module() {
  case "$1" in
    1)  echo "- \`/lah-explain-code\` — Explain code with analogies and diagrams" ;;
    2)  printf '%s\n' \
          "- \`/lah-explain-code\` — Explain code with analogies and diagrams" \
          "- \`/lah-plan-task\` — Decompose a task before coding" ;;
    3)  printf '%s\n' \
          "- \`/lah-explain-code\` — Explain code with analogies and diagrams" \
          "- \`/lah-plan-task\` — Decompose a task before coding" \
          "- \`/lah-commit-message\` — Write conventional commit messages" ;;
    # ... etc
    6|8|9) printf '%s\n' \
          "- \`/lah-explain-code\`" \
          "- \`/lah-commit-message\`" \
          "- \`/lah-plan-task\`" \
          "- \`/lah-review-code\`" \
          "- \`/lah-debug-it\`" ;;
  esac
}
```

### Session CLAUDE.md Heredoc Write

```bash
write_session_context() {
  local module_num="$1"
  local module_dir="$2"
  local module_title="$3"
  local session_file="$module_dir/.claude/session.md"
  local today
  today=$(date "+%Y-%m-%d %H:%M")

  mkdir -p "$module_dir/.claude"

  cat > "$session_file" << HEREDOC
<!-- SESSION: written by start.sh — do not edit manually -->
<!-- Module: ${module_num} | Started: ${today} -->

## Your Session Context

You are helping a student working on **Module ${module_num}: ${module_title}**.

**Working directory:** $(basename "$module_dir")/
**What this module covers:** $(sed -n '/^## What you/,/^## Lessons/p' "$module_dir/README.md" 2>/dev/null | head -4 | tail -2 | tr '\n' ' ')

## Skills available this module

$(get_skills_for_module "$module_num")

## Agents available this module

$(get_agents_for_module "$module_num")
HEREDOC

  log_done "Session context written to $(basename "$module_dir")/.claude/session.md"
}
```

### Ensuring @session.md Import Exists in CLAUDE.md

```bash
ensure_session_import() {
  local module_dir="$1"
  local claude_md="$module_dir/.claude/CLAUDE.md"

  mkdir -p "$module_dir/.claude"

  if [ ! -f "$claude_md" ]; then
    # No CLAUDE.md yet — create minimal one that loads session
    echo "@session.md" > "$claude_md"
    log_done "Created $(basename "$module_dir")/.claude/CLAUDE.md"
  elif ! grep -q "@session.md" "$claude_md"; then
    # CLAUDE.md exists but doesn't import session.md — append the import
    echo "" >> "$claude_md"
    echo "@session.md" >> "$claude_md"
    log_done "Added @session.md import to $(basename "$module_dir")/.claude/CLAUDE.md"
  else
    log_skip "$(basename "$module_dir")/.claude/CLAUDE.md already imports session.md"
  fi
}
```

### Claude Launch

```bash
log_info "Launching Claude Code in modules/$(basename "$MODULE_DIR")/ ..."
log_info "Tip: Claude will load the session context automatically."
echo ""
cd "$MODULE_DIR" && exec claude
```

---

## Session CLAUDE.md Template (reference)

What `start.sh` writes to `.claude/session.md`:

```markdown
<!-- SESSION: written by start.sh — do not edit manually -->
<!-- Module: 04 | Started: 2026-03-10 14:30 -->

## Your Session Context

You are helping a student working on **Module 04: Research & Plan Your Product**.

**Working directory:** 04-plan-your-product/
**What this module covers:** Good AI-assisted development starts before you write a single line of code. This module walks you through using Claude to do real market research, write a PRD, and scaffold your project.

## Skills available this module

- `/lah-plan-task` — Decompose a task before coding
- `/lah-explain-code` — Explain code with analogies and diagrams

## Agents available this module

- `@lah-planner` — Architecture planning, no writes (opus)
```

---

## Open Questions

1. **Session.md and gitignore**
   - What we know: session.md is dynamic and should not be committed
   - What's unclear: Does `.gitignore` at root already ignore `.claude/session.md`? Needs checking.
   - Recommendation: Add `**/session.md` to root `.gitignore` in the start.sh task or a dedicated gitignore task

2. **Module 08 "Expert Pro" — Pro/VIP gating**
   - What we know: Module 08 README says "Pro/VIP access required"
   - What's unclear: Should `start.sh` show module 08 in the list, or hide it / show a note?
   - Recommendation: Show it in the list with a "(Pro/VIP)" suffix, don't gate at the script level — gating happens at the platform, not the local script

3. **start.sh location assumption**
   - What we know: install.sh lives at repo root; start.sh should match
   - What's unclear: REQUIREMENTS.md should be checked for explicit placement constraint
   - Recommendation: Place at repo root alongside install.sh — consistent, discoverable

4. **"Teaching mode" language in session CLAUDE.md**
   - What we know: The global CLAUDE.md.snippet references "Teaching Mode" with explain-as-you-go behavior
   - What's unclear: Should session.md reinforce or simply inherit the teaching mode from global config?
   - Recommendation: Don't repeat it in session.md — it's already in global CLAUDE.md.snippet appended by install.sh. Session file should be additive, not repetitive.

---

## Sources

### Primary (HIGH confidence)
- Direct `claude --help` output — claude 2.1.72, all flags verified 2026-03-10
- Direct filesystem inspection — `/tmp/claude-masterclass/modules/` directory structure, all existing .claude/CLAUDE.md files read
- Bash 3.2 testing — glob patterns, printf zero-padding, case statements all tested live
- `install.sh` in codebase — established `SCRIPT_DIR` pattern, `log_info/log_done/log_skip/log_error` convention
- Prior research: `.planning/research/ARCHITECTURE.md` — CLAUDE.md loading hierarchy, session flow design
- Prior research: `.planning/phases/03-module-structure-and-claude-md/03-RESEARCH.md` — @import syntax, subdirectory CLAUDE.md scoping rules

### Secondary (MEDIUM confidence)
- Prior research: `.planning/research/STACK.md` — bash 3.2 incompatibilities list, `declare -A` constraint
- Module README.md files (all 9) — module titles, lesson descriptions, used for session context content

---

## Metadata

**Confidence breakdown:**
- bash 3.2 patterns: HIGH — tested live against macOS bash 3.2.57
- claude CLI invocation: HIGH — verified against actual `--help` output
- CLAUDE.md loading behavior: HIGH — confirmed by 3 existing module CLAUDE.md files + prior research
- Progressive skill/agent mapping: MEDIUM — based on module content analysis, not an explicit spec
- Session CLAUDE.md template: MEDIUM — inferred from existing module CLAUDE.md style + global snippet pattern

**Research date:** 2026-03-10
**Valid until:** 2026-04-10 (claude CLI flags are stable; bash 3.2 compatibility is permanent)
