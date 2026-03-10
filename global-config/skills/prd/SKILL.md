---
name: prd
description: >
  Project Requirements Document assistant. Checks if a PRD exists, validates its
  completeness, and guides creation if it's missing. Auto-invokes when the user
  says "PRD", "requirements", "what should I build", "do I have tickets",
  "what's in scope", or starts a new build session without clear direction.
---

# /prd — Your Project Requirements Document

The PRD is the source of truth for everything you build. Claude should ALWAYS know it exists and reference it.

## Step 1: Check what exists

Before anything else, run:
```bash
ls docs/ 2>/dev/null && cat docs/prd.md 2>/dev/null || echo "No docs/prd.md found"
```

Also check for tickets:
```bash
gh issue list --limit 20 2>/dev/null || echo "No GitHub issues found (or gh not set up)"
```

## Step 2: If PRD exists — validate it

Read docs/prd.md and check:

**Completeness check:**
- [ ] Problem statement — what user pain does this solve?
- [ ] Target user — who specifically?
- [ ] Goals — what does success look like? (measurable)
- [ ] Features — what are we building? (Must Have vs Nice to Have)
- [ ] Out of scope — what are we NOT building?
- [ ] Tech stack — what are we using?
- [ ] Open questions — what's unresolved?

**Ticket coverage check:**
- Does every "Must Have" feature have at least one ticket?
- Are tickets right-sized? (15-30 min of Claude Code work each)
- Do tickets have acceptance criteria?

Report findings:
> "Your PRD covers [X/7 sections]. Missing: [list]. [N] features don't have tickets yet."

## Step 3: If PRD is missing — guide creation

Run an interview. Ask these questions ONE AT A TIME, waiting for answers:

1. **"What does your product do in one sentence?"**
   → This becomes the Problem + Goal

2. **"Who is the primary user? Describe them specifically."**
   → This becomes the Target User

3. **"What are the 3-5 most important things it must do for launch?"**
   → These become Must Have features

4. **"What are you deliberately NOT building in v1?"**
   → This becomes Out of Scope (critical — prevents scope creep)

5. **"What tech stack are you using?"**
   → Confirm: Next.js, Convex, Clerk, Stripe (or their choices)

6. **"What are your biggest open questions right now?"**
   → Captures unknowns before they become blockers

After all answers, generate docs/prd.md automatically and ask for approval before writing.

## Step 4: Generate tickets from PRD

After PRD is confirmed:

```
For each Must Have feature:
1. Break into 1-3 tickets (each 15-30 min of Claude work)
2. Each ticket has: title, user story, acceptance criteria
3. Push to GitHub: gh issue create --title "..." --body "..."
```

Offer to run this automatically:
> "Want me to create GitHub issues for all your Must Have features? I'll draft them for you to review first."

## Reference format

When referencing the PRD in other responses:
> "According to your PRD, the goal is [X]. This feature maps to [Y] in your Must Have list."

Always ground build decisions in PRD requirements.
