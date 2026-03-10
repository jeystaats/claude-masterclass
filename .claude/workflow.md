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
- Feature branches: `feat/[description]`
- Bug fixes: `fix/[description]`
- Never commit directly to `main` — always use a branch + PR
- Run `pnpm typecheck` before committing

## Working with modules
1. Open the module folder: `modules/NN-[slug]/`
2. Read `README.md` for objectives
3. Open lesson files or `exercises/` folder
4. Use `PROGRESS.md` to track completion

## Starting a new feature
1. Create a feature brief in `exercises/feature-brief.md` (Module 6 pattern)
2. Ask Claude to review the brief before writing code
3. Build one ticket at a time — verify before moving on
4. Commit working increments with semantic commit messages

## Semantic commit format
```
feat(scope): add invoice creation form
fix(auth): resolve redirect after login
```
Types: feat, fix, refactor, docs, style, chore
