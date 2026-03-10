---
name: review
description: >
  Perform a structured code review with prioritized findings. Invoke manually
  with /review and point it at a file, function, or git diff.
disable-model-invocation: true
---

<!-- WHY THIS SKILL EXISTS: Code review is a core professional skill, but
beginners either miss critical issues or nitpick formatting. This structured
approach teaches priority-based review -- catch the things that break production
before worrying about style. -->

# /lah-review-code -- Review code like a senior developer

## Workflow

1. **Read the full context** -- Don't review line-by-line in isolation. Understand what the code is trying to do first. Read surrounding code, types, and tests if they exist.

2. **Check for critical issues** -- These can cause bugs, security holes, or data loss:
   - Logic errors (off-by-one, wrong condition, missing return)
   - Unhandled error cases (what if the API call fails? what if the input is null?)
   - Security problems (unsanitized input, exposed secrets, missing auth checks)
   - Data loss risks (destructive operations without confirmation)

3. **Check for warnings** -- These won't break things today but cause pain later:
   - Missing TypeScript types or `any` usage
   - Duplicated logic that should be extracted
   - Performance issues (unnecessary re-renders, N+1 queries, missing pagination)
   - Missing edge cases in business logic

4. **Note suggestions** -- Nice-to-haves for cleaner code:
   - Naming improvements
   - Simpler alternatives (array methods vs loops, early returns vs nesting)
   - Missing comments on non-obvious logic

5. **Summarize** -- Give a one-sentence verdict: ship it, fix criticals then ship, or needs rework.

## Example output

```
## Review: src/api/create-order.ts

### Critical
- **Line 23: No error handling on payment call** -- If `stripe.charges.create()`
  throws, the order is saved but payment never collected. Wrap in try/catch and
  roll back the order on failure.

### Warning
- **Line 8: `amount` is typed as `any`** -- Should be `number`. A string amount
  would silently pass and cause wrong charges.

### Suggestion
- **Line 15-20: Nested if/else** -- Could use early return pattern to reduce
  nesting and improve readability.

### Verdict
Fix the payment error handling (critical), then good to ship.
```

## When to use

- Before committing: `/lah-review-code` on your staged changes
- Learning: point it at open-source code to practice reading
- Pull requests: review a teammate's diff
