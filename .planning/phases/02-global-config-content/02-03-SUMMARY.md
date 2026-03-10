---
plan: 02-03
status: complete
duration: 3min
files_created:
  - global-config/hooks/lah-check-typescript.sh
  - global-config/hooks/lah-check-react.sh
  - global-config/hooks/lah-check-cn-usage.sh
  - global-config/hooks/lah-check-file-size.sh
  - global-config/hooks/lah-check-secrets.sh
  - config/workshop-settings.json (updated)
  - .planning/phases/02-global-config-content/02-03-SUMMARY.md
---

## Summary

Created 5 teaching hooks that run as PostToolUse handlers after every Edit/Write. Each hook detects a specific code quality issue, explains why it matters, and tells Claude how to fix it. Updated workshop-settings.json with all 5 PostToolUse entries.

## Artifacts

- **lah-check-typescript.sh** — Detects `any` types, `@ts-ignore`/`@ts-expect-error`, and `console.log` in .ts/.tsx files
- **lah-check-react.sh** — Detects unnecessary `"use client"`, data fetching in useEffect, and direct DOM manipulation in .tsx files
- **lah-check-cn-usage.sh** — Detects raw template literals, string concatenation, and ternaries in className without cn() in .tsx files
- **lah-check-file-size.sh** — Warns at 200+ lines, escalates at 300+ lines for .ts/.tsx/.js/.jsx files
- **lah-check-secrets.sh** — Detects hardcoded API keys (sk-, pk_test_, AKIA, etc.), Bearer tokens, and passwords in all source files
- **config/workshop-settings.json** — 5 PostToolUse entries pointing to ~/.claude/hooks/lah-*.sh

## Verification

- All 5 hooks exist and are executable (chmod +x confirmed)
- All 5 hooks start with `INPUT=$(cat)` as first executable line (line 7, after comments)
- All 5 hooks pass `bash -n` syntax check (bash 3.2 compatible)
- All hooks check file extensions and exit 0 for non-matching files (case statements)
- All hooks use DETECTED / WHY IT MATTERS / HOW TO FIX output format
- All hooks exit 2 on issues found, exit 0 when clean
- workshop-settings.json is valid JSON with 5 PostToolUse entries
- No bash 4+ features used (no declare -A, no mapfile, no readarray)
