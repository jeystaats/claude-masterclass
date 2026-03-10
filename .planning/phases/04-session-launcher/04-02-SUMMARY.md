---
plan: 04-02
status: complete
duration: 8min
files_created:
  - templates/session.md.tpl
  - lib/session.sh
---

## Summary

Created the session template reference file and the sourceable bash library
that encapsulates all session context logic for the start.sh launcher.

## Artifacts

### templates/session.md.tpl (39 lines)
Human-readable template showing the exact structure of `.claude/session.md`.
Uses `{{TOKEN}}` double-brace placeholders with inline `{{! comment }}` annotations
explaining each token and the progressive disclosure logic. Serves as a teaching
artifact — students can read it to understand what gets injected per module.

### lib/session.sh (191 lines)
Sourceable bash 3.2-compatible library defining four functions:

| Function | Purpose |
|---|---|
| `get_skills_for_module <num>` | Returns markdown bullet list of skills for module 1-9 |
| `get_agents_for_module <num>` | Returns markdown bullet list of agents for module 1-9 |
| `write_session_context <num> <dir> <title>` | Writes `.claude/session.md` via heredoc |
| `ensure_session_import <dir>` | Idempotently adds `@session.md` to `.claude/CLAUDE.md` |

Progressive disclosure implemented as `case` statements (bash 3.2 compatible,
no `declare -A`). Each function includes a `log_done`/`log_skip` fallback for
standalone testing without requiring start.sh.

## Verification

All plan checks passed:

```
bash -n lib/session.sh                          → exit 0 (PASS)
source lib/session.sh; get_skills_for_module 1  → 1 line (lah-explain-code only)
source lib/session.sh; get_skills_for_module 5  → 5 lines (all skills)
source lib/session.sh; get_skills_for_module 6  → 5 lines (all skills)
source lib/session.sh; get_agents_for_module 1  → 1 line (lah-explainer only)
source lib/session.sh; get_agents_for_module 5  → 4 lines (all agents)
source lib/session.sh (no args)                 → no output (no side effects)
write_session_context 4 /tmp/test-mod "Test"    → correct session.md created
ensure_session_import /tmp/test-import          → created on first run, skipped on second
grep MODULE_NUM|SKILLS_LIST templates/session.md.tpl → 7 matching lines (PASS)
grep progressive templates/session.md.tpl       → 2 matching lines (PASS)
```

Templates file: 39 lines (min: 25 -- PASS)
Library file: 191 lines (min: 80 -- PASS)
