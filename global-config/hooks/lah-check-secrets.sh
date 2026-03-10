#!/bin/bash
# lah-check-secrets.sh
# Teaches: Security (never hardcode secrets, API keys, or passwords)
# Event: PostToolUse on Edit|Write
# Exit 0 = clean (silent), Exit 2 = issues found (Claude sees feedback)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip non-file paths
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip .env files, env examples, and non-source files
case "$FILE_PATH" in
  *.env|*.env.*|*node_modules*|*.git/*|*.lock|*.png|*.jpg|*.svg|*.ico|*.woff*) exit 0 ;;
esac

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

ISSUES=""

# Check 1: Hardcoded API keys (common prefixes)
API_KEY_COUNT=$(grep -c -E '(sk-[a-zA-Z0-9]{20,}|pk_test_[a-zA-Z0-9]{20,}|sk_test_[a-zA-Z0-9]{20,}|whsec_[a-zA-Z0-9]{20,}|AKIA[A-Z0-9]{16})' "$FILE_PATH" 2>/dev/null || true)
if [ "$API_KEY_COUNT" -gt 0 ]; then
  ISSUES="$ISSUES
---
DETECTED: Hardcoded API key pattern ($API_KEY_COUNT occurrence(s))
WHY IT MATTERS: API keys in source code get committed to git and exposed to anyone with repo access. Leaked keys can be used for unauthorized access, data theft, or running up charges on your accounts.
HOW TO FIX: Move the key to a \`.env.local\` file and access it via \`process.env.YOUR_KEY_NAME\`. Add \`.env.local\` to \`.gitignore\`. Never commit real API keys."
fi

# Check 2: Bearer tokens
BEARER_COUNT=$(grep -c -E 'Bearer [a-zA-Z0-9_\-\.]{20,}' "$FILE_PATH" 2>/dev/null || true)
if [ "$BEARER_COUNT" -gt 0 ]; then
  ISSUES="$ISSUES
---
DETECTED: Hardcoded Bearer token ($BEARER_COUNT occurrence(s))
WHY IT MATTERS: Bearer tokens are authentication credentials. Hardcoding them means they will be committed to version control and anyone with access can impersonate you or your service.
HOW TO FIX: Store the token in an environment variable and reference it with \`process.env.YOUR_TOKEN\`. For client-side auth, use a proper auth library like Clerk or NextAuth."
fi

# Check 3: Hardcoded passwords
PASSWORD_COUNT=$(grep -c -E '(password|passwd|secret)\s*[:=]\s*["\x27][^"\x27]{4,}' "$FILE_PATH" 2>/dev/null || true)
if [ "$PASSWORD_COUNT" -gt 0 ]; then
  # Skip if this looks like an env example or type definition
  IS_EXAMPLE=$(grep -c -E '(password|secret)\s*[:=]\s*["\x27](your_|example|changeme|xxx|placeholder)' "$FILE_PATH" 2>/dev/null || true)
  IS_TYPE_DEF=$(grep -c -E '(password|secret)\s*:\s*string' "$FILE_PATH" 2>/dev/null || true)
  REAL_PASSWORD_COUNT=$((PASSWORD_COUNT - IS_EXAMPLE - IS_TYPE_DEF))
  if [ "$REAL_PASSWORD_COUNT" -gt 0 ]; then
    ISSUES="$ISSUES
---
DETECTED: Possible hardcoded password or secret ($REAL_PASSWORD_COUNT occurrence(s))
WHY IT MATTERS: Passwords in source code are a critical security vulnerability. They persist in git history even after deletion and can be found by automated scanners.
HOW TO FIX: Move secrets to environment variables (\`.env.local\`). Use a secrets manager for production. Never commit real credentials — use \`.env.example\` with placeholder values."
  fi
fi

if [ -n "$ISSUES" ]; then
  echo "Security Check — $(basename "$FILE_PATH"):$ISSUES" >&2
  echo "" >&2
  echo "Fix these issues immediately. Hardcoded secrets are a critical security risk." >&2
  exit 2
fi

exit 0
