# Phase 5: Scaffold and Docs - Research

**Researched:** 2026-03-10
**Domain:** Next.js scaffold verification, cn() utility, student-facing documentation
**Confidence:** HIGH

## Summary

Phase 5 is the final polish phase. The hard work is done: the installer, global config, module structure, and session launcher are all complete. This phase verifies the Next.js scaffold works, adds the cn() utility that rules.md already mandates, and replaces the placeholder README with one that gets a first-time student from `git clone` to a running Claude Code session in under 5 minutes.

The scaffold is in better shape than expected. Next.js 16.1.3 + React 19.2.3 + Tailwind v4 are already in package.json with a valid lockfile. The Tailwind v4 CSS-first setup (postcss.config.mjs + `@import "tailwindcss"` in globals.css) is already correct — no tailwind.config.js needed. The App Router structure (src/app/) is in place. The only missing pieces are: (1) clsx and tailwind-merge are not in package.json, so cn() does not exist yet, and (2) the README is a placeholder that references Next.js 15 and workshop commands that don't exist yet.

**Primary recommendation:** Add clsx + tailwind-merge to package.json, create src/lib/utils.ts with the standard cn() implementation, update the README with a real 5-step first-run guide, and write UPGRADING.md. No scaffold rebuild is needed.

## Scaffold Audit — Current State

### What Already Exists (do not rebuild)

| File | Status | Notes |
|------|--------|-------|
| `package.json` | GOOD | next 16.1.3, react 19.2.3, typescript ^5 |
| `package-lock.json` | GOOD | lockfileVersion 3, all core deps locked |
| `next.config.ts` | GOOD | Minimal, valid TS export |
| `postcss.config.mjs` | GOOD | `@tailwindcss/postcss` plugin — correct for v4 |
| `tsconfig.json` | GOOD | Strict mode, `@/*` → `./src/*`, bundler resolution |
| `src/app/globals.css` | GOOD | `@import "tailwindcss"` + `@theme inline` — correct v4 pattern |
| `src/app/layout.tsx` | NEEDS UPDATE | References Geist fonts — replace with system fonts (no external dep) |
| `src/app/page.tsx` | NEEDS UPDATE | Vercel promotional content — replace with clean starter page |
| `.gitignore` | GOOD | Covers .env, node_modules, .DS_Store, Claude Code logs (done in Phase 1) |
| `.env.example` | GOOD | Done in Phase 1 |

### What Is Missing

| Missing | What's Needed |
|---------|---------------|
| `clsx` dependency | Add to package.json dependencies |
| `tailwind-merge` dependency | Add to package.json dependencies |
| `src/lib/utils.ts` | Create with cn() implementation |
| Meaningful `src/app/page.tsx` | Replace Vercel promo page with workshop starter |
| Real README | Replace placeholder with 5-step first-run guide |
| `UPGRADING.md` | New file — personalization guide |

## Standard Stack

### Core (already in package.json)
| Library | Version | Purpose | Status |
|---------|---------|---------|--------|
| next | 16.1.3 | App framework | Installed, locked |
| react | 19.2.3 | UI runtime | Installed, locked |
| react-dom | 19.2.3 | DOM renderer | Installed, locked |
| tailwindcss | ^4 (resolves 4.1.18) | Styling | Installed, locked |
| @tailwindcss/postcss | ^4 (resolves 4.1.18) | PostCSS integration | Installed, locked |
| typescript | ^5 | Language | Installed |

### To Add (missing from package.json)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| clsx | 2.1.1 | Conditional class merging | Industry standard; used by shadcn, every major component library |
| tailwind-merge | 3.5.0 | Resolve Tailwind class conflicts | Required for cn() to work correctly — without it, conflicting classes both apply |

**Installation command:**
```bash
pnpm add clsx tailwind-merge
```

These go in `dependencies` (not devDependencies) because cn() is used at runtime in component files, not just at build time.

## Architecture Patterns

### cn() Utility — Standard Implementation

**Location:** `src/lib/utils.ts`

This is the exact pattern used by shadcn/ui, every major Next.js starter, and referenced in rules.md (`Use cn() for conditional classes — never string concatenation`). The rules.md already mandates cn() — it just doesn't exist yet.

```typescript
// src/lib/utils.ts
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

**Import path:** `@/lib/utils` (works via tsconfig `@/*` → `./src/*`)

Usage example:
```typescript
import { cn } from "@/lib/utils"

// Conditional classes
<div className={cn("base-class", isActive && "active-class", variant === "primary" && "primary-class")} />

// Conflict resolution (tailwind-merge handles this)
<div className={cn("p-4", "p-8")} /> // resolves to p-8
```

### Tailwind v4 CSS-First Config Pattern

**Confidence: HIGH** — verified in official Tailwind v4 docs and confirmed in the existing project.

Tailwind v4 uses CSS-first configuration. There is no `tailwind.config.js`. All customization happens in CSS:

```css
/* globals.css — already correct in this project */
@import "tailwindcss";

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  /* Custom tokens go here */
}
```

This is already set up correctly. The planner should NOT add a tailwind.config.js — that's the v3 pattern.

### Recommended page.tsx Replacement

Replace the Vercel promotional page with a minimal starter that:
- Renders successfully with `pnpm dev`
- Teaches the student the import pattern for cn()
- Confirms Tailwind is working via a styled element
- Points to `CLAUDE.md` and the modules folder

The page should be visually clean but minimal — not a design showcase. Students will immediately start changing it.

### Starter page structure:
```tsx
// src/app/page.tsx
export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-8 p-8">
      <h1>Claude Code Mastery</h1>
      <p>Your starter kit is ready. Open a module in modules/ to begin.</p>
    </main>
  )
}
```

### layout.tsx — Font Simplification

The current layout.tsx imports Geist fonts from next/font/google. For a student starter kit, this adds an external network dependency at boot and references fonts the stack docs don't mention. Replace with system font stack via Tailwind (font-sans):

```tsx
// Replace Geist imports with no-dep system font approach
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="antialiased font-sans">{children}</body>
    </html>
  )
}
```

This eliminates a Google Fonts request, removes the font CSS variable wiring, and keeps layout.tsx under 20 lines — more beginner-readable.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Conditional Tailwind classes | String concatenation: `` `${base} ${condition ? 'a' : 'b'}` `` | `cn()` from clsx + tailwind-merge | String concat breaks with class conflicts; two `bg-*` classes both apply, last-write-wins is not guaranteed |
| Class conflict resolution | Manual deduplication | tailwind-merge inside cn() | Tailwind generates styles by class name, not specificity — both `p-4` and `p-8` apply without merge |

**Key insight:** clsx alone handles conditionals but cannot resolve Tailwind conflicts. tailwind-merge alone resolves conflicts but has clunky API for conditionals. Together via cn() they cover both problems.

## Common Pitfalls

### Pitfall 1: Tailwind v4 vs v3 Config Format
**What goes wrong:** Student or Claude adds `tailwind.config.js` thinking it's required.
**Why it happens:** All pre-2025 tutorials and most AI training data uses v3 pattern.
**How to avoid:** globals.css already uses `@import "tailwindcss"` and `@theme inline` — the correct v4 pattern. Planner task should explicitly NOT create tailwind.config.js.
**Warning signs:** If `tailwind.config.js` appears, v4 will still work but the file is dead weight and confuses students.

### Pitfall 2: cn() in devDependencies
**What goes wrong:** clsx and tailwind-merge placed in devDependencies.
**Why it happens:** They feel like "build tools."
**How to avoid:** They are imported by component source files at runtime — they belong in `dependencies`. Planner task should specify `pnpm add clsx tailwind-merge` (no `-D`).
**Warning signs:** Works locally (pnpm installs both), breaks in production Docker builds that skip devDeps.

### Pitfall 3: README 5-Minute Clock — Prerequisites Before Step 1
**What goes wrong:** README begins with "clone the repo" but student doesn't have Node.js, Git, or Claude Code installed.
**Why it happens:** Authors assume prerequisites; students don't have them.
**How to avoid:** README must start with a prerequisites check section before the 5-step flow. install.sh handles the actual installation — README should direct students there first, then proceed to the 5-step git clone flow.
**Warning signs:** Student gets "command not found: pnpm" or "command not found: claude" at step 3.

### Pitfall 4: EACCES During Claude Code Install
**What goes wrong:** `sudo npm install -g @anthropic-ai/claude-code` causes permission corruption.
**Why it happens:** Student uses sudo; npm global dir owned by root.
**How to avoid:** README and troubleshooting must state: "Do not use sudo. Use the native installer instead: `curl -fsSL https://claude.ai/install.sh | bash`"
**Warning signs:** Subsequent installs fail with mixed-ownership errors in /usr/local/lib/node_modules.

### Pitfall 5: "command not found: claude" After Install
**What goes wrong:** Claude Code installs but shell can't find it.
**Root cause:** `~/.local/bin` not in PATH (native installer path on macOS/Linux).
**Fix:**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```
**Warning signs:** `which claude` returns nothing; `ls ~/.local/bin/claude` shows the binary exists.

### Pitfall 6: PowerShell Execution Policy (Windows)
**What goes wrong:** `pnpm.ps1 cannot be loaded because running scripts is disabled on this system`
**Root cause:** Windows default execution policy blocks unsigned PS1 scripts (pnpm, npm, node CLIs install .ps1 wrappers).
**Fix:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
**Warning signs:** Happens immediately after pnpm or node install on a fresh Windows machine. The error names the exact .ps1 file blocked.

## README Architecture

### 5-Step First-Run Flow (target: under 5 minutes)

The README must be restructured around this flow:

```
Step 1: Prerequisites (30 sec) — Node 18+, Git, Claude Code
Step 2: Clone and install (60 sec) — git clone + pnpm install
Step 3: Verify the scaffold (30 sec) — pnpm dev, see the page
Step 4: Install global config (60 sec) — bash install.sh
Step 5: Start your first session (60 sec) — bash start.sh
```

Each step should have exactly one command to run. No branching, no options. Options belong in the Troubleshooting section.

### Troubleshooting Section Structure

Must cover these three error classes (per success criteria):

1. **EACCES permission error** — `Error: EACCES: permission denied` during npm/pnpm global install
   - Root cause: trying to write to system-owned directory
   - Fix: use native installer `curl -fsSL https://claude.ai/install.sh | bash`, never sudo

2. **"command not found"** — `zsh: command not found: claude` or `pnpm: command not found`
   - Root cause: install dir not in PATH
   - Fix: add ~/.local/bin to PATH, source shell config, or open new terminal

3. **PowerShell execution policy** — `pnpm.ps1 cannot be loaded because running scripts is disabled`
   - Root cause: Windows default blocks unsigned scripts
   - Fix: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Current README — What Must Change

| Current | Problem | Fix |
|---------|---------|-----|
| References "Next.js 15" in tech stack table | Wrong version | Update to Next.js 16 |
| "just type /workshop-start" as the entire quick start | That command doesn't exist; skips all setup | Replace with 5-step flow |
| References `commands/workshop-start.md` in structure diagram | Doesn't exist | Remove or replace with real structure |
| Empty Notion link | Not helpful | Replace with actual module flow description |
| No troubleshooting section | Required by DOC-02 | Add full troubleshooting section |
| Emoji-heavy tone | Inconsistent with course materials | Reduce to professional/direct tone |

## UPGRADING.md Architecture

**Purpose:** Teach students how to take the course defaults and make them their own.

**Required sections:**

1. **Personalizing the global CLAUDE.md** — how to edit `~/.claude/CLAUDE.md` beyond the course section; what to add for their own stack preferences
2. **Adding your own skills** — how to write a skill in `~/.claude/skills/`; naming convention to avoid lah- prefix collisions; when to make a skill vs put rules in CLAUDE.md
3. **Adding your own agents** — how to write a subagent in `~/.claude/agents/`; use cases (code review, research, planning)
4. **Evolving the hooks** — how to turn advisory hooks (exit 0) into blocking hooks (exit 1) once confident; when enforcement helps vs hurts
5. **After the course** — what to carry forward vs reset; how to apply this workflow to a real project; recommended reading

**Tone:** Should read like a post-course letter, not a reference doc. The student has finished the workshop and is ready to own their setup.

## Code Examples

### cn() — Verified Standard Pattern

```typescript
// src/lib/utils.ts
// Source: shadcn/ui standard, clsx npm docs, tailwind-merge npm docs
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

### Tailwind v4 globals.css — Verified Existing Pattern

```css
/* src/app/globals.css — already in project, do not change structure */
@import "tailwindcss";

:root {
  --background: #ffffff;
  --foreground: #171717;
}

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --font-sans: var(--font-geist-sans);    /* can simplify to remove Geist ref */
}
```

### package.json — After cn() Dependencies Added

```json
{
  "dependencies": {
    "clsx": "^2.1.1",
    "next": "16.1.3",
    "react": "19.2.3",
    "react-dom": "19.2.3",
    "tailwind-merge": "^3.5.0"
  }
}
```

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| `tailwind.config.js` | CSS-first `@theme` in globals.css | No config file needed; tokens in CSS |
| `npm install -g` for Claude Code | Native installer `curl ... install.sh` | No EACCES issues; installs to ~/.local/bin |
| Pages Router (`getStaticProps`) | App Router (`src/app/`) | Already using correct approach |
| Separate clsx vs tailwind-merge | Combined `cn()` utility | Single import for all class merging |
| Geist font via next/font | System font via Tailwind `font-sans` | Zero external network request at boot |

## Open Questions

1. **Font choice in layout.tsx**
   - What we know: Current layout.tsx imports Geist via next/font/google; stack.md doesn't mention fonts
   - What's unclear: Is Geist intentional for the starter kit or was it left in from create-next-app default?
   - Recommendation: Switch to system font (font-sans via Tailwind) — simpler, no Google dependency, students immediately understand it

2. **page.tsx content**
   - What we know: Current page.tsx is the Vercel promotional default
   - What's unclear: How much content/styling the starter page should have
   - Recommendation: Minimal — one h1, one p, no images. Students will overwrite it immediately.

3. **pnpm vs npm lockfile**
   - What we know: package-lock.json (npm) exists; stack.md says use pnpm; pnpm generates pnpm-lock.yaml
   - What's unclear: Whether to generate pnpm-lock.yaml and delete package-lock.json in this phase
   - Recommendation: Yes — run `pnpm install` in 05-01 to generate pnpm-lock.yaml. Add package-lock.json to .gitignore. The existing npm lockfile is from create-next-app; students will use pnpm.

## Sources

### Primary (HIGH confidence)
- Official Claude Code troubleshooting docs — https://code.claude.com/docs/en/troubleshooting — EACCES, command not found, PATH, Windows errors
- npm registry — `npm view clsx version` → 2.1.1; `npm view tailwind-merge version` → 3.5.0
- Direct file inspection — `/tmp/claude-masterclass/package.json`, `src/app/globals.css`, `next.config.ts`, `tsconfig.json`
- package-lock.json inspection — confirmed: next 16.1.3, react 19.2.3, tailwindcss 4.1.18

### Secondary (MEDIUM confidence)
- shadcn/ui cn() pattern — standard implementation verified across multiple community sources; consistent with clsx and tailwind-merge official docs
- Tailwind v4 CSS-first config — confirmed by project's existing globals.css structure using `@import "tailwindcss"` and `@theme inline`

### Tertiary (LOW confidence — flag for validation)
- PowerShell execution policy fix (`Set-ExecutionPolicy RemoteSigned`) — sourced from multiple community guides; exact behavior varies by Windows version and Node/pnpm installer used

## Metadata

**Confidence breakdown:**
- Scaffold current state: HIGH — directly inspected all files
- Standard stack (clsx + tailwind-merge): HIGH — npm registry + official docs
- cn() implementation: HIGH — consistent across official npm docs and shadcn pattern
- Tailwind v4 setup: HIGH — confirmed in existing working project files
- README troubleshooting errors: HIGH (EACCES, command not found) — official Claude Code docs; MEDIUM (PowerShell) — community sources
- UPGRADING.md content: MEDIUM — based on course goals and common post-course needs; no official reference

**Research date:** 2026-03-10
**Valid until:** 2026-04-10 (Next.js 16, Tailwind v4, and clsx/tailwind-merge are stable; Claude Code installer path may change faster)
