# Coding Rules

These rules apply to every file in this project. Follow them without exception.

## TypeScript
- Strict mode is on — no `any`, no `@ts-ignore`
- Types in separate `.types.ts` files when complex (3+ properties)
- Use `interface` for object shapes, `type` for unions and aliases
- No implicit `any` — every function parameter must be typed

## React and Next.js
- App Router only — no `getServerSideProps`, no `getStaticProps`
- Server Components by default — add `"use client"` only when needed (event handlers, hooks, browser APIs)
- Named exports only — never `export default` for components
- One component per file

## Tailwind CSS v4
- Use design tokens from `globals.css`, never hardcode hex colors
- Use `cn()` for conditional classes — never string concatenation
- No inline `style={{}}` attributes

## File organization
- Components: `src/components/[domain]/[component-name].tsx`
- Pages: `src/app/[route]/page.tsx`
- API routes: `src/app/api/[route]/route.ts`
- Shared types: `src/types/[domain].types.ts`

## Code quality
- Components under 100 lines — split if longer
- No commented-out code in commits
- Every `fetch()` call has error handling
- Validate external data with Zod before using it
