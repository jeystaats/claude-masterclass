# Phase 3: Module Structure and CLAUDE.md - Research

**Researched:** 2026-03-10
**Domain:** Claude Code CLAUDE.md authoring, course module structure, progressive CLAUDE.md complexity
**Confidence:** HIGH

---

## Summary

Phase 3 creates the visible skeleton students interact with every session: nine module folders they browse in their editor, a root CLAUDE.md that teaches while guiding, and module-scoped CLAUDE.md files that demonstrate progressive complexity. All three pieces feed into Phase 4 (start.sh), so folder names must be exact and stable.

The canonical nine module slugs were verified directly from `seed.constants.ts` — the single source of truth for the platform's curriculum. The CLAUDE.md `@import` syntax was verified against current official docs at code.claude.com. The existing root CLAUDE.md in the starter kit references an outdated stack (Next.js 15, Tailwind 3.4) and must be replaced.

**Primary recommendation:** Use the exact slugs from seed.constants.ts as folder names, numbered with zero-padding (`01-getting-started` through `09-commands-and-resources`). Write the root CLAUDE.md from scratch (the existing file is 280+ lines — too long and wrong stack). Use `@` imports to offload the stack reference tables and rules details into sub-files, keeping root under 80 lines.

---

## Key Research Finding: Canonical Module Order

Sourced directly from `/Users/jasperstaats/Documents/Klanten/likeahuman/platform/apps/claude-mastery/convex/seed.constants.ts` — the authoritative module registry.

| # | Folder name | Slug | Display title |
|---|-------------|------|---------------|
| 01 | `01-getting-started` | `getting-started` | Getting Started |
| 02 | `02-think-like-an-engineering-lead` | `think-like-an-engineering-lead` | Think Like an Engineering Lead |
| 03 | `03-ai-agents-and-automation` | `ai-agents-and-automation` | Meet Your AI Team |
| 04 | `04-plan-your-product` | `plan-your-product` | Research & Plan Your Product |
| 05 | `05-design-and-components` | `design-and-components` | Design & Components |
| 06 | `06-build-your-app` | `build-your-app` | Build Your App |
| 07 | `07-deploy-and-ship` | `deploy-and-ship` | Deploy & Ship |
| 08 | `08-expert-pro` | `expert-pro` | Expert Pro |
| 09 | `09-commands-and-resources` | `commands-and-resources` | Commands & Resources |

**Critical for Phase 4:** start.sh reads these folder names to present module selection. They must match this table exactly. The display title (shown to students) differs from the slug for modules 3, 4 — use the display title in README.md headings and the slug for the folder name.

---

## Lesson Inventory Per Module

Sourced from `seed.constants.ts` (canonical) and cross-checked against file system at `content/modules/`. Lessons are ordered by their `order` field.

### Module 01: Getting Started (5 lessons)
0. Terminal Basics [text, 15 min]
1. Setup & Installation [exercise, 10 min]
2. AI Fundamentals [text, 15 min]
3. Choosing Your Project Idea [text, 8 min]
4. Your First Conversation [text, 20 min]

### Module 02: Think Like an Engineering Lead (9 lessons)
0. The 8 Tentacles of Claude Code [text, 15 min]
1. The Claude Ecosystem [text, 12 min]
2. The Safety Net (4 Levels of Git Recovery) [text, 10 min]
3. The Status Line & Cost Control [text, 10 min]
4. Engineering Lead Mindset [text, 12 min]
5. PRDs, Epics & Tickets [text, 12 min]
6. How Claude Thinks (Prompt Engineering) [text, 18 min]
7. CLAUDE.md Mastery [exercise, 15 min]
8. Context Management & Memory [text, 12 min]

### Module 03: Meet Your AI Team (6 lessons)
0. What Are Agents? [text, 15 min]
1. Building Custom Agents [exercise, 25 min]
2. Skills, Hooks & MCP [text, 20 min]
3. Connecting Your Tools [exercise, 25 min]
4. Spawning Specialist Agents [exercise, 20 min]
5. Automation Pipelines [exercise, 20 min]

### Module 04: Research & Plan Your Product (6 lessons)
0. Market Research with Claude [exercise, 15 min]
1. Writing a PRD [exercise, 18 min]
2. Creating Your Tickets [exercise, 15 min]
3. Architecture & Tech Stack [text, 20 min]
4. Database Design [exercise, 15 min]
5. Project Scaffolding [exercise, 10 min]

### Module 05: Design & Components (6 lessons)
0. Design Inspiration & Visual DNA [text, 15 min]
1. Design System Setup [exercise, 18 min]
2. Component Library [exercise, 25 min]
3. Responsive Layouts [text, 15 min]
4. Animations & Interactions [text, 20 min]
5. Visual Polish & The Magazine Test [exercise, 20 min]

### Module 06: Build Your App (6 lessons)
0. From Plan to Code [text, 15 min]
1. Agent-Driven Development [exercise, 25 min]
2. Parallel Worktrees [exercise, 20 min]
3. Maintaining Consistency [text, 18 min]
4. Review & Iterate [exercise, 20 min]
5. Shipping Your MVP [exercise, 15 min]

### Module 07: Deploy & Ship (5 lessons)
0. Environment Setup [text, 12 min]
1. Deploying to Vercel [exercise, 15 min]
2. Domain & DNS [text, 10 min]
3. Monitoring & Analytics [text, 15 min]
4. Launch Checklist [text, 12 min]

### Module 08: Expert Pro (7 lessons) — Pro/VIP only
0. Advanced Prompting Patterns [text, 20 min]
1. Multi-Agent Orchestration [exercise, 25 min]
2. Custom MCP Servers [exercise, 30 min]
3. Production-Grade CLAUDE.md [exercise, 20 min]
4. AI Code Review Pipeline [exercise, 25 min]
5. Performance Optimization [text, 20 min]
6. Enterprise Patterns [text, 20 min]

### Module 09: Commands & Resources (3 lessons) — Reference section
0. Slash Commands [text, 10 min]
1. Keyboard Shortcuts [text, 5 min]
2. Curated Tools & MCP Servers [text, 10 min]

---

## CLAUDE.md @import Syntax

Source: official docs at code.claude.com/docs/en/memory (verified 2026-03-10)

### Syntax

```text
@path/to/file.md
```

Both relative and absolute paths are supported. Relative paths resolve relative to the file containing the import (not the working directory). Works anywhere in the file — inline or on its own line.

### Examples

```text
# Stack reference
@.claude/stack.md

# Personal preferences (not checked in)
@~/.claude/my-project-instructions.md

# Inline reference
See @README for project overview and @package.json for available npm commands.
```

### Constraints (verified)
- Maximum import depth: 5 hops (imported files can themselves import)
- First-time external imports (outside project directory) show an approval dialog
- The `@path` is expanded inline at load time — imported content is part of context
- VSCode extension has a known bug where @imports don't load (CLI unaffected)
- Relative paths resolve from the file containing the import, not cwd

### @import vs .claude/rules/

| Use | Mechanism |
|-----|-----------|
| Splitting one long CLAUDE.md into sub-files | `@import` |
| Scoping rules to specific file types | `.claude/rules/*.md` with frontmatter `paths:` |
| Lazy-loading instructions only when working in a subdirectory | Place CLAUDE.md in that subdirectory |

For this phase, `@import` is the right tool: the root CLAUDE.md delegates stack details and rule details to sub-files, keeping root under 80 lines.

---

## Subdirectory CLAUDE.md Scoping

Source: official docs (verified 2026-03-10)

CLAUDE.md files in subdirectories load on demand — not at launch. Claude loads them when it reads files in those subdirectories. This means:

- `modules/01-getting-started/.claude/CLAUDE.md` loads when Claude works in that module folder
- Students don't see module-9 rules until they're actually in module 9
- This is the correct pattern for progressive complexity

Placement: the docs say CLAUDE.md can be at `./CLAUDE.md` or `./.claude/CLAUDE.md` within any directory. For modules, `.claude/CLAUDE.md` inside each module folder is cleaner (keeps the folder tidy) and avoids confusion with README.md.

---

## Existing Starter Kit CLAUDE.md — Status

The file at `/tmp/claude-masterclass/CLAUDE.md` exists and is ~280 lines. It has two problems that require a full rewrite rather than edits:

1. **Wrong stack:** References Next.js 15, Tailwind 3.4+. Requirements specify Next.js 16, React 19, Tailwind v4, TypeScript 5.
2. **Too long:** At 280+ lines it exceeds the 80-line constraint (CMD-01) by 3.5x. It cannot be trimmed — it must be restructured with @imports.

**Decision:** Write root CLAUDE.md from scratch. Archive or ignore the existing file. The new file will be the teaching artifact.

---

## Architecture Patterns

### Module Folder Structure

```
modules/
├── 01-getting-started/
│   ├── README.md              # Objectives + lesson list (MOD-02)
│   ├── PROGRESS.md            # Checklist for student to tick off (MOD-04)
│   └── .claude/
│       └── CLAUDE.md          # Module-scoped rules (module 1 only per requirements)
│
├── 02-think-like-an-engineering-lead/
│   ├── README.md
│   └── PROGRESS.md
│
├── 05-design-and-components/
│   ├── README.md
│   ├── PROGRESS.md
│   └── .claude/
│       └── CLAUDE.md          # Module-scoped rules (module 4 = folder 05)
│
└── 09-commands-and-resources/
    ├── README.md
    ├── PROGRESS.md
    └── .claude/
        └── CLAUDE.md          # Module-scoped rules (module 9 per requirements)
```

**Important naming clarification:** The requirements say "modules 1, 4, and 9" for module-scoped CLAUDE.md files. In folder numbering: module 1 = `01-getting-started`, module 4 = `04-plan-your-product`, module 9 = `09-commands-and-resources`. The exercise files go in modules 1, 4, and 6 (folders 01, 04, 06) — note this is different from the CLAUDE.md module-scoped files.

Wait — re-reading requirements: "module-scoped .claude/CLAUDE.md files exist for modules 1, 4, and 9". This maps to:
- Module 1 = folder `01-getting-started`
- Module 4 = folder `04-plan-your-product`
- Module 9 = folder `09-commands-and-resources`

And exercise files for modules 1, 4, 6:
- Module 1 = folder `01-getting-started`
- Module 4 = folder `04-plan-your-product`
- Module 6 = folder `06-build-your-app`

### Root CLAUDE.md Structure (under 80 lines)

```
CLAUDE.md                      # Root — under 80 lines, @imports everything detailed
.claude/
├── stack.md                   # Stack table (Next.js 16, React 19, etc.)
├── rules.md                   # Full coding standards
└── workflow.md                # Command reference and workflow patterns
```

The root CLAUDE.md headers each section with a one-liner explaining WHY the rule exists, then delegates detail to imports:

```markdown
# Claude Code Mastery — Workshop Guide

## Stack
<!-- Why: You need consistent technology decisions so Claude doesn't suggest Redux or NextAuth -->
@.claude/stack.md

## Coding Standards
<!-- Why: Rules that Claude reads literally — be specific, not aspirational -->
@.claude/rules.md
```

---

## Starter Exercise Files

### Module 01 (Getting Started) — appropriate exercises

Module 1's exercise lesson is "Setup & Installation" (order 1) and "Your First Conversation" (order 4). A good starter exercise file:
- A simple `hello.ts` that students ask Claude to extend (low barrier)
- A `first-prompt.md` with a structured prompt template students fill in

### Module 04 (Plan Your Product) — appropriate exercises

Module 4's exercises are all planning artifacts: market research, PRD, tickets, database design, scaffolding. A good starter exercise file:
- `RESEARCH.md` — a template students populate with Claude's help
- `PRD.md` — a skeleton PRD with instructional comments showing the format

### Module 06 (Build Your App) — appropriate exercises

Module 6 is the main build phase. Exercise lessons: agent-driven development, parallel worktrees, review & iterate, shipping MVP. A good starter exercise file:
- `PLAN.md` — a ticket list template students work through with agents
- `feature-brief.md` — a concise feature description format that works well with Claude agents

---

## Progressive CLAUDE.md Complexity Pattern

Requirements: module 1 = ~10 rules, module 4 = intermediate, module 9 = full engineering standards.

### Module 01 CLAUDE.md (10 rules, beginner-safe)

Focus: what NOT to do, stack identity, one workflow rule. No jargon. No TypeScript patterns. Just enough to stop Claude from going off-piste.

```markdown
# Module 1: Getting Started

You are helping a beginner learn Claude Code.

## The stack we use
- Next.js 16 (App Router)
- TypeScript 5
- Tailwind CSS v4
- React 19

## Rules (keep it simple)
- Never suggest alternatives to the stack above
- When the user makes a mistake, explain what happened before fixing it
- Prefer short, working examples over elegant abstractions
- Ask one question at a time — don't overwhelm beginners
- Use comments in code to explain each non-obvious line
- Don't use advanced TypeScript (no generics, no utility types yet)
- Keep components under 50 lines while teaching
- Always explain WHY before HOW
- Celebrate small wins explicitly
- If unsure, show the simple path first
```

### Module 04 CLAUDE.md (intermediate, planning focus)

Adds: TypeScript patterns, planning workflow, architecture decisions. Drops the hand-holding tone.

### Module 09 CLAUDE.md (full engineering standards)

Mirrors what a production CLAUDE.md looks like: all TypeScript standards, testing requirements, performance rules, security, code review checklist. This is the capstone teaching artifact.

---

## Common Pitfalls

### Pitfall 1: Module numbering mismatch between folders and "module N" in requirements
**What goes wrong:** The requirements say "module 4" but there are 9 modules starting from 0 in the platform. The platform uses zero-indexed orders internally (M0-M8) but students count from 1.
**How to avoid:** Always use 1-indexed human names in documentation ("Module 4 = Design & Components") with folder `05-design-and-components`. This research resolves the ambiguity: requirements "module 4" = folder `04-plan-your-product` (1-indexed student counting, not platform's internal order).

**Resolved mapping:**
- "Module 1" (requirements) → platform order 0 → folder `01-getting-started`
- "Module 4" (requirements) → platform order 3 → folder `04-plan-your-product`
- "Module 6" (requirements) → platform order 5 → folder `06-build-your-app`
- "Module 9" (requirements) → platform order 8 → folder `09-commands-and-resources`

### Pitfall 2: Root CLAUDE.md exceeds 80 lines if not disciplined
**What goes wrong:** Stack tables, workflow rules, and coding standards easily reach 150+ lines. The 80-line constraint is real (official docs recommend under 200 lines for adherence; we need 80 as a teaching constraint).
**How to avoid:** The root file must ONLY contain: preamble (5 lines), one-liner per section with WHY comment, and @import reference. All detail goes into imported files.

### Pitfall 3: @import paths break when students clone to different directories
**What goes wrong:** Absolute paths in @imports (e.g., `/Users/jasper/...`) break for every student.
**How to avoid:** All @imports in CLAUDE.md must use relative paths (e.g., `@.claude/stack.md`). Relative paths resolve from the file's location, not cwd.

### Pitfall 4: module-scoped CLAUDE.md files conflict with root
**What goes wrong:** Module 9's full engineering standards include rules that contradict module 1's "keep it simple" rules when both are loaded.
**How to avoid:** Module-scoped CLAUDE.md files should begin with `<!-- Overrides root CLAUDE.md for this module -->` and explicitly restate any rule they change. Claude loads both; being explicit prevents arbitrary tie-breaking.

### Pitfall 5: PROGRESS.md checkboxes that can't be checked
**What goes wrong:** Markdown checkboxes (`- [ ]`) are visual only — students can't check them in a terminal file view.
**How to avoid:** Include a note at the top of PROGRESS.md: "Edit this file to mark items complete: change `- [ ]` to `- [x]`". This is an expected friction point, not a bug.

---

## Code Examples

### @import in root CLAUDE.md (verified syntax)
```markdown
## Stack (why: tells Claude what to build WITH, not what to choose)
@.claude/stack.md

## Coding rules (why: specific rules Claude can verify, not vague principles)
@.claude/rules.md
```

### Module-scoped CLAUDE.md placement
```
modules/01-getting-started/.claude/CLAUDE.md
```
Claude loads this automatically when working in the `01-getting-started/` directory. No configuration needed.

### PROGRESS.md format
```markdown
# Module 01: Getting Started — Progress

Mark complete by changing `[ ]` to `[x]`

## Lessons
- [ ] Terminal Basics (15 min)
- [ ] Setup & Installation (10 min) [exercise]
- [ ] AI Fundamentals (15 min)
- [ ] Choosing Your Project Idea (8 min)
- [ ] Your First Conversation (20 min) [exercise]

## Exercises
- [ ] Installed Claude Code and verified `claude --version`
- [ ] Completed first conversation with Claude
- [ ] Chose a project idea to build during the course
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| CLAUDE.local.md for personal overrides | `@~/.claude/personal.md` import in project CLAUDE.md | CLAUDE.local.md is deprecated — don't reference it |
| Single monolithic CLAUDE.md | `@import` to split into topic files | Official pattern since mid-2025 |
| Rules in conversation | `.claude/rules/*.md` with path scoping | Cleaner separation, lazy loading |

---

## Open Questions

1. **Module 04 exercise file scope**
   - What we know: Module 4 lessons are all planning exercises (PRD, tickets, architecture). A RESEARCH.md template and PRD.md skeleton are logical choices.
   - What's unclear: How much of the PRD template should be pre-filled vs blank? Too pre-filled = no learning; too blank = overwhelm.
   - Recommendation: Pre-fill section headers and one example entry per section. Students replace examples with real content.

2. **Module-scoped CLAUDE.md load behavior with nested .claude/**
   - What we know: Subdirectory CLAUDE.md files load on demand when Claude reads files in that directory.
   - What's unclear: Whether `.claude/CLAUDE.md` (nested) vs `CLAUDE.md` (at module root) loads identically.
   - Official docs say both `./CLAUDE.md` and `./.claude/CLAUDE.md` are valid — behavior should be identical.
   - Recommendation: Use `.claude/CLAUDE.md` pattern (confirmed valid per docs) and note this in plan verification step.

---

## Sources

### Primary (HIGH confidence)
- `seed.constants.ts` at `/Users/jasperstaats/Documents/Klanten/likeahuman/platform/apps/claude-mastery/convex/seed.constants.ts` — canonical module order, slugs, lesson inventory
- `code.claude.com/docs/en/memory` fetched 2026-03-10 — @import syntax, subdirectory loading behavior, size recommendations, path resolution rules

### Secondary (MEDIUM confidence)
- GitHub issue thread on CLAUDE.md @import (anthropics/claude-code #2950, #6321) — confirmed VSCode extension bug with @imports (CLI unaffected)
- Platform content filesystem at `content/modules/` — cross-checked lesson counts against seed.constants.ts (all match)

---

## Metadata

**Confidence breakdown:**
- Module slugs and order: HIGH — verified from seed.constants.ts
- Lesson inventory: HIGH — verified from both seed.constants.ts and file system
- @import syntax: HIGH — verified from official docs fetched live
- Subdirectory CLAUDE.md scoping: HIGH — documented in official docs
- Exercise file content design: MEDIUM — reasoned from lesson types, not verified against a reference implementation
- Progressive complexity pattern: MEDIUM — based on requirements + general pedagogy, no authoritative external source

**Research date:** 2026-03-10
**Valid until:** 2026-04-10 (stable domain; CLAUDE.md syntax rarely changes)
