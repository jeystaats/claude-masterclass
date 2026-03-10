# Project Research Summary

**Project:** Claude Code Mastery — Course Companion Starter Kit
**Domain:** Developer education starter kit (Claude Code extensions + Next.js scaffold)
**Researched:** 2026-03-10
**Confidence:** HIGH

## Executive Summary

This is a developer education starter kit that ships as a git repository students clone and run. The kit teaches Claude Code extensions (skills, agents, hooks, MCP servers) through a brownfield Next.js scaffold. Experts build this kind of kit in three distinct layers: the global install (`~/.claude/` — user-level, always available), the project repo (version-controlled, shareable), and the session launcher (per-lesson context injection). All four research areas converge on the same recommendation: build for safety first, then pedagogy. The highest-risk operation — installing files into a student's existing `~/.claude/` directory — must be non-destructive, additive, and idempotent before anything else ships.

The recommended approach is a `global-config/` source directory that feeds a one-time `install.sh` and a per-session `start.sh`. The install script merges (never overwrites) into `~/.claude/`, namespaces all course files with a `lah-` prefix, and backs up before touching anything. The session launcher uses progressive CLAUDE.md disclosure to reveal only the skills, agents, and constraints relevant to the current module — this is both the core teaching mechanic and the primary defense against context window bloat. The brownfield scaffold (Next.js 16, React 19, Tailwind v4, Convex, Clerk) is already in place and requires no migration.

The key risks are all installer-layer problems: destructive config writes that break existing Claude Code setups, non-idempotent scripts that corrupt on re-run, hooks that block beginners cold instead of teaching them, and shell environment issues that leave `node` or `claude` unreachable after install. Every one of these has a concrete mitigation pattern documented in research. Build the installer defensively and test it on machines with pre-existing `~/.claude/` configs before any module content work begins.

---

## Key Findings

### Recommended Stack

The extension formats are fully documented against official Claude Code docs and carry HIGH confidence across all four formats: Skills (SKILL.md with YAML frontmatter, `~/.claude/skills/`), Agents (agent.md with YAML frontmatter, `~/.claude/agents/`), Hooks (JSON in `settings.json`), and MCP servers (`.mcp.json` at project root). The `.claude/commands/` format still works but Skills are the canonical forward-looking format and should be used in all course material.

The app scaffold stack is locked to what already exists in the brownfield repo — no migration needed.

**Core technologies:**
- Next.js 16 + React 19.2 — brownfield scaffold, Turbopack stable, React Compiler stable; no migration needed
- Tailwind CSS v4 — CSS-first `@theme` config already in place; demonstrates the new v4 pattern
- TypeScript 5 (strict) — required for React Compiler; enforced by existing Husky pre-commit hook
- Bash (POSIX-compatible) — installer + session launcher; avoids bash 4+ features that fail on stock macOS
- PowerShell 5.1+ — Windows installer path; self-fixes execution policy at startup
- jq — required in hook scripts that parse Claude Code's stdin JSON; `brew install jq`
- shellcheck + shfmt — installer QA; catches portability issues and enforces readable style

**Key avoids:** `#!/bin/bash` with bash 4+ features (macOS ships bash 3.2), `curl | bash` as the only install method, global npm packages in the installer, `Task(...)` agent tool syntax (deprecated alias — use `Agent(...)`), hardcoded API keys in `.mcp.json`.

### Expected Features

The competitive landscape (Wes Bos, KCD Epic Workshop, freeCodeCamp) sets a clear baseline: numbered module folders, environment verification scripts, starter/solution file pairs, and a README that gets a beginner to their first working command in under 60 seconds. What none of them offer is the differentiating value this kit can provide: instructional hooks that teach patterns in real-time, annotated skills as learning artefacts, and a progressive CLAUDE.md that evolves with the student.

**Must have (table stakes):**
- Module-aligned workspace folders (`01-foundations/` through `09-advanced-agents/`) — orientation is non-negotiable
- Root CLAUDE.md with instructional inline comments — the course's primary teaching artefact
- Module-scoped CLAUDE.md files (at minimum modules 1, 4, 8) — demonstrates how context evolves
- Environment verification script (macOS + Linux) — eliminates 80% of "it doesn't work" support tickets
- `.env.example` with `ANTHROPIC_API_KEY` and inline comments — prevents the #1 beginner mistake
- README with 5 or fewer steps to first successful Claude Code run — first impression is permanent
- `.gitignore` — no learner should ever accidentally commit their API key
- 3 annotated skills: `explain-code`, `commit-message`, `plan-task` — core Skills format taught through working examples
- 2 pre-built agents: `code-reviewer.md`, `planner.md` — Agent format taught through working examples
- Module-scoped `settings.json` examples (modules 1, 6, 9) — concrete diff showing hook evolution

**Should have (competitive):**
- Instructional hooks that print "why this matters" and "how to fix it" on every trigger — no other course kit does this
- Global skills installer script (`install-global-skills.sh`) — ships course skills to `~/.claude/skills/` so they work in any project
- Module progress checklists (`PROGRESS.md`) — zero-dependency, zero-server progress tracking
- Windows PowerShell setup path — add when course analytics show Windows user share
- 2 additional agents: `debugger.md`, `docs-writer.md`

**Defer (v2+):**
- Validation hooks for exercises (advisory, not grading) — HIGH complexity; only justified if completion data shows students getting stuck
- `UPGRADING.md` — only meaningful after students complete the course; premature for v1
- MCP setup bonus module — keep base kit credential-free; add only if students ask

**Anti-features to avoid:** Auto-installing Claude Code CLI (requires interactive auth), interactive web progress tracker (server overhead, maintenance surface), automated binary grading (wrong mindset for LLM-based learning), pre-configured MCP servers (breaks on missing credentials).

### Architecture Approach

The kit separates into three non-bleeding layers: the `global-config/` source directory (what gets installed), the `~/.claude/` target (student's global Claude Code config, modified additively), and the `modules/` workspace (where students do their work). `install.sh` runs once and merges; `start.sh` runs per session and injects module-specific context into `.claude/CLAUDE.md`. Every file the installer writes to `~/.claude/` is namespaced with `lah-` to prevent collision with the student's existing config. The session CLAUDE.md is the only dynamic file — everything else is static after install.

**Major components:**
1. `install.sh` — One-time global setup; merges agents/skills/hooks into `~/.claude/`; backs up before every write; idempotent
2. `start.sh` — Per-session launcher; writes module-specific context to `.claude/CLAUDE.md`; opens Claude Code in `modules/XX/starter/`
3. `global-config/` — Source directory for all files the installer deploys (agents, skills, hooks, CLAUDE.md snippet)
4. `modules/XX-name/` — Isolated per-module workspaces with `starter/`, `solution/`, and `README.md`; no cross-module imports
5. Root `CLAUDE.md` — Progressive teaching manifest with stack rules and instructional comments; kept under 80 lines
6. Module CLAUDE.md files — Layered on top of root CLAUDE.md by Claude Code's directory traversal; add module-specific constraints

**Build order:** `global-config/` files first → `install.sh` → `modules/` skeleton → root `CLAUDE.md` → `start.sh` → module content. Everything downstream depends on knowing what gets installed.

### Critical Pitfalls

1. **Destructive global config installation** — The installer must never use `>` (overwrite) on any file in `~/.claude/`. Use `jq` to deep-merge `settings.json`, append with delimiters to `CLAUDE.md`, and always write a timestamped backup before touching anything. This is the highest-severity issue: a student who loses months of custom Claude Code config will not complete the course and will request a refund.

2. **Hooks that block beginners cold** — Advisory hooks (exit 0 + message) teach; blocking hooks (exit 2) wall. Course hooks must use exit 0 with a fix-guidance message unless the operation is genuinely dangerous (writing secrets to public files). Every hook output must include: what was detected, why it matters, and the exact fix.

3. **CLAUDE.md cognitive overload** — Official docs state that bloated CLAUDE.md files cause Claude to ignore actual instructions. Target under 80 lines / under 3KB for beginner modules. Use `@path/to/file` imports to load supplementary rules on demand. Module 1 CLAUDE.md should contain 10 rules or fewer.

4. **Non-idempotent installer** — A student who hits an error and re-runs the installer must get a clean second run. Use `grep -q` before every `~/.zshrc` append, skip-if-exists on every file copy, and `jq`'s conditional insert for JSON. Test by running the installer twice in a row on the same machine.

5. **Shell environment not propagating** — After installing Node via nvm, the `node` command is not available until the shell is reloaded. End the installer with an explicit "RESTART YOUR TERMINAL" prompt. Never call a just-installed tool without re-sourcing or using the full path. Test on a fresh terminal window, not the install window.

6. **PowerShell execution policy blocking Windows students** — Default Windows PowerShell policy (`Restricted`) blocks all scripts. The installer `.ps1` must check and self-fix the execution policy at startup, or document WSL2 as the primary Windows path.

---

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Installer Foundation
**Rationale:** All other phases depend on a non-destructive, idempotent installer. Shipping module content without a verified installer means students who already use Claude Code will lose their config. This is the only pitfall with a non-recoverable failure mode (if no backup was created).
**Delivers:** `install.sh` with merge logic, backup system, idempotency guards; `start.sh` skeleton; `.env.example`; `.gitignore`; environment verification script (macOS + Linux)
**Addresses:** Environment verification script, cross-platform setup (macOS/Linux), `.env.example`
**Avoids:** Destructive global config install (Pitfall 1), non-idempotent installer (Pitfall 5), EACCES npm errors (Pitfall 6), shell environment propagation failures (Pitfall 4)
**Research flag:** Standard patterns — shell merge scripting is well-documented; no additional research needed

### Phase 2: Global Config Content
**Rationale:** The `global-config/` directory is the curriculum in code form. The installer is useless without knowing what it installs. Building these files second means the installer can be tested with real content, and every agent/skill/hook is a standalone teaching artefact before modules reference them.
**Delivers:** 3 annotated skills (`explain-code`, `commit-message`, `plan-task`), 2 pre-built agents (`code-reviewer.md`, `planner.md`), 5 teaching hooks (TypeScript quality, React antipatterns, security, file size, JSON validity), `global-config/CLAUDE.md.snippet`
**Uses:** Skills frontmatter spec (HIGH confidence from STACK.md), Agents frontmatter spec (HIGH confidence), Hooks configuration spec (HIGH confidence)
**Avoids:** Production-complexity hooks from day one — install only 5 pedagogically valuable hooks, not all 26 (Pitfall from ARCHITECTURE.md)
**Research flag:** Standard patterns — all frontmatter specs are fully documented in official docs

### Phase 3: Module Structure and Root CLAUDE.md
**Rationale:** The module folder skeleton and root CLAUDE.md are the student's orientation layer. They must exist before any content is written into them, and the CLAUDE.md architecture (layered, import-based) must be decided before a single line is written. Getting this wrong means a 15KB CLAUDE.md that Claude partially ignores.
**Delivers:** `modules/01-foundations/` through `modules/09-advanced-agents/` directory skeleton with `README.md`, `starter/`, `solution/` per module; root `CLAUDE.md` under 80 lines; module-scoped `.claude/settings.json` examples for modules 1, 6, 9
**Addresses:** Module-aligned workspace folders, module-scoped settings.json examples, module navigation (Pitfall 7)
**Avoids:** CLAUDE.md cognitive overload (Pitfall 3), one giant CLAUDE.md anti-pattern (ARCHITECTURE.md)
**Research flag:** Standard patterns — module folder conventions are well-established; CLAUDE.md architecture is documented

### Phase 4: Module CLAUDE.md Files and Progressive Disclosure
**Rationale:** Module-specific CLAUDE.md files are the core teaching mechanic. They must layer on the root CLAUDE.md established in Phase 3. The `start.sh` session launcher that writes the dynamic session CLAUDE.md depends on knowing the module structure and CLAUDE.md format — it is the last infrastructure piece to build.
**Delivers:** Module CLAUDE.md files for modules 1, 4, 8 (minimum); completed `start.sh` with module-context injection; progressive skill-access logic in session CLAUDE.md template
**Implements:** Progressive CLAUDE.md Disclosure pattern (ARCHITECTURE.md Pattern 2), Module-Scoped Workspace Isolation pattern (Pattern 3)
**Research flag:** May benefit from research-phase — the exact structure of instructional CLAUDE.md comments (teaching-through-config) is not well-documented in community; worth testing with a real beginner before scaling to all 9 modules

### Phase 5: README and Cross-Platform Polish
**Rationale:** The README is the first impression and cannot be an afterthought. Windows support (PowerShell installer) requires explicit testing on a fresh Windows machine and is best added after the core installer is validated on macOS/Linux. The license and upgrade documentation are deferred here as they only make sense once all other files exist.
**Delivers:** README with 5-step first-run flow, `SETUP.md` per OS, PowerShell installer with self-fixing execution policy check, MIT license
**Addresses:** README with clear first-step instructions, cross-platform setup (Windows path)
**Avoids:** PowerShell execution policy blocking Windows students (Pitfall 8)
**Research flag:** Windows PowerShell patterns are well-documented; no additional research needed

### Phase Ordering Rationale

- **Installer before content:** Every other phase's work gets deployed by `install.sh`. A broken installer discovered after module content is built means rework at the worst time.
- **Global config before modules:** Modules reference skills and agents by name. Those files must exist before READMEs can say "use `/lah-explain-code` on this file."
- **Structure before content:** The CLAUDE.md architecture decision (how many lines, what goes in the root vs. module files) is cheaper to change before content is written into it.
- **Infrastructure before polish:** README and Windows support are the last mile — meaningful to ship once the core experience is verified on the primary platform.
- **Dependency chain:** `global-config/` → `install.sh` (test with real content) → `modules/` skeleton → root `CLAUDE.md` → `start.sh` (needs module names) → module content (parallel per module)

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 4 (Module CLAUDE.md + Progressive Disclosure):** The instructional comment style — teaching through config comments — is a novel format with no established community patterns. Test with one real beginner before committing the approach to all 9 modules.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Installer Foundation):** Shell merge scripting, idempotency patterns, and npm prefix checks are all well-documented with concrete examples.
- **Phase 2 (Global Config Content):** All Claude Code extension frontmatter specs are fully documented in official docs at HIGH confidence.
- **Phase 3 (Module Structure):** Module folder conventions follow established course kit patterns (Wes Bos, KCD). CLAUDE.md length limits are documented by Anthropic.
- **Phase 5 (README + Cross-Platform):** PowerShell execution policy self-fix is a single documented command; README conventions are standard.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All Claude Code extension formats verified against official docs (code.claude.com); brownfield scaffold inspected directly; version compatibility confirmed |
| Features | HIGH | Table stakes derived from live competitor repos (Wes Bos, KCD, fCC); differentiators verified against official Claude Code docs; anti-features validated through community patterns |
| Architecture | HIGH | Three-layer separation, merge patterns, and progressive disclosure verified against official docs and direct inspection of `~/.claude/` on this machine; shell scripting patterns MEDIUM |
| Pitfalls | HIGH | Critical pitfalls backed by official npm docs, official Claude Code docs, and Microsoft PowerShell docs; installer patterns verified against community projects |

**Overall confidence:** HIGH

### Gaps to Address

- **Shell installer cross-platform edge cases:** POSIX compatibility on Windows Git Bash and fish shell is not fully tested in research. During Phase 1, run the installer explicitly in bash, zsh, and (if possible) WSL2 bash before declaring it done.
- **Claude Code CLI minimum version requirements:** Research confirmed hook events and frontmatter fields but did not establish the minimum Claude Code CLI version required for all features to work. Add a `claude --version` check in the installer with a minimum version floor.
- **`start.sh` module-name lookup function:** The `get_module_name` function referenced in ARCHITECTURE.md is described but not implemented. This lookup (module number → directory name) is a small but tricky piece of `start.sh` that needs a concrete implementation decision before the session launcher is built.
- **Windows user share:** FEATURES.md recommends deferring the PowerShell path until course analytics confirm Windows users. For v1, document WSL2 as the Windows path rather than building a full PowerShell installer — revisit after first cohort.

---

## Sources

### Primary (HIGH confidence)
- [Claude Code — Create custom subagents](https://code.claude.com/docs/en/sub-agents) — agent frontmatter spec, tool control, memory, hooks
- [Claude Code — Extend Claude with skills](https://code.claude.com/docs/en/skills) — skills frontmatter spec, file locations, invocation modes
- [Claude Code — Hooks reference](https://code.claude.com/docs/en/hooks) — all hook events, exit codes, handler types
- [Claude Code — Connect via MCP](https://code.claude.com/docs/en/mcp) — mcpServers format, .mcp.json location
- [Claude Code — Settings documentation](https://code.claude.com/docs/en/settings) — config hierarchy, array merge behavior
- [Claude Code — Best Practices](https://code.claude.com/docs/en/best-practices) — CLAUDE.md length guidance, pruning discipline
- [npm EACCES permissions — official npm docs](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally/) — root cause and official solutions
- [PowerShell Execution Policies — Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies) — default Restricted policy, RemoteSigned recommendation
- Direct inspection of `~/.claude/settings.json` and existing project `package.json` — first-party source

### Secondary (MEDIUM confidence)
- [KCD web-app-fundamentals GitHub](https://github.com/epicweb-dev/web-app-fundamentals) — exercise structure patterns
- [Wes Bos Learn-Node](https://github.com/wesbos/Learn-Node) — starter/solution pattern
- [The Decipherist Starter Kit](https://github.com/TheDecipherist/claude-code-mastery-project-starter-kit) — non-destructive merge installer pattern
- [serpro69/claude-starter-kit](https://github.com/serpro69/claude-starter-kit) — `lah-*` prefix namespacing pattern
- [Progressive disclosure for CLAUDE.md — alexop.dev](https://alexop.dev/posts/stop-bloating-your-claude-md-progressive-disclosure-ai-coding-tools/) — file-reference pattern to avoid context bloat
- [Claude Code Setup Guide 2026 — okhlopkov.com](https://okhlopkov.com/claude-code-setup-mcp-hooks-skills-2026/) — ecosystem overview
- [How to write idempotent Bash scripts — arslan.io](https://arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts/) — conditional check patterns

### Tertiary (LOW confidence / for design philosophy reference)
- [create-t3-app design philosophy](https://create.t3.gg/en/faq) — "What's next" / UPGRADING.md philosophy
- [Developer onboarding — why developers never finish — daily.dev](https://business.daily.dev/resources/why-developers-never-finish-your-onboarding-and-how-to-fix-it/) — 81% information overwhelm statistic

---
*Research completed: 2026-03-10*
*Ready for roadmap: yes*
