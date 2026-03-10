<!-- Overrides root CLAUDE.md for this module -->
<!-- Why: Module 9 is the capstone reference section. This CLAUDE.md demonstrates
     full production-grade engineering standards — it's a teaching artifact as much
     as a behavior file. Students study this as the "what a mature CLAUDE.md looks
     like" example from Module 2's CLAUDE.md Mastery lesson. -->

# Module 9: Commands & Resources — Production Standards

This module is a reference section. Students are reviewing and referencing material
they've learned. Claude's role shifts from teacher to expert collaborator.

---

## TypeScript standards

- Strict mode on — `"strict": true` in tsconfig.json
- No `any`, no `@ts-ignore`, no `as unknown as T` escape hatches
- Generics used where appropriate: `function fetchById<T>(id: string): Promise<T>`
- Utility types used correctly: `Partial<T>`, `Required<T>`, `Pick<T, K>`, `Omit<T, K>`
- Zod for runtime validation of all external data (API responses, form inputs, env vars)
- Discriminated unions for state machines: `type State = { status: "loading" } | { status: "success"; data: T } | { status: "error"; error: string }`

## React and Next.js standards

- Server Components by default, Client Components only for: event handlers, hooks, Web APIs
- `"use client"` at the top of the file, never in the middle
- No prop drilling more than 2 levels — use context or server-side data passing
- `useEffect` only for: syncing with external systems, browser APIs. Never for derived state.
- Error boundaries on all route segments
- Suspense boundaries for all async data fetching
- `next/image` for all images — never `<img>`
- `next/link` for all internal navigation — never `<a href>`

## Component architecture

- Single responsibility: one component does one thing
- Components under 100 lines — split into smaller pieces if longer
- Props interfaces above the component: `interface ButtonProps { ... }`
- Compound components for complex UI (Tabs, Accordion, Select)
- CVA (class-variance-authority) for components with 3+ style variants
- No inline styles — Tailwind only

## Testing (when tests are required)

- Unit tests for business logic and pure functions
- Integration tests for API routes
- No tests for UI layout (fragile, low value)
- Test file collocated: `[component].test.ts` next to `[component].ts`
- Vitest for all tests — never Jest

## Security

- Never expose secrets to the client — all secret env vars server-only
- Validate and sanitize all user input before database writes
- Use parameterized queries — never string interpolation in SQL
- Rate limit all public API routes
- Content Security Policy headers on all pages

## Performance

- Lazy load non-critical components: `const Chart = dynamic(() => import("./Chart"))`
- Images: always `next/image` with explicit `width` and `height`
- Fonts: `next/font` with `display: "swap"`
- Bundle analysis before shipping: `pnpm build && pnpm analyze`
- Core Web Vitals targets: LCP < 2.5s, CLS < 0.1, FID < 100ms

## Git and CI

- Semantic commits: `feat(scope): description` — see root CLAUDE.md
- PR description must include: what changed, why, how to test
- `pnpm typecheck` passes before every commit
- `pnpm lint` passes before every commit
- No direct commits to `main` — always branch + PR

## Code review checklist (what Claude checks before considering code done)

- [ ] TypeScript strict mode passes
- [ ] No `any` or `@ts-ignore`
- [ ] External data validated with Zod
- [ ] Error states handled (not just happy path)
- [ ] Loading states handled
- [ ] No hardcoded strings that should be env vars
- [ ] Component under 100 lines
- [ ] No console.log in committed code
