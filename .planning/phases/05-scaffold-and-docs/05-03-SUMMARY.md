---
plan: 05-03
status: complete
duration: 3min
files_created:
  - UPGRADING.md
  - .planning/phases/05-scaffold-and-docs/05-03-SUMMARY.md
---

## Summary

Wrote UPGRADING.md — a concise post-course personalization and evolution guide for students. The file answers the three core questions: how to make the config yours, how to add new capabilities, and how to pull course updates without losing personalizations.

## Artifacts

- **UPGRADING.md** — 80 lines (under 100 line limit)
  - Section 1 (Personalize): rename lah-* prefix with concrete bash example, swap global CLAUDE.md
  - Section 2 (Extend): copy lah-* files as templates for agents, skills, hooks; links to Claude Code hooks docs
  - Section 3 (Evolve): course-to-production differences, Module 9 migration path
  - Section 4 (Update): `git pull` + idempotent `bash install.sh`, delete-then-reinstall pattern for force-refreshing individual files

## Verification

All checks passed:
- Line count: 80 (under 100 ✓)
- Sections: 4 numbered sections ✓
- lah-* references: 7 ✓
- install.sh references: 4 ✓
- Module 9 references: 2 ✓
- No `install.sh --force` references ✓

Content decisions:
- No "what's next" or aspirational closer — plan explicitly prohibited encouragement filler
- External link kept (Claude Code hooks docs) — only external link, load-bearing for hook authors
- Delete-then-reinstall pattern used instead of --force flag (install.sh does not support --force)
