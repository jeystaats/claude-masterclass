# Stack Research

**Domain:** Developer education starter kit — Claude Code extensions + Next.js scaffold
**Researched:** 2026-03-10
**Confidence:** HIGH (official docs verified for all Claude Code extension formats; MEDIUM for shell scripting patterns)

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Next.js | 16.x | App scaffold for course project | Turbopack now stable as default, React Compiler stable at 1.0, "use cache" directive replaces old caching model — the brownfield scaffold already runs this, no migration needed |
| React | 19.2 | UI runtime | Bundled with Next.js 16; View Transitions and Activity component are new in 19.2 — course content on these is immediately relevant |
| Tailwind CSS | 4.x | Styling | CSS-first config (no tailwind.config.js needed), @theme for design tokens, Oxide engine (Rust-based) makes incremental builds >100x faster — brownfield already uses v4 |
| TypeScript | 5.x | Type safety | Strict mode enforced by existing project; required for React Compiler to work correctly |
| Bash (POSIX-compatible) | n/a | macOS/Linux installer + start.sh | No runtime dependency to install, runs on every Unix-like system out of the box; keep POSIX-compatible, avoid bash 4+ features |
| PowerShell | 5.1+ | Windows installer | Runs on Windows natively, also available on macOS/Linux as pwsh — enables true cross-platform coverage without third-party tools |

### Claude Code Extension Formats

All formats verified against official docs at code.claude.com as of March 2026.

| Format | File Location | File Format | Purpose | Confidence |
|--------|--------------|-------------|---------|------------|
| Skills | `~/.claude/skills/<name>/SKILL.md` (user) or `.claude/skills/<name>/SKILL.md` (project) | Markdown with YAML frontmatter | Reusable slash commands and background knowledge; invoked as `/skill-name` | HIGH |
| Agents (subagents) | `~/.claude/agents/<name>.md` (user) or `.claude/agents/<name>.md` (project) | Markdown with YAML frontmatter | Specialized AI assistants with custom tools, model, permissions | HIGH |
| Hooks | `~/.claude/settings.json` (user) or `.claude/settings.json` (project) | JSON, `"hooks"` key in settings | Lifecycle event handlers — pre/post tool, session start/end, etc. | HIGH |
| MCP servers | `.mcp.json` (project) or `~/.claude.json` (global) | JSON, `"mcpServers"` key | External service connectors (GitHub, databases, APIs, browsers) | HIGH |
| CLAUDE.md | `~/.claude/CLAUDE.md` (global), `CLAUDE.md` (project root) | Plain Markdown | Always-loaded context and instructions for every session | HIGH |

### Skills Frontmatter Fields

Source: official docs, code.claude.com/docs/en/skills

| Field | Required | Values | Notes |
|-------|----------|--------|-------|
| `name` | No | lowercase, hyphens, max 64 chars | Becomes the `/slash-command`; defaults to directory name |
| `description` | Recommended | string | Claude uses this to auto-invoke when relevant |
| `disable-model-invocation` | No | `true`/`false` (default false) | Set `true` for deploy/commit flows the user must trigger manually |
| `user-invocable` | No | `true`/`false` (default true) | Set `false` for background knowledge only |
| `allowed-tools` | No | `Read, Grep, Glob, Bash` etc. | Grants those tools without per-use approval |
| `model` | No | `sonnet`, `opus`, `haiku`, or omit | Defaults to session model |
| `context` | No | `fork` | Runs skill in an isolated subagent |
| `agent` | No | agent name | Used with `context: fork` |
| `argument-hint` | No | string | Shown in autocomplete: `[issue-number]` |
| `hooks` | No | hook config object | Scoped to this skill's lifecycle |

### Agents (Subagents) Frontmatter Fields

Source: official docs, code.claude.com/docs/en/sub-agents

| Field | Required | Values | Notes |
|-------|----------|--------|-------|
| `name` | Yes | lowercase, hyphens | Unique identifier |
| `description` | Yes | string | When Claude should delegate to this agent |
| `tools` | No | comma-separated tool names | Inherits all if omitted; use `Agent(name)` to restrict spawnable sub-agents |
| `disallowedTools` | No | comma-separated | Denylist approach |
| `model` | No | `sonnet`, `opus`, `haiku`, `inherit` | Defaults to `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` | Override permission behavior |
| `maxTurns` | No | integer | Cap agentic turns |
| `skills` | No | list of skill names | Full content injected at startup (not inherited from parent) |
| `mcpServers` | No | list of server names or inline configs | Agents do NOT inherit MCP from parent |
| `hooks` | No | hook config object | Scoped to this agent only |
| `memory` | No | `user`, `project`, `local` | Cross-session persistent memory |
| `background` | No | `true`/`false` | Always run as background task |
| `isolation` | No | `worktree` | Isolated git worktree |
| `color` | No | color string | UI badge color |

### Hooks Configuration

Source: official docs, code.claude.com/docs/en/hooks

Hook events (in order through session lifecycle):

| Event | When | Matcher Target |
|-------|------|---------------|
| `SessionStart` | Session begins or resumes | startup, resume, clear, compact |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | (no matcher) |
| `UserPromptSubmit` | Before Claude processes prompt | (no matcher) |
| `PreToolUse` | Before tool call — can block | tool name (regex) |
| `PermissionRequest` | Permission dialog appears | tool name |
| `PostToolUse` | After tool succeeds | tool name |
| `PostToolUseFailure` | After tool fails | tool name |
| `SubagentStart` | Subagent spawned | agent type name |
| `SubagentStop` | Subagent finishes | agent type name |
| `Stop` | Claude finishes responding | (no matcher) |
| `TaskCompleted` | Task being marked complete | (no matcher) |
| `TeammateIdle` | Agent team member going idle | (no matcher) |
| `PreCompact` | Before context compaction | manual, auto |
| `WorktreeCreate` | Worktree being created | (no matcher) |
| `WorktreeRemove` | Worktree being removed | (no matcher) |
| `ConfigChange` | Config file changes mid-session | config source |
| `SessionEnd` | Session terminates | clear, logout, prompt_input_exit, etc. |

Hook handler types: `"command"` (shell script via stdin), `"http"` (POST to URL), `"prompt"` (single-turn LLM eval), `"agent"` (spawns subagent with tools).

Exit code behavior for command hooks:
- Exit 0: allow/continue
- Exit 2: block tool call with stderr message fed back to Claude
- Any other non-zero: non-blocking error, execution continues

### MCP Configuration Format

Source: official docs, code.claude.com/docs/en/mcp; GitHub issues confirming .mcp.json location

```json
// .mcp.json (project-scoped, committed to git)
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

### Supporting Libraries (app scaffold only)

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| shadcn/ui | latest | Accessible component primitives | All interactive UI components |
| class-variance-authority (CVA) | ^0.7 | Typed component variants | Any component with 3+ visual variants |
| tailwind-merge | ^3.5 | Resolves conflicting Tailwind classes | Always via `cn()` wrapper |
| clsx | ^2.1 | Conditional className logic | Always via `cn()` wrapper |
| Convex | ^1.32 | Realtime backend + DB | Already in scaffold |
| Clerk | ^6.x | Auth | Already in scaffold |
| Zod | ^3.x | Runtime validation | All form inputs and API boundaries |
| Husky | ^9.x | Git hooks | Pre-commit type checking |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| pnpm | Package manager | Monorepo workspaces; `packageManager` pinned in package.json |
| Turborepo | Monorepo build orchestration | Already configured; `turbo dev` runs all packages |
| shellcheck | Shell script linter | Install via `brew install shellcheck`; catches bash portability issues |
| shfmt | Shell script formatter | Install via `brew install shfmt`; enforce consistent style |
| jq | JSON parsing in shell scripts | Required for hook scripts that read stdin JSON from Claude Code |

---

## Installation

The starter kit is distributed as a zip/git archive and installed via shell scripts, not via npm. No npm install step is needed for the kit itself.

```bash
# For the app scaffold (brownfield — already initialized)
pnpm install

# Development
pnpm dev          # all packages via Turborepo
pnpm typecheck    # TypeScript check across monorepo
pnpm storybook    # DLS storybook at localhost:6006
```

```bash
# Installer dependencies (need to be available on PATH)
brew install jq shellcheck shfmt  # macOS
```

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Bash installer (POSIX) | Node.js/npx installer (like `create-next-app`) | When the scaffold requires complex config generation — node is heavier but allows JSON manipulation without jq; avoid for a course kit where the script IS the teaching |
| PowerShell for Windows | WSL-only on Windows | If the course explicitly drops Windows support; risky for a paid course, PowerShell covers native Windows |
| Skills in `.claude/skills/` | Commands in `.claude/commands/` | Commands still work but Skills are the forward-looking format; they support supporting files, frontmatter, and `context: fork` |
| `.mcp.json` for MCP config | Adding to `~/.claude/settings.json` | `.mcp.json` at project root is version-controlled and shareable — correct for a starter kit |
| Turbopack (Next.js 16 default) | Webpack | Webpack still works but is not the default for new projects; no reason to revert |
| Tailwind v4 CSS-first config | `tailwind.config.js` | `tailwind.config.js` still works but CSS-first @theme is the v4 way — starter kit should demonstrate the new pattern |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `#!/bin/bash` with bash 4+ features (associative arrays, etc.) | macOS ships bash 3.2 by default due to GPLv3; bash 4+ features will fail silently or error on stock macOS | POSIX `sh` features, or detect and install bash 5 explicitly |
| `curl \| bash` one-liner as the only install method | Security theater — many developers won't run it; also bypasses any code review | Provide the curl-pipe as convenience option alongside a "clone and run" alternative |
| Global npm packages in the installer | Requires npm/node to be pre-installed, and pollutes global namespace | Keep the installer pure shell + system tools |
| `Task` in agent frontmatter | Renamed to `Agent` in Claude Code v2.1.63 — still works as alias but confusing in course material | Use `tools: Agent(name)` syntax |
| Multiple CLAUDE.md files at root without clear hierarchy | Claude loads the nearest CLAUDE.md per directory; overlapping instructions cause unpredictable behavior | One root CLAUDE.md + module-level CLAUDE.md files with explicit scope notes |
| Hardcoded API keys in `.mcp.json` | Gets committed to git | Use `${ENV_VAR}` interpolation in mcpServers config |
| Writing hook scripts inline in settings.json | Unmaintainable, no syntax highlighting, no chmod | Put scripts in `.claude/hooks/`, reference by path in settings.json |

---

## Stack Patterns by Variant

**If building a macOS-only course:**
- Drop PowerShell; bash installer with `set -euo pipefail` is sufficient
- Can use bash 4+ features if installer explicitly checks `bash --version`

**If building for enterprise/team distribution:**
- Use Plugin format (not covered in this starter kit scope) to bundle agents+skills+hooks together
- Managed settings via org policy instead of user settings

**If course teaches API/backend work:**
- Add MCP servers: `@modelcontextprotocol/server-github` for GitHub, filesystem server for file ops
- Context7 HTTP MCP for library docs lookups

**If module needs isolated sandbox:**
- Use `isolation: worktree` in agent frontmatter to give each subagent a fresh git worktree
- Pair with `pnpm typecheck` PostToolUse hook to catch type errors immediately

---

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| Next.js 16.x | React 19.2, Turbopack stable | React Compiler now stable in 16.x, was opt-in in 15.x |
| Tailwind v4.x | Vite, PostCSS; no tailwind.config.js | First-party Vite plugin for tight integration; `@import "tailwindcss"` replaces `@tailwind` directives |
| Claude Code skills | Current `~/.claude/skills/` format | `.claude/commands/` still works but Skills are the canonical format going forward |
| Claude Code hooks | `settings.json` format | `Task(...)` tool reference still works as alias for `Agent(...)` — prefer `Agent` in new files |
| Husky 9.x | pnpm 9.x | `prepare: husky` in package.json scripts |
| jq | Any POSIX shell | Required in hook scripts to parse Claude Code's stdin JSON; `brew install jq` on macOS |

---

## Key Architectural Decisions for the Starter Kit

These are not library choices but structural decisions that feed into architecture planning:

**1. Global vs. project-scoped Claude extensions**
The course teaches `~/.claude/` (user-level, always available) for personal productivity tools, and `.claude/` (project-level, committed to git) for project-specific automation. The starter kit installs into `~/.claude/` only — each module scaffold adds project-level files separately.

**2. CLAUDE.md as the primary teaching artifact**
The `CLAUDE.md` at project root is the course's primary reference document. Each module adds its own CLAUDE.md section or sub-file. Claude loads these automatically — no slash command needed to activate course context.

**3. Skills vs. hooks distinction**
Skills are for "what Claude should do" (methodology, patterns, best practices). Hooks are for "what must always happen" (enforcement, quality gates). The course should teach this distinction explicitly. Use `disable-model-invocation: true` for hooks-like flows (deploy, commit) that should only fire when user explicitly triggers them.

**4. Shell installer philosophy**
The installer is teaching material as much as a functional script. Write it to be readable: `set -euo pipefail`, clear section headers with `echo`, no magic one-liners. Idempotent (safe to run multiple times). Dry-run mode via `--dry-run` flag.

---

## Sources

- [Claude Code — Create custom subagents](https://code.claude.com/docs/en/sub-agents) — agent frontmatter spec, tool control, memory, hooks — HIGH confidence
- [Claude Code — Extend Claude with skills](https://code.claude.com/docs/en/skills) — skills frontmatter spec, file locations, invocation modes — HIGH confidence
- [Claude Code — Hooks reference](https://code.claude.com/docs/en/hooks) — all 17 hook events, settings.json format, exit codes, handler types — HIGH confidence
- [Claude Code — Connect via MCP](https://code.claude.com/docs/en/mcp) — mcpServers config format, .mcp.json location — HIGH confidence
- [Next.js 16 release notes](https://nextjs.org/blog/next-16) — Turbopack stable, React Compiler stable, React 19.2, "use cache" directive — HIGH confidence
- [Tailwind CSS v4.0 release](https://tailwindcss.com/blog/tailwindcss-v4) — CSS-first config, Oxide engine, @theme, stable Jan 2025 — HIGH confidence
- [Claude Code Setup Guide 2026](https://okhlopkov.com/claude-code-setup-mcp-hooks-skills-2026/) — ecosystem overview, corroborates official docs — MEDIUM confidence
- [Claude Code to AI OS Blueprint](https://dev.to/jan_lucasandmann_bb9257c/claude-code-to-ai-os-blueprint-skills-hooks-agents-mcp-setup-in-2026-46gg) — CLAUDE.md → Skills → Hooks → Agents layering model — MEDIUM confidence
- Existing project `package.json` — pnpm 9.15.9, Turborepo 2.5, Husky 9, TypeScript 5, Next.js 16.1.6, Convex 1.32.0 — HIGH confidence (direct inspection)

---

*Stack research for: Claude Code Mastery companion starter kit*
*Researched: 2026-03-10*
