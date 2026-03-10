# Architecture Research

**Domain:** Claude Code education starter kit (brownfield Next.js scaffold)
**Researched:** 2026-03-10
**Confidence:** HIGH (verified against official Claude Code docs + real ~/.claude config inspection)

## Standard Architecture

### System Overview

The kit has three distinct layers: the **repo** (what students clone), the **global install** (what the installer drops into `~/.claude/`), and the **session launcher** (what starts each learning session). These layers must never bleed into each other.

```
┌─────────────────────────────────────────────────────────────────┐
│                     STUDENT'S MACHINE                           │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    ~/.claude/  (GLOBAL)                  │   │
│  │  settings.json   CLAUDE.md   agents/   hooks/   skills/ │   │
│  │  [merged by installer, never overwritten wholesale]      │   │
│  └─────────────────────────────────────────────────────────┘   │
│            ↑ installer writes once, additively                  │
│                                                                 │
│  ┌──────────────────────┐   ┌──────────────────────────────┐   │
│  │   REPO (git clone)   │   │   MODULE WORKSPACE           │   │
│  │                      │   │   ~/claude-masterclass/      │   │
│  │  install.sh          │   │   modules/                   │   │
│  │  start.sh            │──▶│     01-foundations/          │   │
│  │  modules/            │   │     02-context/              │   │
│  │    01-foundations/   │   │     ...                      │   │
│  │    02-context/       │   │   .claude/settings.json      │   │
│  │    ...               │   │   CLAUDE.md (progressive)    │   │
│  │  .claude/            │   └──────────────────────────────┘   │
│  │    settings.json     │                                      │
│  │    CLAUDE.md         │                                      │
│  └──────────────────────┘                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

```
INFORMATION FLOW

install.sh
    │
    ├── reads ~/.claude/settings.json (if exists) → merges, never overwrites
    ├── creates ~/.claude/agents/  (prefixed: lah-*.md)
    ├── creates ~/.claude/skills/  (prefixed: lah-*.md)
    ├── appends to ~/.claude/CLAUDE.md (does NOT replace)
    └── writes backup to ~/.claude/backups/pre-masterclass-TIMESTAMP/

start.sh (per session)
    │
    ├── reads MODULE_NUMBER env var or prompts
    ├── writes .claude/settings.json for this session
    ├── writes CLAUDE.md unlocking only current module content
    └── opens Claude Code in modules/XX-name/ directory
```

### Component Responsibilities

| Component | Responsibility | Boundary |
|-----------|----------------|----------|
| `install.sh` | One-time global setup. Merges agents/skills/hooks into `~/.claude/`. Creates backups. Never runs twice safely. | Writes to `~/.claude/` only. Never touches project files. |
| `start.sh` | Session launcher. Sets module context, unlocks appropriate CLAUDE.md content. | Writes to `.claude/` in working dir. Idempotent. |
| `modules/XX-name/` | Per-module student workspace. Contains starter files, exercises, reference solutions. | Self-contained. No cross-module imports. |
| `.claude/settings.json` (project) | Permission allowlist for the course project. Team-shareable. Committed to git. | Additive to global settings. Array permissions merge. |
| `CLAUDE.md` (project) | Progressive teaching manifest. Unlocks content as student advances. | Project-level — overrides `~/.claude/CLAUDE.md` for this project only. |
| `~/.claude/agents/lah-*.md` | Beginner-friendly simplified agent definitions. The `lah-` prefix namespaces them. | Global scope. Available across all Claude Code sessions. |
| `~/.claude/skills/lah-*.md` | Simplified skills matching course lessons. Readable teaching docs, not power-user configs. | Global scope. Referenced from CLAUDE.md via progressive disclosure. |
| `~/.claude/hooks/` | Beginner-safe hooks. Fewer, less aggressive than production config (26 hooks → ~5 teaching hooks). | Global. Must not conflict with student's existing hooks. |

---

## Recommended Project Structure

```
claude-masterclass/                   # git root
├── install.sh                        # One-time global installer
├── start.sh                          # Session launcher (run before each lesson)
├── CLAUDE.md                         # Project CLAUDE.md (progressive disclosure root)
├── .claude/
│   ├── settings.json                 # Course-level permissions (committed)
│   └── settings.local.json.example  # Template for student personal overrides
│
├── modules/
│   ├── 01-foundations/
│   │   ├── README.md                 # Lesson instructions
│   │   ├── starter/                  # Code students begin with
│   │   ├── solution/                 # Reference solution
│   │   └── .claude/CLAUDE.md         # Module-specific unlock (optional)
│   ├── 02-context/
│   │   └── [same pattern]
│   └── 09-advanced-agents/
│       └── [same pattern]
│
├── global-config/                    # Source files that install.sh deploys
│   ├── agents/
│   │   ├── lah-workshop-start.md
│   │   ├── lah-code-reviewer.md
│   │   └── lah-debug-helper.md
│   ├── skills/
│   │   ├── lah-react-patterns.md
│   │   ├── lah-stack-guide.md
│   │   └── lah-hooks-guide.md
│   ├── hooks/
│   │   ├── check-typescript.sh       # TypeScript quality (beginner-safe)
│   │   └── check-react-antipatterns.sh
│   └── CLAUDE.md.snippet             # Appended (not replacing) global CLAUDE.md
│
├── src/                              # Shared Next.js scaffold (brownfield base)
│   ├── app/
│   │   ├── layout.tsx
│   │   └── page.tsx
│   └── components/
│
└── docs/
    ├── setup-guide.md
    └── troubleshooting.md
```

### Structure Rationale

- **`global-config/` as source directory:** The installer reads from here, students never edit it. Clean separation between "what gets installed" and "how students work."
- **`lah-` prefix on all global files:** Namespaces the course's agents/skills so they don't clash with students' existing `~/.claude/` content. Critical for non-destructive installs.
- **Module-local CLAUDE.md files:** Optional per-module context overrides. When Claude Code opens a subdirectory, it loads all CLAUDE.md files up the tree — module files automatically layer on top of the project file.
- **`solution/` beside `starter/`:** Students work in `starter/`, compare against `solution/`. Never in the same directory — avoids "let me just look at the answer" accidents with Claude Code.
- **`settings.local.json.example`:** Committed template showing students how to create their own untracked personal overrides (IDE preferences, personal API keys, etc.)

---

## Architectural Patterns

### Pattern 1: Additive Global Install (Non-Destructive)

**What:** The installer checks for existing `~/.claude/settings.json` and surgically merges new permission entries into existing arrays rather than replacing the file. Backs up the entire `~/.claude/` state before touching anything.

**When to use:** Every installer operation. This is a hard constraint — students may have months of custom config.

**Trade-offs:** Slightly more complex installer logic. The payoff is zero "it broke my Claude Code" support tickets.

```bash
# install.sh core merge pattern
backup_existing_config() {
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  BACKUP_DIR="$HOME/.claude/backups/pre-masterclass-$TIMESTAMP"
  if [ -d "$HOME/.claude" ]; then
    cp -r "$HOME/.claude" "$BACKUP_DIR"
    echo "Backup saved: $BACKUP_DIR"
  fi
}

merge_settings() {
  TARGET="$HOME/.claude/settings.json"
  SOURCE="./global-config/settings-additions.json"

  if [ ! -f "$TARGET" ]; then
    # No existing config — safe to copy directly
    cp "$SOURCE" "$TARGET"
  else
    # Merge: use node/python to deep-merge JSON arrays
    node -e "
      const existing = require('$TARGET');
      const additions = require('$SOURCE');
      const merged = {
        ...existing,
        permissions: {
          ...existing.permissions,
          allow: [...new Set([
            ...(existing.permissions?.allow || []),
            ...(additions.permissions?.allow || [])
          ])]
        }
      };
      require('fs').writeFileSync('$TARGET', JSON.stringify(merged, null, 2));
    "
  fi
}
```

### Pattern 2: Progressive CLAUDE.md Disclosure

**What:** The project CLAUDE.md starts minimal (just stack and "read the module README"). `start.sh` rewrites a `## Current Module` section to progressively unlock lesson-appropriate skills, agents, and constraints as students advance.

**When to use:** This is the core teaching mechanic. Module 1 students get a CLAUDE.md with beginner guardrails; Module 9 students get fewer guardrails and access to advanced agents.

**Trade-offs:** CLAUDE.md becomes dynamic (written by `start.sh`), not purely static. This is acceptable because the file is in `.claude/` not committed student work.

```bash
# start.sh writes the module-specific context section
write_module_context() {
  MODULE_NUM=$1
  MODULE_DIR="modules/$(printf '%02d' $MODULE_NUM)-*"

  cat > .claude/CLAUDE.md << EOF
# Claude Masterclass — Module $MODULE_NUM

## Stack
Next.js 15, React 19, TypeScript, Tailwind CSS
Auth: Clerk | Database: Supabase or Convex
See CLAUDE.md in the project root for full stack rules.

## Your Current Focus
Work in: $MODULE_DIR/starter/

## Skills Available This Module
$(get_skills_for_module $MODULE_NUM)

## Constraints
$(get_constraints_for_module $MODULE_NUM)
EOF
}
```

### Pattern 3: Module-Scoped Workspace Isolation

**What:** Each module directory is a self-contained unit. `start.sh` changes Claude Code's working directory to the active module. Students cannot accidentally reference or break other modules.

**When to use:** When launching a learning session. Claude Code loads CLAUDE.md files recursively from the opened directory upward — opening `modules/03-hooks/starter/` automatically stacks: `~/.claude/CLAUDE.md` → `CLAUDE.md` (project root) → `modules/03-hooks/.claude/CLAUDE.md`.

**Trade-offs:** Students must re-run `start.sh` to switch modules. This is intentional friction — it prevents context bleed between lessons.

```bash
# start.sh: open Claude Code in the correct module directory
MODULE_PATH="$REPO_ROOT/modules/$(printf '%02d' $MODULE_NUM)-$(get_module_name $MODULE_NUM)/starter"
cd "$MODULE_PATH"
claude  # starts Claude Code in that directory
```

### Pattern 4: Simplified Hook Set (5 not 26)

**What:** The production config has 26 hooks covering everything from Convex patterns to Gmail tone. For teaching, install only the 5 most pedagogically valuable hooks:
1. `check-typescript-quality.sh` — TypeScript errors (core skill)
2. `check-react-antipatterns.sh` — React patterns (core skill)
3. `check-security.sh` — Never commit secrets (universally important)
4. `check-file-size-guard.sh` — Keep files small (good habit)
5. `validate-json.sh` — JSON validity (config files)

**When to use:** The install step. Production hooks like `check-convex-patterns.sh` or `check-pencil-spacing.sh` are irrelevant to students and create noise.

**Trade-offs:** Students don't get the full hook experience. But overwhelming a beginner with 26 opinionated hooks on day one causes abandonment, not learning.

---

## Data Flow

### Session Start Flow

```
Student runs: ./start.sh [module-number]
    │
    ├── [start.sh] Reads AVAILABLE_MODULES from modules/ directory names
    ├── [start.sh] Prompts if no MODULE_NUMBER provided
    ├── [start.sh] Writes .claude/CLAUDE.md with module-specific context
    ├── [start.sh] Verifies prerequisites (node, npm, Claude Code installed)
    └── [start.sh] exec: claude in modules/XX-name/starter/
                              │
                              ▼
              Claude Code loads CLAUDE.md stack:
              ~/.claude/CLAUDE.md (global - base rules)
                    +
              [repo-root]/CLAUDE.md (project - stack rules)
                    +
              [repo-root]/modules/XX/.claude/CLAUDE.md (module - lesson rules)
                    +
              [session]/.claude/CLAUDE.md (session - current focus, written by start.sh)
```

### Install Flow

```
Student runs: ./install.sh
    │
    ├── [install.sh] Check: is Claude Code installed?
    │   └── If not: print install instructions, exit 1
    │
    ├── [install.sh] Backup ~/.claude/ → ~/.claude/backups/pre-masterclass-TIMESTAMP/
    │
    ├── [install.sh] Merge ~/.claude/settings.json
    │   └── Adds course permission allows (Bash, npm, git, etc.)
    │   └── Registers 5 teaching hooks (PostToolUse)
    │
    ├── [install.sh] Copy global-config/agents/ → ~/.claude/agents/
    │   └── Only files not already present (idempotent)
    │   └── All prefixed lah-* (no collision with existing)
    │
    ├── [install.sh] Copy global-config/skills/ → ~/.claude/skills/
    │   └── Same: lah-* prefix, skip if exists
    │
    ├── [install.sh] Append global-config/CLAUDE.md.snippet → ~/.claude/CLAUDE.md
    │   └── Guarded: only appends if masterclass section not already present
    │
    └── [install.sh] Print: "Setup complete! Run ./start.sh to begin Module 1."
```

### Key Data Flows

1. **Module context injection:** `start.sh` → `.claude/CLAUDE.md` → Claude Code context window. The session CLAUDE.md is the only dynamic file. Everything else is static after install.

2. **Hook execution:** Student writes code → Claude Code triggers PostToolUse → `~/.claude/hooks/check-*.sh` runs → hook reads the written file → returns feedback to Claude → Claude shows student what to fix. Students see the hook system working live — it's a teaching moment, not just enforcement.

3. **Progressive skill access:** `start.sh` determines module number → writes appropriate `## Skills Available` section in session CLAUDE.md → Claude Code sees and loads those skills on demand (not upfront). This is progressive disclosure: Module 1 CLAUDE.md might reference `lah-react-patterns.md` only; Module 7 adds `lah-agents-orchestration.md`.

---

## Anti-Patterns

### Anti-Pattern 1: Full settings.json Replacement

**What people do:** Overwrite `~/.claude/settings.json` wholesale with the course's config.

**Why it's wrong:** Destroys the student's existing permission allows, MCP server configs, hook registrations, and model preferences. Results in broken Claude Code setups for any student who was already using it. High severity support burden.

**Do this instead:** JSON-merge the `permissions.allow` and `hooks` arrays additively. Use `jq` or a Node.js script. Test with `diff` before writing. Always back up first.

### Anti-Pattern 2: Global CLAUDE.md Replacement

**What people do:** Write a completely new `~/.claude/CLAUDE.md` with course instructions, erasing the student's existing global memory.

**Why it's wrong:** Students using Claude Code for other projects lose their global context (project conventions, personal preferences, client rules). The global CLAUDE.md accumulates months of useful context.

**Do this instead:** Append a clearly delimited section: `## Claude Masterclass Context (added by install.sh)`. Check for this delimiter before appending — makes the operation idempotent and reversible.

### Anti-Pattern 3: One Giant CLAUDE.md for All Modules

**What people do:** Put all 9 modules' instructions, skills references, and constraints into a single project CLAUDE.md.

**Why it's wrong:** Bloats the context window, confuses Claude Code (Module 9 constraints visible to Module 1 students), and defeats the pedagogical progression where students gradually gain "powers."

**Do this instead:** Keep the project CLAUDE.md minimal (stack only). Use `start.sh` to write a lean session file in `.claude/CLAUDE.md` that is specific to the active module. Use progressive disclosure: reference skill files rather than inlining content.

### Anti-Pattern 4: Shared `starter/` Directory Across Modules

**What people do:** Have students work in a single shared workspace that accumulates all module work.

**Why it's wrong:** Module 5 code pollutes Module 3 context. Claude Code gets confused about what's "active." Students can't tell where one lesson ends and the next begins.

**Do this instead:** Each module is a fully isolated directory. `start.sh` changes the working directory per session. Encourage students to `git commit` at the end of each module before starting the next.

### Anti-Pattern 5: Production-Complexity Hooks From Day One

**What people do:** Install all 26 production hooks (Convex patterns, Pencil spacing, Gmail tone, etc.) into the student's global config.

**Why it's wrong:** Hooks that check for Convex patterns throw errors on a Supabase project. Hooks that check Pencil spacing are meaningless without a Pencil.dev project. Noisy, irrelevant hook failures make students distrust the hook system entirely.

**Do this instead:** Install 5 universally applicable teaching hooks. Document what each does in plain English in the hook script headers. Students should *understand* every hook that runs on their machine.

---

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Claude Code (anthropic) | Students install via official `curl` or `npm` method first | Installer pre-checks for `claude --version`. Fails fast with clear error if not installed. |
| Clerk (auth) | Installed via CLAUDE.md stack rules, not installer | Students follow module README to set up their own Clerk account. Never install for them. |
| Supabase / Convex | Same — student-owned accounts | Module README provides quickstart. CLAUDE.md provides patterns. |
| GitHub (repo) | `git clone` is the entry point | `install.sh` lives in the repo root. Students run it post-clone. |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `install.sh` ↔ `~/.claude/` | File writes (merge, not replace) | install.sh must handle `~/.claude/` not existing yet (fresh machine) |
| `start.sh` ↔ `.claude/CLAUDE.md` | File write (rewrites per session) | start.sh owns this file. Students should not manually edit it. |
| `global-config/` ↔ `~/.claude/agents/` | File copy (lah-* prefixed) | Source of truth is `global-config/`. If students modify `~/.claude/agents/lah-*.md`, that's fine — they won't be overwritten (idempotent copy, skip-if-exists). |
| Module `starter/` ↔ Module `solution/` | No programmatic link | Intentionally separate. Students compare manually, not via import. |
| Project `.claude/settings.json` ↔ `~/.claude/settings.json` | Array merge at runtime by Claude Code | Permissions arrays concatenate across scopes. Project-level allows stack on top of user-level allows. |

---

## Suggested Build Order

Based on component dependencies, build in this sequence:

1. **`global-config/` structure** — Define the 5 teaching hooks, 3-5 starter agents, and 5-8 skills as actual files. These are the curriculum material in code form. Everything else depends on knowing what gets installed.

2. **`install.sh`** — Build the installer second, once you know what you're installing. Test the JSON merge logic against a mock `~/.claude/settings.json` with many existing entries. Test backup creation. Test idempotency (running twice should be a no-op).

3. **`modules/` structure** — Create the directory skeleton for all 9 modules with README.md and empty `starter/` / `solution/` dirs. This unblocks parallel work on module content.

4. **`CLAUDE.md` (project root)** — Write the base teaching config: stack rules, decision guide, what not to do. This is the single most-read file by every student. Worth multiple revision passes.

5. **`start.sh`** — Build last among infrastructure files. Depends on knowing the module structure and CLAUDE.md format. The module-name lookup needs the actual directory names to exist.

6. **Module content** — Fill `starter/` and `solution/` per module. Can be parallelized across modules once the structure is locked.

---

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-50 students (Barcelona workshop) | Current architecture handles this fine. Manual install support via Telegram/Discord. |
| 50-500 students (online cohorts) | Add `--uninstall` flag to `install.sh`. Add version tracking (write `MASTERCLASS_VERSION` to a file post-install) so returning students can upgrade. |
| 500+ students (self-paced catalog) | Consider a web-based config generator that outputs a pre-filled `install.sh` for each student's skill level. Module gating (server-side unlock) becomes worth building. |

### Scaling Priority

1. **First issue:** Students who run `install.sh` twice and get duplicate hook registrations. Fix: idempotency guards on every write operation.
2. **Second issue:** Students on Windows (WSL) — bash scripts behave differently. Fix: test explicitly on WSL2, add a Powershell alternative or document the workaround clearly.

---

## Sources

- [Claude Code Settings Documentation](https://code.claude.com/docs/en/settings) — Settings schema, hooks lifecycle, agent format, CLAUDE.md behavior (MEDIUM confidence — fetched live)
- [Claude Code Settings array-merge behavior](https://github.com/anthropics/claude-code/issues/11626) — Confirmed array permissions merge across scopes; project-level does NOT auto-inherit global for non-array keys (MEDIUM confidence — GitHub issue)
- [The Decipherist Starter Kit](https://github.com/TheDecipherist/claude-code-mastery-project-starter-kit) — Non-destructive merge installer pattern, `global-config/` source directory pattern (MEDIUM confidence — community project, live-fetched)
- [serpro69/claude-starter-kit](https://github.com/serpro69/claude-starter-kit) — `lah-*` prefix namespacing pattern for non-conflicting global installs, symlink-based config isolation (MEDIUM confidence)
- [Progressive disclosure for CLAUDE.md](https://alexop.dev/posts/stop-bloating-your-claude-md-progressive-disclosure-ai-coding-tools/) — File-reference pattern to avoid context bloat (MEDIUM confidence — community article)
- Direct inspection of `~/.claude/settings.json` and `~/.claude/hooks/` on this machine (HIGH confidence — first-party source)

---
*Architecture research for: Claude Code Masterclass starter kit (brownfield Next.js)*
*Researched: 2026-03-10*
