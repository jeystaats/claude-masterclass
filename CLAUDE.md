# Claude Code Masterclass - Project Guide

This is the bootstrap project for the Claude Code Masterclass workshop. Claude Code will follow these conventions when helping you build.

## Approved Tech Stack

Use **only** these technologies. Do not suggest alternatives.

### Core Framework
| Technology | Version | Purpose |
|------------|---------|---------|
| Next.js | 15+ | Full-stack React framework (App Router) |
| React | 18/19 | UI library |
| TypeScript | 5+ | Type safety |
| Tailwind CSS | 3.4+ | Styling |

### Backend & Database
| Technology | Purpose |
|------------|---------|
| Convex | Real-time database + backend functions |
| Clerk | Authentication (SSO, social login) |

### State Management
| Library | Use For |
|---------|---------|
| Zustand | Client-side UI state (modals, cart, preferences) |
| TanStack Query | Server state caching (external APIs only) |
| Convex hooks | Convex data (real-time subscriptions) |

**Rule:** Never use Redux. Never mix state libraries incorrectly.

### Forms & Validation
| Library | Purpose |
|---------|---------|
| React Hook Form | Form state management |
| Zod | Schema validation (shared client + server) |
| @hookform/resolvers | Connect Zod to React Hook Form |

### Animation & Motion
| Library | Use For |
|---------|---------|
| GSAP | Complex animations, ScrollTrigger, timelines |
| Framer Motion | Simple component animations, page transitions |
| Lenis | Smooth scrolling |

**Rule:** Use GSAP for scroll-based and complex animations. Use Framer Motion for simple hover/tap effects and layout animations.

### CMS (Optional)
| Technology | Purpose |
|------------|---------|
| Storyblok | Headless CMS with visual editor |

---

## Design Principles

### The 60/30/10 Rule

Apply this color distribution to every interface:

```
60% — Dominant color (background, large surfaces)
       Usually neutral: white, off-white, dark gray

30% — Secondary color (cards, sections, containers)
       Complementary neutral or subtle tint

10% — Accent color (CTAs, highlights, key actions)
       ONE brand color, used sparingly
```

**Example:**
- 60%: `bg-slate-950` (dark background)
- 30%: `bg-slate-900` (card backgrounds)
- 10%: `bg-purple-500` (buttons, links, highlights)

### Color Rules

1. **ONE Accent Color** — Pick one. Stick to it. No rainbow UIs.
2. **No Decorative Gradients** — Gradients are for depth, not decoration
3. **Color for Meaning** — Red = error, Green = success, Blue = info
4. **Muted > Saturated** — Use `slate`, `zinc`, `neutral` over pure colors

### Layout Rules

1. **No Symmetric Grids** — Asymmetry creates visual interest
2. **Editorial Layouts** — Think magazine, not spreadsheet
3. **Generous Whitespace** — Let content breathe
4. **4px Grid System** — All spacing should be multiples of 4px

### Typography

1. **Two Fonts Maximum** — One for headings, one for body (or just one)
2. **Clear Hierarchy** — Large headlines, readable body text
3. **Responsive Scaling** — `text-4xl md:text-5xl lg:text-6xl`

---

## Coding Patterns

### Component Architecture

```
src/
├── app/                 # Next.js App Router pages
├── components/
│   ├── ui/             # Generic reusable (Button, Card, Input)
│   └── features/       # Domain-specific (LoginForm, UserCard)
├── lib/
│   ├── utils.ts        # Helper functions
│   └── schemas/        # Zod validation schemas
├── hooks/              # Custom React hooks
└── stores/             # Zustand stores
```

### State Management Decision Tree

```
Is it from an API/database?
├── Yes → Is it Convex data?
│         ├── Yes → Use useQuery/useMutation from Convex
│         └── No → Use TanStack Query
└── No → Is it shared across multiple components?
         ├── Yes → Use Zustand store
         └── No → Use useState
```

### Form Pattern

Always follow this structure:

```typescript
// 1. Define schema (lib/schemas/example.ts)
import { z } from 'zod';

export const exampleSchema = z.object({
  name: z.string().min(2, 'Name is required'),
  email: z.string().email('Invalid email'),
});

export type ExampleFormData = z.infer<typeof exampleSchema>;

// 2. Use in component
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

const form = useForm<ExampleFormData>({
  resolver: zodResolver(exampleSchema),
});
```

### Convex Patterns

**Function Types:**
- `query` — Read data (reactive, real-time)
- `mutation` — Write data (transactional)
- `action` — External API calls ONLY

**Always add indexes** for any field you query by:
```typescript
// convex/schema.ts
export default defineSchema({
  users: defineTable({
    email: v.string(),
    name: v.string(),
  }).index("by_email", ["email"]),
});
```

### Animation Pattern

```typescript
// GSAP for complex animations
import { gsap } from 'gsap';
import { useGSAP } from '@gsap/react';

useGSAP(() => {
  gsap.from('.hero-text', {
    y: 100,
    opacity: 0,
    duration: 1,
    stagger: 0.2,
  });
}, []);

// Framer Motion for simple interactions
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
>
  Click me
</motion.button>
```

---

## Performance Rules

1. **60fps Minimum** — Never drop frames on scroll or animation
2. **Lazy Load Images** — Use `next/image` with proper `sizes`
3. **Code Split** — Use `dynamic()` for heavy components
4. **Respect Preferences** — Check `prefers-reduced-motion`

```typescript
// Check for reduced motion
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches;
```

---

## Workshop Skills

These skills are pre-configured for you:

| Command | Description |
|---------|-------------|
| `/workshop-start` | Create your first app in 5 minutes |

---

## What NOT to Do

- **Don't use Redux** — Zustand is simpler and sufficient
- **Don't use CSS Modules** — Use Tailwind CSS
- **Don't use axios** — Use native fetch or TanStack Query
- **Don't use moment.js** — Use date-fns (if needed)
- **Don't use lodash entirely** — Import specific functions only
- **Don't suggest Firebase** — We use Convex
- **Don't suggest NextAuth** — We use Clerk

---

## Quick Reference

### Tailwind Color Palette (Dark Theme)
```
Background:     bg-slate-950
Surface:        bg-slate-900
Border:         border-slate-800
Text Primary:   text-white
Text Secondary: text-slate-400
Accent:         bg-purple-500 / text-purple-400
```

### Common Patterns
```typescript
// cn() utility for conditional classes
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

---

*Built for the Claude Code Masterclass • Barcelona 2026*
