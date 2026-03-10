#!/bin/bash
# lah-check-file-size.sh
# Teaches: File organization (keep files focused and under 200 lines)
# Event: PostToolUse on Edit|Write
# Exit 0 = clean (silent), Exit 2 = issues found (Claude sees feedback)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check source code files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

# Skip generated/vendor files
case "$FILE_PATH" in
  *node_modules*|*.d.ts|*.min.*) exit 0 ;;
esac

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
ISSUES=""

if [ "$LINE_COUNT" -gt 300 ]; then
  ISSUES="$ISSUES
---
DETECTED: File is $LINE_COUNT lines (significantly over the 200-line limit)
WHY IT MATTERS: Files over 300 lines are very hard to maintain, test, and review. They usually contain multiple responsibilities that should be separated. Long files increase merge conflicts and make onboarding harder.
HOW TO FIX: Split this file urgently. Extract helper functions into a utils file, break large components into smaller sub-components, and move types to a separate \`.types.ts\` file."
elif [ "$LINE_COUNT" -gt 200 ]; then
  ISSUES="$ISSUES
---
DETECTED: File is $LINE_COUNT lines (over the 200-line limit)
WHY IT MATTERS: Large files are harder to maintain and usually signal that a component or module has too many responsibilities. Focused files are easier to test, review, and reuse.
HOW TO FIX: Consider splitting — extract utility functions to a separate file, break the component into smaller sub-components, or move type definitions to a \`.types.ts\` file."
fi

if [ -n "$ISSUES" ]; then
  echo "File Size — $(basename "$FILE_PATH"):$ISSUES" >&2
  echo "" >&2
  echo "Fix these issues." >&2
  exit 2
fi

exit 0
