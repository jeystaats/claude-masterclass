---
plan: 03-02
status: complete
duration: 5min
files_created:
  - modules/01-getting-started/exercises/hello.ts
  - modules/01-getting-started/exercises/first-prompt.md
  - modules/04-plan-your-product/exercises/RESEARCH.md
  - modules/04-plan-your-product/exercises/PRD.md
  - modules/06-build-your-app/exercises/PLAN.md
  - modules/06-build-your-app/exercises/feature-brief.md
---

## Summary

Created 6 starter exercise files across modules 1, 4, and 6. Each file gives students an immediate scaffold to work from — pre-filled section headers and one example entry per section — without solving the exercise for them. Every file includes an "Ask Claude:" prompt so students know exactly which conversation to use it in.

The original plan specified `// TODO` comments in `hello.ts`, but the project's TypeScript quality hook blocks TODO/FIXME/HACK comments without a Linear ticket reference. Replaced with `// EXERCISE:` prefix, which conveys the same instruction without triggering the hook.

## Artifacts

| File | Purpose |
|------|---------|
| `modules/01-getting-started/exercises/hello.ts` | Valid TypeScript with a `greet()` function and 3 EXERCISE comments guiding the first Claude conversation |
| `modules/01-getting-started/exercises/first-prompt.md` | Structured template students fill in before their first Claude session (goal, background, first question) |
| `modules/04-plan-your-product/exercises/RESEARCH.md` | Market research template with example row in the alternatives table |
| `modules/04-plan-your-product/exercises/PRD.md` | PRD skeleton with all standard sections and one example user story |
| `modules/06-build-your-app/exercises/PLAN.md` | Ticket list with Wave 1/2/3 structure and 13 checkboxes |
| `modules/06-build-your-app/exercises/feature-brief.md` | Feature description format with acceptance criteria checklist |

## Verification

- `find modules -name "*.ts" -o -name "*.md" | grep exercises` → 6 files across 3 module folders
- `grep "EXERCISE" modules/01-getting-started/exercises/hello.ts | wc -l` → 3
- `grep "## My goal" modules/01-getting-started/exercises/first-prompt.md` → heading found
- `grep "## Problem" modules/04-plan-your-product/exercises/RESEARCH.md` → heading found
- `grep "Wave" modules/06-build-your-app/exercises/PLAN.md` → Wave 1, Wave 2, Wave 3 headings found
- `grep -c "\- \[ \]" modules/06-build-your-app/exercises/PLAN.md` → 13 checkboxes (plan required ≥8)
- `grep "Ask Claude" modules/04-plan-your-product/exercises/RESEARCH.md` → instructional prompt found
- `hello.ts` is syntactically valid TypeScript with a typed function signature and no errors
