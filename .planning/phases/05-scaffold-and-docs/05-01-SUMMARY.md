---
plan: 05-01
status: complete
duration: 6min
files_created:
  - src/lib/utils.ts
  - pnpm-lock.yaml
files_modified:
  - package.json
  - src/app/layout.tsx
  - .gitignore
---

## Summary

Wired the `cn()` utility and cleaned the Next.js 16 scaffold so the starter kit compiles clean and runs immediately after clone. Added `clsx` and `tailwind-merge` as runtime dependencies, created `src/lib/utils.ts` with the canonical `cn()` implementation, replaced the Geist font setup with a system font stack, added `viewport` export to satisfy the SEO metadata hook, and updated `.gitignore` to exclude `package-lock.json` while keeping `pnpm-lock.yaml` committed.

## Artifacts

### src/lib/utils.ts
```typescript
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

### package.json — added to `dependencies`
- `clsx: "^2.1.1"` (resolved: 2.1.1)
- `tailwind-merge: "^2.5.5"` (resolved: 2.6.1 — latest compatible)

### src/app/layout.tsx
- Removed `next/font/google` imports (Geist, Geist_Mono)
- Body now uses `className="font-sans antialiased"` (system font stack via Tailwind)
- Added `metadataBase` and `export const viewport: Viewport` to satisfy SEO hook
- Updated title/description to match starter kit context

### .gitignore
- Added `package-lock.json` (project uses pnpm; npm lockfile is noise)
- `pnpm-lock.yaml` is NOT ignored — committed as required

## Verification

```
cn() implementation: OK
clsx import: OK
tailwind-merge import: OK
Geist removed: OK
.gitignore: OK     (package-lock.json present)
pnpm-lock.yaml: OK (committed)
npx tsc --noEmit   → exit 0, no output
```

## Deviations from Plan

1. **Viewport export added** — The pre-commit SEO hook (`check-seo-metadata.sh`) blocked the write of `layout.tsx` without a `viewport` export and `metadataBase`. Added `export const viewport: Viewport` with `width: "device-width", initialScale: 1` and `metadataBase: new URL("https://claude-mastery.vercel.app")`. This is correct Next.js 15+ practice and not a regression.

2. **tailwind-merge resolved to 2.6.1** — `^2.5.5` resolved to the latest 2.x patch (2.6.1). No functional difference; semver range satisfied.
