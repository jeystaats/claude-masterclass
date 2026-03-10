# Workflow

## Commands

| Task | Command |
|------|---------|
| Install dependencies | `pnpm install` |
| Start dev server | `pnpm dev` (runs on port 3000) |
| Type check | `pnpm typecheck` |
| Lint | `pnpm lint` |
| Build | `pnpm build` |

## Git workflow
- Feature branches: `feat/[description]`, `fix/[description]`, `docs/[description]`
- Never commit directly to `main` — always use a branch + PR
- Run `pnpm typecheck` before committing
- Commit working increments often — don't wait for "done"

## Feature development loop
1. Create branch: `git checkout -b feat/feature-name`
2. Feed ticket to Claude with full context
3. Review: `git diff` + browser test + architecture check
4. Create PR: `gh pr create --title "feat: ..." --body "Closes #X"`
5. Merge: `gh pr merge`
6. Pull main: `git checkout main && git pull`

## Planning documents
Course planning documents live in the project root:
- `RESEARCH.md` — market research (Module 4)
- `docs/prd.md` — Product Requirements Document (Module 4)
- `docs/backlog.md` — tickets and priorities (Module 4)
- `docs/architecture.md` — tech stack and data model decisions (Module 4)

## Semantic commit format
```
feat(scope): add invoice creation form
fix(auth): resolve redirect after login
docs: add PRD and backlog
```
Types: feat, fix, refactor, docs, style, chore
