# Roadmap: Claude Code Mastery — Starter Kit Overhaul

## Overview

Overhaul the `jeystaats/claude-masterclass` GitHub repo into a course companion starter kit aligned with the 9-module Claude Code Mastery course. The build proceeds in dependency order: installer first (highest risk, everything else deploys through it), then global config content (what gets installed), then module structure and CLAUDE.md architecture, then the session launcher (depends on module names), and finally scaffold verification and documentation (the student-facing first impression).

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Installer Foundation** - Safe, idempotent install.sh that merges into ~/.claude/ without destroying existing config ✓ (2026-03-10)
- [x] **Phase 2: Global Config Content** - The 5 skills, agents, and teaching hooks that install.sh deploys ✓ (2026-03-10)
- [x] **Phase 3: Module Structure and CLAUDE.md** - 9 module folders, root CLAUDE.md, and module-scoped CLAUDE.md files ✓ (2026-03-10)
- [ ] **Phase 4: Session Launcher** - start.sh with module-context injection and progressive disclosure
- [ ] **Phase 5: Scaffold and Docs** - Verified Next.js scaffold, cn() utility, and student-facing README

## Phase Details

### Phase 1: Installer Foundation

**Goal**: Students can safely bootstrap their environment on macOS/Linux with one command, and the installer never corrupts an existing Claude Code config.

**Depends on**: Nothing (first phase)

**Requirements**: INST-01, INST-02, INST-03, INST-04, INST-05, SCAF-03, SCAF-04

**Success Criteria** (what must be TRUE):
  1. Running `bash install.sh` on a fresh macOS machine installs Node.js, Git, pnpm, and Claude Code CLI without errors
  2. Running `install.sh` twice in a row produces the same result as running it once (idempotent)
  3. Before touching any file in `~/.claude/`, the installer creates a timestamped backup at `~/.claude/backup-YYYYMMDD-HHMMSS/`
  4. The installer clones the starter kit to `~/Documents/claude-mastery-starter` if not already present
  5. `.env.example` and `.gitignore` exist at project root covering all required variables and ignoring .env, node_modules, .DS_Store, Claude Code logs

**Plans:** 3 plans

Plans:
- [ ] 01-01-PLAN.md — Core install.sh with OS detection, dependency install functions, idempotency guards, clone logic
- [ ] 01-02-PLAN.md — .env.example, .gitignore update, and config/workshop-settings.json template
- [ ] 01-03-PLAN.md — Backup system and jq-based settings.json merge logic added to install.sh

---

### Phase 2: Global Config Content

**Goal**: The skills, agents, and teaching hooks the installer deploys are written, annotated, and pedagogically sound — each one is a standalone teaching artefact, not just a config file.

**Depends on**: Phase 1

**Requirements**: GLOB-01, GLOB-02, GLOB-03, GLOB-04, GLOB-05

**Success Criteria** (what must be TRUE):
  1. Five skills exist in `global-config/skills/lah-*/` with YAML frontmatter and inline comments explaining the pattern they teach
  2. Three to five agents exist in `global-config/agents/lah-*.md` with YAML frontmatter, each demonstrating a distinct Claude Code agent pattern
  3. Five teaching hooks are defined in `global-config/hooks/` and merged into `~/.claude/settings.json` using advisory exit 0 — every hook output includes what was detected, why it matters, and the exact fix
  4. All installed files use the `lah-` prefix; running the installer on a machine with pre-existing agents/skills produces no duplicates and no overwrites
  5. A `global-config/CLAUDE.md.snippet` with clear open/close delimiters exists and appends cleanly to an existing `~/.claude/CLAUDE.md`

**Plans**: TBD

Plans:
- [ ] 02-01: Write 5 skills (explain-code, commit-message, plan-task, review-code, debug-it) with annotated YAML frontmatter
- [ ] 02-02: Write 3-5 agents (code-reviewer, planner, debugger) with YAML frontmatter and tool declarations
- [ ] 02-03: Write 5 teaching hooks (TypeScript quality, React antipatterns, cn() usage, file size guard, secret detector) with advisory exit 0 and instructional output
- [ ] 02-04: Write CLAUDE.md.snippet and installer merge logic for all global-config files

---

### Phase 3: Module Structure and CLAUDE.md

**Goal**: Students see a clear 9-folder workspace aligned to the course, understand what each module covers, and experience a root CLAUDE.md that teaches while guiding — without cognitive overload.

**Depends on**: Phase 2

**Requirements**: MOD-01, MOD-02, MOD-03, MOD-04, CMD-01, CMD-02, CMD-03, CMD-04

**Success Criteria** (what must be TRUE):
  1. Nine module folders exist at `modules/01-getting-started/` through `modules/09-expert-pro/`, each matching its course slug exactly
  2. Every module folder contains a `README.md` listing objectives and the lesson list, plus a `PROGRESS.md` checklist students can check off
  3. Modules 1, 4, and 6 contain starter exercise files students can open and work in immediately
  4. Root `CLAUDE.md` is under 80 lines and uses `@imports` for detailed sections; inline comments explain WHY each rule exists, not just what the rule is
  5. Root `CLAUDE.md` references the correct stack (Next.js 16, React 19, Tailwind v4, TypeScript 5); module-scoped `.claude/CLAUDE.md` files exist for modules 1, 4, and 9, showing progressive complexity from 10 rules to full engineering standards

**Plans**: TBD

Plans:
- [ ] 03-01: Create 9 module folder skeleton with README.md and PROGRESS.md per module
- [ ] 03-02: Write starter exercise files for modules 1, 4, and 6
- [ ] 03-03: Write root CLAUDE.md (under 80 lines, correct stack, @import structure, instructional comments)
- [ ] 03-04: Write module-scoped .claude/CLAUDE.md for modules 1, 4, and 9 (progressive complexity)

---

### Phase 4: Session Launcher

**Goal**: Students can start a focused Claude Code session for any module with a single command, and Claude Code receives the right context for that module without manual setup.

**Depends on**: Phase 3

**Requirements**: SESS-01, SESS-02, SESS-03

**Success Criteria** (what must be TRUE):
  1. Running `bash start.sh` without arguments displays available modules and prompts the student to select one
  2. Running `bash start.sh 4` launches Claude Code scoped to `modules/04-build-your-app/` with teaching-mode instructions injected into the session CLAUDE.md
  3. The session CLAUDE.md written by start.sh includes only the skills, agents, and constraints relevant to the selected module — not the full global ruleset

**Plans**: TBD

Plans:
- [ ] 04-01: Write start.sh with module listing, selection prompt, and module-number-to-directory lookup
- [ ] 04-02: Implement session CLAUDE.md template with module-specific context injection and progressive skill disclosure

---

### Phase 5: Scaffold and Docs

**Goal**: Students arrive at a working Next.js app they can immediately build in, and the README gets them from clone to first Claude Code session in under 5 minutes.

**Depends on**: Phase 4

**Requirements**: SCAF-01, SCAF-02, DOC-01, DOC-02, DOC-03

**Success Criteria** (what must be TRUE):
  1. Running `pnpm install && pnpm dev` in the project root starts the Next.js 16 dev server without errors
  2. The `cn()` utility is importable from a consistent path and works with Tailwind class merging
  3. A new student who has never cloned this repo can follow the README and run their first Claude Code session in 5 minutes or fewer, with no prior Claude Code experience
  4. The README troubleshooting section covers EACCES errors, "command not found" errors, and PowerShell execution policy blocks
  5. `UPGRADING.md` exists and explains how to personalize the global config and evolve the setup beyond the course defaults

**Plans**: TBD

Plans:
- [ ] 05-01: Verify and update Next.js 16 + React 19 + Tailwind v4 scaffold; add cn() utility
- [ ] 05-02: Write README (5-step first-run, prerequisites, troubleshooting section)
- [ ] 05-03: Write UPGRADING.md with personalization guide and evolution path

---

## Progress

**Execution Order:**
Phases execute in order: 1 → 2 → 3 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Installer Foundation | 3/3 | ✓ Complete | 2026-03-10 |
| 2. Global Config Content | 4/4 | ✓ Complete | 2026-03-10 |
| 3. Module Structure and CLAUDE.md | 4/4 | ✓ Complete | 2026-03-10 |
| 4. Session Launcher | 0/2 | Not started | - |
| 5. Scaffold and Docs | 0/3 | Not started | - |
