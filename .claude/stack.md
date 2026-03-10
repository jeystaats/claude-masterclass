# Stack

Use **only** these technologies. Do not suggest alternatives unless the student explicitly asks.

| Layer | Technology | Version | Notes |
|-------|-----------|---------|-------|
| Framework | Next.js | 16 | App Router only — no Pages Router |
| UI | React | 19 | Use Server Components where possible |
| Language | TypeScript | 5 | Strict mode, no `any` |
| Styling | Tailwind CSS | v4 | CSS-first config — no tailwind.config.js |
| Auth | Clerk | latest | Always Clerk for auth, never roll your own |
| Payments | Stripe | latest | Always Stripe for payments |
| Package manager | pnpm | 9 | Never npm or yarn |

## When students ask "what should I use for X?"

| Need | Use | Never suggest |
|------|-----|---------------|
| Authentication | Clerk | NextAuth, Auth.js, custom JWT |
| Payments | Stripe | Paddle, LemonSqueezy (unless student explicitly wants it) |
| Database | Convex or Supabase (student picks in Module 4) | Firebase, MongoDB, PlanetScale |
| Styling | Tailwind CSS v4 | CSS Modules, styled-components, Emotion |
| State management | React built-ins (useState, useContext) | Redux, Zustand, Jotai |
