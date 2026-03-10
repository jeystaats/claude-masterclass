#!/bin/bash
# lah-check-typescript.sh
# Teaches: TypeScript best practices (no any, no ts-ignore, no debug logs)
# Event: PostToolUse on Edit|Write
# Exit 0 = clean (silent), Exit 2 = issues found (Claude sees feedback)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check TypeScript files
case "$FILE_PATH" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Skip generated/vendor files
case "$FILE_PATH" in
  *node_modules*|*.d.ts|*.min.*) exit 0 ;;
esac

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

ISSUES=""

# Check 1: any type usage
ANY_COUNT=$(grep -c -E ':\s*any\b|<any>|as any' "$FILE_PATH" 2>/dev/null || true)
if [ "$ANY_COUNT" -gt 0 ]; then
  ISSUES="$ISSUES
---
DETECTED: \`any\` type used ($ANY_COUNT occurrence(s))
WHY IT MATTERS: \`any\` disables TypeScript's type checking, defeating the purpose of using TypeScript. Bugs slip through that the compiler would otherwise catch.
HOW TO FIX: Replace \`any\` with \`unknown\` and add type guards, or define a proper interface/type for the data."
fi

# Check 2: @ts-ignore or @ts-expect-error
IGNORE_COUNT=$(grep -c -E '@ts-ignore|@ts-expect-error' "$FILE_PATH" 2>/dev/null || true)
if [ "$IGNORE_COUNT" -gt 0 ]; then
  ISSUES="$ISSUES
---
DETECTED: TypeScript suppression comment ($IGNORE_COUNT occurrence(s))
WHY IT MATTERS: \`@ts-ignore\` and \`@ts-expect-error\` hide type errors instead of fixing them. The underlying issue remains and can cause runtime bugs.
HOW TO FIX: Remove the suppression comment and fix the actual type error. If the types are wrong, update the type definitions."
fi

# Check 3: console.log left in code (not console.error/warn/info)
LOG_COUNT=$(grep -c -E 'console\.log\(' "$FILE_PATH" 2>/dev/null || true)
if [ "$LOG_COUNT" -gt 0 ]; then
  ISSUES="$ISSUES
---
DETECTED: \`console.log\` found ($LOG_COUNT occurrence(s))
WHY IT MATTERS: Debug logs clutter the console in production and can leak sensitive data. They signal unfinished code.
HOW TO FIX: Remove debug \`console.log\` statements. If logging is needed, use \`console.error\` for errors or a proper logging utility."
fi

if [ -n "$ISSUES" ]; then
  echo "TypeScript Quality — $(basename "$FILE_PATH"):$ISSUES" >&2
  echo "" >&2
  echo "Fix these issues." >&2
  exit 2
fi

exit 0
