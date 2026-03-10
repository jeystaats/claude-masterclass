# Claude Code Mastery — Starter Kit

A production-ready Next.js starter kit for the Claude Code Mastery course. Installs a team of powerful AI agents globally, so every project you build gets expert-level help automatically.

## Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jeystaats/claude-masterclass/main/install.sh)
```

Then:

```bash
cd ~/Documents/claude-mastery-starter
pnpm install
pnpm dev        # http://localhost:3000
claude          # open Claude Code in the project
```

## What Gets Installed

### Agents (globally in `~/.claude/agents/`)

A full AI development team installed once and available in every project:

| Agent | Role |
|-------|------|
| `@agent-orchestrator` | Primary entry point — routes all tasks to the right specialists |
| `@frontend-lead` | Creative frontend direction + component/SSR routing |
| `@backend-lead` | Data, state, auth, payments — routes to backend specialists |
| `@saas-stack-architect` | SaaS stack decisions: Clerk, Stripe, Convex, Resend |
| `@convex-expert` | Convex schema design, queries, mutations, real-time patterns |
| `@react-component-architect` | Component review, CVA patterns, prop drilling fixes |
| `@security-sentinel` | Security audit, OWASP, auth patterns, secret management |
| `@nextjs-ssr-optimizer` | Server/client component boundaries, hydration, RSC |

### Skills (globally in `~/.claude/skills/`)

| Skill | What it does |
|-------|-------------|
| `/lah-explain-code` | Explains code with analogies and step-by-step breakdowns |
| `/lah-plan-task` | Decomposes a task before writing any code |
| `/lah-commit-message` | Writes conventional commit messages |
| `/lah-review-code` | Structured code review for quality and correctness |
| `/lah-debug-it` | Scientific debugging with root cause analysis |

### Quality Hooks

Five hooks that run on every file write and teach while they enforce:

1. **TypeScript quality** — catches `any` types and `@ts-ignore`
2. **React patterns** — flags unnecessary `"use client"`, useEffect for data fetching
3. **Tailwind cn() usage** — prevents raw className string concatenation
4. **File size guard** — soft 200-line limit with split suggestions
5. **Secret detector** — catches hardcoded API keys and credentials

### The Next.js Project

A clean Next.js 16 + React 19 + Tailwind v4 + TypeScript scaffold ready to build on:

```
src/
├── app/
│   ├── layout.tsx          # Root layout with metadata
│   └── page.tsx            # Home page
└── lib/
    └── utils.ts            # cn() utility (clsx + tailwind-merge)
```

## Stack

| Layer | Tech |
|-------|------|
| Framework | Next.js 16 + React 19 |
| Language | TypeScript (strict) |
| Styling | Tailwind CSS v4 |
| Package manager | pnpm |

## Prerequisites

- macOS or Linux (Windows: use WSL2)
- Internet connection for the installer

The installer handles everything else: Homebrew, Git, jq, Node.js LTS via nvm, pnpm, Claude Code CLI.

## Troubleshooting

**`EACCES: permission denied` on pnpm install**
```bash
sudo chown -R $(whoami) ~/.npm
```

**`command not found: claude`**
Close and reopen your terminal. The installer adds `claude` to your PATH via your shell profile.

**Windows: `Execution policy` blocks the script**
Install WSL2 first: `wsl --install`, then run the curl command inside WSL.

**Agents not showing up in Claude Code**
Check they're installed: `ls ~/.claude/agents/`. Run `bash install.sh` again — it's idempotent.

## Customizing Your Setup

See [UPGRADING.md](./UPGRADING.md) for how to extend the agents, add your own skills, and evolve beyond the course defaults.
