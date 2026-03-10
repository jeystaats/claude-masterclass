---
plan: 04-01
status: complete
duration: 12min
files_created:
  - start.sh
  - .planning/phases/04-session-launcher/04-01-SUMMARY.md
files_modified:
  - .gitignore
---

## Summary

Wrote `start.sh` — the single-command session launcher for the Claude Code Mastery starter kit. Students run `bash start.sh` before every learning session. The script lists all 9 modules (titles read dynamically from README.md), accepts a numeric selection, resolves the module directory via zero-padded glob, writes a session context file, ensures the CLAUDE.md imports it, and launches Claude Code.

Updated `.gitignore` to exclude `**/.claude/session.md` so per-session context files are never committed.

## Artifacts

### start.sh (282 lines)

- **Bash 3.2 compatible** — no `declare -A`, no `readlink -f`, no `${!var}`. Uses `case` statements and `ls -d` glob for all lookups.
- **Dynamic module listing** — reads first line of each `README.md`; no hardcoded titles.
- **Directory resolution** — zero-padded glob: `ls -d "$MODULES_DIR/${NUM_PADDED}-"* | head -1`. Self-healing if slugs change.
- **Progressive skill disclosure** — `get_skills_for_module()` and `get_agents_for_module()` via `case` statements. Module 1 gets 1 skill + 1 agent; modules 6/8/9 get all 5 skills + 4 agents.
- **`write_session_context()`** — writes to `modules/XX/.claude/session.md` via heredoc. Includes module number, timestamp, skills list, agents list.
- **`ensure_session_import()`** — idempotent: creates minimal `CLAUDE.md` with `@session.md` if none exists; appends if missing; skips if already present.
- **Never overwrites existing CLAUDE.md** — modules 01, 04, 09 retain hand-crafted rules. Only `@session.md` line is appended.
- **Launch** — `cd "$MODULE_DIR" && exec claude`

### .gitignore

Added block:
```
# Session context files written by start.sh — not committed
**/.claude/session.md
```

## Verification

| Check | Result |
|-------|--------|
| `bash -n start.sh` | PASS — exits 0 |
| `bash start.sh 4` writes session.md | PASS — contains "Module 4: Research & Plan Your Product" and skills section |
| `bash start.sh 4` second run shows `[skip]` | PASS — idempotent |
| Module 02 `.claude/CLAUDE.md` created with `@session.md` | PASS |
| Module 01 `.claude/CLAUDE.md` not overwritten | PASS — original beginner rules intact, `@session.md` appended at bottom |
| Module 1 session.md has only `lah-explain-code` | PASS |
| Module 6 session.md has all 5 skills | PASS |
| `grep "session.md" .gitignore` returns result | PASS |
| `git status` does not show session.md as untracked | PASS — gitignored correctly |
| `start.sh` >= 120 lines | PASS — 282 lines |
