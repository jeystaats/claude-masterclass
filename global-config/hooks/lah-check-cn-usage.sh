#!/bin/bash
# lah-check-cn-usage.sh
# Teaches: Tailwind className best practices (always use cn() for conditional classes)
# Event: PostToolUse on Edit|Write
# Exit 0 = clean (silent), Exit 2 = issues found (Claude sees feedback)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check React component files
case "$FILE_PATH" in
  *.tsx) ;;
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

# Check 1: Template literal in className (className={`...`)
TEMPLATE_COUNT=$(grep -c 'className={`' "$FILE_PATH" 2>/dev/null || true)
if [ "$TEMPLATE_COUNT" -gt 0 ]; then
  ISSUES="$ISSUES
---
DETECTED: Template literal in className ($TEMPLATE_COUNT occurrence(s))
WHY IT MATTERS: Raw template literals like \`className={\`text-lg \${condition ? \"bold\" : \"\"}\`}\` can produce duplicate or conflicting Tailwind classes. The \`cn()\` utility uses \`tailwind-merge\` to resolve conflicts automatically.
HOW TO FIX: Replace with \`cn()\`: \`className={cn(\"text-lg\", condition && \"font-bold\")}\`. Import cn from \`@/lib/utils\`."
fi

# Check 2: String concatenation in className
CONCAT_COUNT=$(grep -c -E 'className=\{[^}]*\+' "$FILE_PATH" 2>/dev/null || true)
if [ "$CONCAT_COUNT" -gt 0 ]; then
  ISSUES="$ISSUES
---
DETECTED: String concatenation in className ($CONCAT_COUNT occurrence(s))
WHY IT MATTERS: String concatenation (\`className={\"base \" + extraClass}\`) is fragile — it can produce extra spaces, miss classes, and doesn't resolve Tailwind conflicts.
HOW TO FIX: Use \`cn()\`: \`className={cn(\"base\", extraClass)}\`. Import cn from \`@/lib/utils\`."
fi

# Check 3: Ternary in className without cn()
# Finds lines with className={ that contain a ternary (? not followed by .) and no cn(
TERNARY_COUNT=$(grep -E 'className=\{' "$FILE_PATH" 2>/dev/null | grep -vE 'cn\(' | grep -cE '\?[^.]' || true)
if [ "$TERNARY_COUNT" -gt 0 ]; then
  ISSUES="$ISSUES
---
DETECTED: Ternary in className without cn() ($TERNARY_COUNT occurrence(s))
WHY IT MATTERS: Raw ternaries like \`className={active ? \"bg-blue-500\" : \"bg-gray-500\"}\` work but don't resolve Tailwind class conflicts when composed with other classes.
HOW TO FIX: Wrap in \`cn()\`: \`className={cn(active ? \"bg-blue-500\" : \"bg-gray-500\")}\`. For 3+ variants, consider \`cva()\` from class-variance-authority."
fi

if [ -n "$ISSUES" ]; then
  echo "Tailwind cn() Usage — $(basename "$FILE_PATH"):$ISSUES" >&2
  echo "" >&2
  echo "Fix these issues." >&2
  exit 2
fi

exit 0
