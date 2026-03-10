---
name: lah-commit-message
description: >
  Write a conventional commit message for staged changes. Invoke manually with
  /lah-commit-message after staging your changes with git add.
disable-model-invocation: true
---

<!-- WHY THIS SKILL EXISTS: Good commit messages are documentation that lives
forever. Conventional commits teach a structured format that makes git history
scannable, enables automated changelogs, and builds a professional habit early. -->

# /lah-commit-message -- Write clear, conventional commit messages

## Workflow

1. **Read the staged diff** -- Run `git diff --cached` to see exactly what changed. Don't guess from file names alone.

2. **Pick the type** -- Choose the one that best fits the change:

   | Type       | When to use                          |
   |------------|--------------------------------------|
   | `feat`     | New feature or capability            |
   | `fix`      | Bug fix                              |
   | `refactor` | Code change that doesn't fix or add  |
   | `docs`     | Documentation only                   |
   | `style`    | Formatting, whitespace, semicolons   |
   | `test`     | Adding or updating tests             |
   | `chore`    | Build config, dependencies, tooling  |

3. **Determine the scope** -- What area of code changed? Use a short word in parentheses: `feat(auth)`, `fix(api)`, `docs(readme)`. Skip the scope if the change is truly global.

4. **Write the subject** -- Complete this sentence: "This commit will ___." Use imperative mood, lowercase, no period, under 50 characters.

5. **Add a body if needed** -- If the "why" isn't obvious, add a blank line and 1-2 sentences explaining the motivation.

## Example output

```
feat(auth): add email verification on signup

Users were able to sign up with invalid emails, causing delivery
failures later. This adds a verification step before account creation.
```

## Good vs bad messages

```
# Bad -- vague, past tense, no type
"updated some stuff"
"fixed the bug"
"changes"

# Good -- typed, scoped, imperative, clear
feat(cart): add quantity selector to product page
fix(api): handle null response from payment provider
refactor(utils): extract date formatting into helper
```

## When to use

Run `/lah-commit-message` after you've staged changes with `git add` and before you commit. It reads your diff and writes the message for you.
