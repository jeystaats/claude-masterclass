#!/bin/bash
# lah-check-react.sh
# Teaches: React best practices (avoid unnecessary use client, useEffect pitfalls, no direct DOM)
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
FILE_CONTENT=$(cat "$FILE_PATH")

# Check 1: Unnecessary "use client" — file has directive but no client-side hooks
HAS_USE_CLIENT=$(echo "$FILE_CONTENT" | grep -c '"use client"' 2>/dev/null || true)
if [ "$HAS_USE_CLIENT" -gt 0 ]; then
  HAS_CLIENT_HOOKS=$(echo "$FILE_CONTENT" | grep -c -E 'use(State|Effect|Ref|Callback|Memo|Context|Reducer|Transition)\b' 2>/dev/null || true)
  HAS_EVENT_HANDLERS=$(echo "$FILE_CONTENT" | grep -c -E 'on(Click|Change|Submit|Focus|Blur|KeyDown|KeyUp|Mouse)\b' 2>/dev/null || true)
  if [ "$HAS_CLIENT_HOOKS" -eq 0 ] && [ "$HAS_EVENT_HANDLERS" -eq 0 ]; then
    ISSUES="$ISSUES
---
DETECTED: \`\"use client\"\` directive without client-side hooks or event handlers
WHY IT MATTERS: Adding \`\"use client\"\` unnecessarily opts the component out of server rendering. Server Components are faster, reduce bundle size, and can access backend resources directly.
HOW TO FIX: Remove \`\"use client\"\` — this component can be a Server Component. Only add it when you use hooks (useState, useEffect, etc.) or event handlers (onClick, onChange, etc.)."
  fi
fi

# Check 2: useEffect with empty deps for data fetching
HAS_FETCH_EFFECT=$(echo "$FILE_CONTENT" | grep -c -E 'useEffect.*\{' 2>/dev/null || true)
if [ "$HAS_FETCH_EFFECT" -gt 0 ]; then
  HAS_FETCH_IN_EFFECT=$(echo "$FILE_CONTENT" | grep -c -E 'fetch\(|axios\.|\.get\(|\.post\(' 2>/dev/null || true)
  if [ "$HAS_FETCH_IN_EFFECT" -gt 0 ]; then
    ISSUES="$ISSUES
---
DETECTED: Data fetching inside useEffect
WHY IT MATTERS: Fetching in useEffect causes waterfalls, loading flickers, and race conditions. It runs after render, so users see empty states unnecessarily.
HOW TO FIX: Move data fetching to a Server Component (async function), use React Server Actions, or use a data-fetching library like TanStack Query that handles caching and deduplication."
  fi
fi

# Check 3: Direct DOM manipulation
DOM_COUNT=$(echo "$FILE_CONTENT" | grep -c -E 'document\.(getElementById|querySelector|querySelectorAll|getElementsBy)' 2>/dev/null || true)
if [ "$DOM_COUNT" -gt 0 ]; then
  ISSUES="$ISSUES
---
DETECTED: Direct DOM manipulation ($DOM_COUNT occurrence(s))
WHY IT MATTERS: Direct DOM access bypasses React's virtual DOM, causing inconsistencies between React's state and the actual DOM. It also breaks server-side rendering.
HOW TO FIX: Use \`useRef\` to reference DOM elements, and let React manage DOM updates through state and props."
fi

if [ -n "$ISSUES" ]; then
  echo "React Patterns — $(basename "$FILE_PATH"):$ISSUES" >&2
  echo "" >&2
  echo "Fix these issues." >&2
  exit 2
fi

exit 0
