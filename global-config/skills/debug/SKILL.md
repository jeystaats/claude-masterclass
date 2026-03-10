---
name: debug
description: >
  Debug an issue using the scientific method -- hypothesize, test, verify.
  Auto-invokes when the user says "debug this", "why isn't this working",
  "getting an error", or pastes an error message they don't understand.
---

<!-- WHY THIS SKILL EXISTS: Beginners debug by randomly changing things until it
works. The scientific method -- observe, hypothesize, test, conclude -- turns
debugging from guessing into a repeatable skill. One diagnostic at a time. -->

# /lah-debug-it -- Never guess, always verify

## Workflow

1. **Reproduce it** -- Can you make the bug happen reliably? Run the code and confirm you see the exact same error. If you can't reproduce it, you can't verify a fix.

2. **Read the error carefully** -- The error message, stack trace, and line number are clues. Read the FULL message. Copy it. Don't paraphrase.

3. **Form one hypothesis** -- Based on the error, what is the single most likely cause? Write it down as a sentence: "I think X is happening because Y."

4. **Add one diagnostic** -- Add a single `console.log`, breakpoint, or assertion to confirm or disprove your hypothesis. Just one -- not five.

5. **Test and conclude** -- Run the code again.
   - **Hypothesis confirmed?** Write the fix, remove the diagnostic, verify the fix.
   - **Hypothesis wrong?** Good -- you learned something. Form a new hypothesis and go back to step 3.

## Example output

```
## Bug
"TypeError: Cannot read properties of undefined (reading 'name')"
at src/components/UserCard.tsx:12

## Reproduce
Clicking "View Profile" on a user with no recent activity triggers the error.

## Hypothesis 1
The `user.profile` object is undefined for inactive users because the API
doesn't return a profile field when there's no activity.

## Diagnostic
Added: console.log("profile value:", user.profile)
Result: logs `undefined` for inactive users -- hypothesis confirmed.

## Fix
Added optional chaining: `user.profile?.name ?? "Unknown"`
Tested with both active and inactive users -- no more error.
```

## The golden rule

**Change one thing at a time.** If you change three things and the bug disappears, you don't know which change fixed it -- and the other two changes might introduce new bugs.

## Tips

- If you're stuck after 3 hypotheses, step back and re-read the error message from scratch. You may have misread it.
- Rubber duck it: explain the bug out loud (or to Claude) before diving deeper.
- Check the boring stuff first: typos, wrong variable names, missing imports, stale cache.
