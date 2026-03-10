# Claude Code Mastery — Starter Kit Overhaul

## Core Value

A **companion starter kit** that helps students DO the exercises from the Claude Code Mastery course platform. Not a replacement for the course — a hands-on sandbox that makes the platform's lessons tangible.

## What We're Building

Overhaul the `jeystaats/claude-masterclass` GitHub repo to align with the current 9-module course on `academy.likeahuman.ai`. The starter kit should:

1. **Integrate installer scripts** — Port install.sh (macOS/Linux) and install.ps1 (Windows) from the platform so students can bootstrap their environment with one command
2. **Include start.sh** — A session launcher that starts Claude Code with the right config and teaching mode
3. **Module-aligned folder structure** — 9 folders matching course modules so students save work per module
4. **Global agents/hooks/skills** — Install beginner-friendly versions globally (~/.claude/) so they work across all projects, not just this repo
5. **Rich CLAUDE.md** — Best-in-class project brief that teaches while guiding Claude Code
6. **Instructional hooks** — Hooks that teach quality patterns (e.g., "always use cn()") while enforcing them

## The 9 Course Modules

| # | Slug | Lessons |
|---|------|---------|
| 1 | getting-started | terminal-basics, setup-and-installation, ai-fundamentals, choosing-your-project, your-first-conversation |
| 2 | think-like-an-engineering-lead | engineering-lead-mindset, the-claude-ecosystem, the-8-tentacles, the-status-line, the-safety-net, claude-md-mastery, context-management, prompt-engineering, prd-epics-and-tickets |
| 3 | plan-your-product | writing-a-prd, market-research, architecture-and-tech-stack, database-design, creating-your-tickets, project-scaffolding |
| 4 | build-your-app | from-plan-to-code, agent-driven-development, parallel-worktrees, maintaining-consistency, review-and-iterate, shipping-your-mvp |
| 5 | design-and-components | design-system-setup, component-library, design-inspiration-and-visual-dna, responsive-layouts, animations-and-interactions, visual-polish |
| 6 | deploy-and-ship | environment-setup, deploying-to-vercel, domain-and-dns, monitoring-and-analytics, launch-checklist |
| 7 | commands-and-resources | slash-commands, keyboard-shortcuts, curated-tools |
| 8 | ai-agents-and-automation | what-are-agents, spawning-specialist-agents, building-custom-agents, skills-hooks-mcp, connecting-your-tools, automation-pipelines |
| 9 | expert-pro | production-grade-claude-md, advanced-prompting-patterns, multi-agent-orchestration, ai-code-review-pipeline, custom-mcp-servers, performance-optimization, enterprise-patterns |

## Source Repos

- **Starter kit:** github.com/jeystaats/claude-masterclass (this repo)
- **Platform:** /Users/jasperstaats/Documents/Klanten/likeahuman/platform (monorepo with course content, DLS, app)

## Existing State (Brownfield)

The current starter kit has:
- ✓ Next.js 16 + React 19 + TypeScript + Tailwind v4 scaffold
- ✓ Comprehensive CLAUDE.md with tech stack decisions (15.5KB)
- ✓ Workshop-start slash command (interactive 9-step flow)
- ✗ No installer scripts (install.sh/install.ps1)
- ✗ No start.sh session launcher
- ✗ No module folder structure
- ✗ No global agents/hooks/skills installation
- ✗ No beginner-friendly hooks
- ✗ CLAUDE.md references Next.js 15 / Tailwind 3.4 (outdated)
- ✗ No cn() utility installed
- ✗ No .env.example

## Target Audience

Complete beginners to intermediate developers taking the Claude Code Mastery course. Many have never used a terminal before. The starter kit must be:
- **Forgiving** — clear error messages, recovery paths
- **Educational** — hooks/skills that teach, not just enforce
- **Progressive** — simple in Module 1, powerful by Module 9

## Constraints

- Must work on macOS, Windows (PowerShell), and Linux
- Claude Code CLI must be installed (course prerequisite)
- No paid services required beyond Claude Pro subscription
- Installer must be idempotent (safe to re-run)
- Global installs must not conflict with user's existing Claude Code config
- Must stay lightweight — students shouldn't wait 10 minutes for npm install

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Global agent/hook/skill install | Students should benefit across all projects, not just this repo | Install to ~/.claude/ |
| Module folders in project root | Simple flat structure for beginners | /modules/01-getting-started/ etc. |
| Keep Next.js scaffold | Students need a real project to work in | Update to Next.js 16 + Tailwind v4 |
| CLAUDE.md as teaching tool | It's the first file Claude reads — make it instructional | Rich, opinionated, beginner-friendly |
| Hooks that teach | Show WHY a pattern matters, not just reject bad code | Educational error messages |

## Out of Scope

- Course content (lives on the platform)
- Payment/auth integration (platform handles this)
- Production deployment config for the starter kit itself
- Advanced enterprise patterns (covered in Module 9 theory, not starter kit)

---
*Last updated: 2026-03-10 after initialization*
