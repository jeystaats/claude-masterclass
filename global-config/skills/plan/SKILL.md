---
name: plan
description: >
  Decompose a feature or task into concrete subtasks before writing any code.
  Auto-invokes when the user says "plan this", "how should I approach", "break
  this down", or describes a multi-step feature to build.
---

<!-- WHY THIS SKILL EXISTS: Jumping straight into code is the #1 beginner
mistake. Planning for even 2 minutes reduces false starts, catches missing
requirements, and gives you a checklist to work through instead of a fog. -->

# /lah-plan-task -- Think before you code

## Workflow

1. **State the goal in one sentence** -- What does "done" look like? Be specific. Not "build auth" but "users can sign up with email, log in, and see a protected dashboard."

2. **List what you don't know** -- What questions need answers before you start? Missing info is where projects stall. Examples: "What happens on invalid input?", "Does this need to work offline?"

3. **Break into 2-4 subtasks** -- Each subtask should be completable in one sitting (under 30 min). If a subtask feels big, split it again. Give each a one-line description.

4. **Find the riskiest part** -- Which subtask are you least sure about? Which has the most unknowns or dependencies? Mark it.

5. **Start with the risk** -- Do the riskiest subtask first. If it turns out to be impossible or needs a different approach, you find out early instead of after building everything else.

## Example output

```
## Goal
Add a dark mode toggle that persists across page reloads.

## Unknowns
- Where to store the preference? (localStorage vs cookie vs database)
- Does the CSS framework support dark mode classes already?
- Should it respect the OS-level setting as default?

## Subtasks
1. [ ] Check if Tailwind dark mode is configured (5 min)
2. [ ] Build the toggle component with light/dark states (15 min)
3. [ ] Wire up localStorage to persist the choice (10 min) <-- RISKIEST
4. [ ] Add OS-preference detection as default (10 min)

## Start with: Subtask 3
localStorage interaction with SSR frameworks can be tricky (window is
undefined on the server). Nail this first, then the rest is styling.
```

## Tips

- If you can't break a task into subtasks, you probably don't understand it yet. Ask more questions.
- Plans are cheap to change. Don't over-plan -- 5 minutes of planning is plenty for most tasks.
- Revisit your plan after each subtask. New info might change the order.
