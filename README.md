# Claude Code Mastery — Starter Kit

A production-ready Next.js starter kit for the Claude Code Mastery course. Installs a full team of powerful AI agents, skills, and quality hooks globally — so every project you build gets expert-level help automatically.

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

A full AI development team, installed once and available in every project you work on:

**Orchestration & Planning**
| Agent | Role |
|-------|------|
| `@agent-orchestrator` | Primary entry point — routes all tasks to the right specialists |
| `@product-owner` | PRDs, user stories, backlog, acceptance criteria |
| `@deep-reasoning-planner` | Complex architecture decisions with structured trade-off analysis |

**Domain Leads**
| Agent | Role |
|-------|------|
| `@frontend-lead` | Creative frontend direction + component/SSR routing |
| `@backend-lead` | Data, state, auth, payments — routes to backend specialists |

**Creative**
| Agent | Role |
|-------|------|
| `@creative-director` | Award-worthy concepts, 2-3 creative directions before any implementation |
| `@animation-specialist` | GSAP, Framer Motion, micro-interactions, hover effects, timelines |
| `@visual-dna-analyst` | Extracts design language from any website, app, or visual reference |

**Backend Specialists**
| Agent | Role |
|-------|------|
| `@saas-stack-architect` | SaaS stack decisions: Clerk, Stripe, Convex, Resend, analytics |
| `@convex-expert` | Convex schema design, queries, mutations, real-time patterns |

**Frontend Specialists**
| Agent | Role |
|-------|------|
| `@react-component-architect` | Component composition, CVA patterns, prop drilling fixes, TypeScript |
| `@nextjs-ssr-optimizer` | Server/client component boundaries, hydration, RSC patterns |
| `@storybook-dls-architect` | Component documentation, design system stories (CSF3) |

**Quality**
| Agent | Role |
|-------|------|
| `@security-sentinel` | OWASP security, auth patterns, input validation, secret management |

### Skills (globally in `~/.claude/skills/`)

| Skill | What it does |
|-------|-------------|
| `/breakdown` | Explains code with analogies and step-by-step breakdowns |
| `/plan` | Decomposes a feature into tasks before writing any code |
| `/commit` | Writes conventional commit messages |
| `/review` | Structured code review with prioritized findings |
| `/debug` | Scientific debugging with root cause analysis |

### visual-explainer Plugin (globally in `~/.claude/skills/visual-explainer/`)

Generates self-contained HTML pages — architecture diagrams, slide decks, diff reviews, and more. Open directly in any browser, no server needed.

| Command | What it does |
|---------|-------------|
| `/generate-web-diagram` | Architecture diagrams, flowcharts, ER diagrams, data flows |
| `/generate-slides` | Magazine-quality slide decks — great for pitching or showcasing |
| `/diff-review` | Visual diff review with architecture comparison and code review |
| `/plan-review` | Compare a plan against the codebase with risk assessment |
| `/project-recap` | Mental model snapshot for switching context back into a project |
| `/share` | Deploy any generated HTML to Vercel for a shareable live URL |

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

## How the Agent Team Works

The agents collaborate. For any non-trivial task, tell `@agent-orchestrator` what you want to build and it will route to the right specialists in the right order:

```
You: "Build a SaaS dashboard with auth and billing"

@agent-orchestrator routes to:
  → @saas-stack-architect (Clerk + Stripe + Convex decisions)
  → @creative-director (2-3 visual directions for the dashboard)
  → @frontend-lead (component architecture)
  → @convex-expert (schema + queries)
  → @security-sentinel (auth patterns)
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
