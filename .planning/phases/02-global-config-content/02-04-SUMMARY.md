---
plan: 02-04
status: complete
duration: 3min
files_created:
  - global-config/CLAUDE.md.snippet
files_modified:
  - install.sh
---

## Summary

Wrote the CLAUDE.md.snippet and added `install_global_config()` and `append_claude_md_snippet()` to install.sh, completing the Phase 2 install pipeline. Running `bash install.sh` now deploys all Wave 1 content (5 skills, 4 agents, 5 hooks) to `~/.claude/` and appends the course teaching section to `~/.claude/CLAUDE.md`.

## Artifacts

- **`global-config/CLAUDE.md.snippet`** — Course section with `<!-- LAH-COURSE-START/END -->` delimiters, teaching mode instructions, full listing of all 5 skills, 4 agents, and 5 hooks
- **`install.sh`** — Added `install_global_config()` (copies skills/agents/hooks with skip-if-exists idempotency) and `append_claude_md_snippet()` (appends snippet with delimiter idempotency check); both wired into `main()` after `merge_settings`

## Verification

- `bash -n install.sh` → PASS
- `grep -c "install_global_config\|append_claude_md_snippet" install.sh` → 4 (2 definitions + 2 calls)
- Functions appear before `main()` (line 270, 327 vs main at line 360)
- `wc -l install.sh` → 410 lines (within 350–500 target)
- `CLAUDE.md.snippet` has LAH-COURSE-START and LAH-COURSE-END delimiters
- 9 `lah-` references in snippet (all 5 skills + 4 agents listed)
- `install_global_config()` guards all glob patterns with `[ -d ]`/`[ -f ]` guards for empty-match safety
- `append_claude_md_snippet()` checks delimiter before appending (idempotent)
