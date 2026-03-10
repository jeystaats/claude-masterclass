# Claude Code Mastery — Project Guide

You are Claude Code, helping a developer build a real SaaS product with the Claude Code Mastery starter kit.
Read this file before every response. Follow every rule without exception.

---

## Stack
<!-- Why: Without a stack declaration, Claude will suggest whatever it prefers.
     Declaring here keeps every answer in the same ecosystem. -->
@.claude/stack.md

## Coding rules
<!-- Why: "Write clean code" is meaningless. "No inline styles" is enforceable.
     These are literal rules Claude reads and applies, not aspirational guidelines. -->
@.claude/rules.md

## Workflow
<!-- Why: Consistent pnpm/git commands stop Claude from guessing or suggesting npm. -->
@.claude/workflow.md

---

## Agent Team

For any non-trivial task, route through the installed agents:

**Orchestration**
| Agent | When to use |
|-------|------------|
| `@agent-orchestrator` | Any multi-step or multi-domain task — start here |
| `@deep-reasoning-planner` | Complex architecture decisions, trade-off analysis |

**Domain Leads**
| Agent | When to use |
|-------|------------|
| `@frontend-lead` | UI, components, layouts, creative direction |
| `@backend-lead` | Data, APIs, auth, payments, state |

**Creative**
| Agent | When to use |
|-------|------------|
| `@creative-director` | Visual concepts, "make it pop", award-worthy UI |
| `@animation-specialist` | GSAP, Framer, micro-interactions, hover effects |
| `@visual-dna-analyst` | Analyze any website/app and extract its design language |

**Specialists**
| Agent | When to use |
|-------|------------|
| `@saas-stack-architect` | SaaS decisions: Clerk, Stripe, Convex, Resend |
| `@convex-expert` | Convex schema, queries, mutations |
| `@react-component-architect` | Component review, prop drilling, CVA patterns |
| `@security-sentinel` | Security review, auth patterns, secrets |
| `@nextjs-ssr-optimizer` | Server/client component boundaries, hydration |
| `@storybook-dls-architect` | Component documentation, Storybook stories |

---

## Behavior

- Prefer routing to specialist agents over doing everything inline
- Explain architectural decisions before implementing them
- When multiple approaches exist, recommend one and explain why
- Use `@agent-orchestrator` for complex tasks — it coordinates the right specialists
