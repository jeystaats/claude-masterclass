---
plan: 02-01
status: complete
duration: 3min
files_created:
  - global-config/skills/lah-explain-code/SKILL.md
  - global-config/skills/lah-commit-message/SKILL.md
  - global-config/skills/lah-plan-task/SKILL.md
  - global-config/skills/lah-review-code/SKILL.md
  - global-config/skills/lah-debug-it/SKILL.md
---

## Summary

Created 5 beginner-friendly skills in `global-config/skills/lah-*/SKILL.md`. Each skill teaches a Claude Code pattern through a concrete step-by-step workflow with example output. Three are auto-invocable; two are manual-only.

## Artifacts

- **lah-explain-code** (53 lines) -- Multi-layer explanation pattern: analogy, ASCII diagram, step-by-step trace, one gotcha. Auto-invocable.
- **lah-commit-message** (62 lines) -- Conventional commit writing with type table and good/bad examples. Manual-only (`disable-model-invocation: true`).
- **lah-plan-task** (53 lines) -- Task decomposition: goal, unknowns, subtasks, risk-first execution. Auto-invocable.
- **lah-review-code** (65 lines) -- Priority-based code review (Critical/Warning/Suggestion). Manual-only (`disable-model-invocation: true`).
- **lah-debug-it** (60 lines) -- Scientific debugging method: reproduce, hypothesize, diagnose one thing at a time. Auto-invocable.

## Verification

- All 5 files exist with valid YAML frontmatter (name, description)
- All 5 contain `<!-- WHY THIS SKILL EXISTS:` pedagogical comment
- All names use `lah-` prefix (GLOB-04 compliant)
- `lah-commit-message` and `lah-review-code` have `disable-model-invocation: true`
- All files within 40-70 line target range (53-65 lines)
- Committed as `feat(skills): add 5 beginner-friendly course skills`
