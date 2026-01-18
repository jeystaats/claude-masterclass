# Claude Code Masterclass - Project Guide

This is the bootstrap project for the Claude Code Masterclass workshop. Claude Code will follow these conventions when helping you build.

## Approved Tech Stack

Use **only** these technologies. Do not suggest alternatives.

### Core Framework
| Technology | Version | Purpose |
|------------|---------|---------|
| Next.js | 15 | Full-stack React framework (App Router) |
| React | 19 | UI library |
| TypeScript | 5+ | Type safety |
| Tailwind CSS | 3.4+ | Styling |

---

## When to Use What (Decision Guide)

This is the most important section. Follow these rules exactly.

### Authentication — Use Clerk

**When someone says:** "login", "signup", "authentication", "user account", "profile", "protected route", "auth"

**Always use:** Clerk

```typescript
// Setup: wrap app in ClerkProvider
import { ClerkProvider } from '@clerk/nextjs';

// Protect routes
import { auth } from '@clerk/nextjs/server';
const { userId } = await auth();

// Get user in components
import { useUser } from '@clerk/nextjs';
const { user, isLoaded } = useUser();

// Pre-built components
<SignIn /> <SignUp /> <UserButton />
```

**Never suggest:** NextAuth, Auth0, Firebase Auth, Supabase Auth, custom JWT

---

### Database & Backend — Supabase or Convex

**When someone says:** "database", "save data", "store", "backend", "API", "real-time", "sync"

#### Choose Your Path:

| Experience Level | Recommended | Why |
|-----------------|-------------|-----|
| **Beginner** | Supabase | Familiar SQL, same as Lovable, easier to debug |
| **Intermediate+** | Convex | Real-time by default, type-safe, less boilerplate |

---

#### Option A: Supabase (Easier Start)

```typescript
// Install: npm install @supabase/supabase-js

// lib/supabase.ts - Create client
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

// Fetch data
const { data: tasks, error } = await supabase
  .from('tasks')
  .select('*')
  .eq('user_id', userId);

// Insert data
const { data, error } = await supabase
  .from('tasks')
  .insert({ title: 'New task', user_id: userId });
```

**Pros:** Familiar SQL model, great dashboard, same as Lovable uses
**Cons:** Not real-time by default, more boilerplate for mutations

---

#### Option B: Convex (Better Long-term)

```typescript
// Install: npm install convex

// convex/schema.ts - Define schema
export default defineSchema({
  tasks: defineTable({
    title: v.string(),
    completed: v.boolean(),
    userId: v.string(),
  }).index("by_user", ["userId"]),
});

// In your component - Real-time by default!
const tasks = useQuery(api.tasks.list);
const createTask = useMutation(api.tasks.create);

await createTask({ title: "New task" });
```

**Pros:** Real-time updates automatic, fully type-safe, less code
**Cons:** New paradigm to learn, validator syntax unfamiliar

---

**Never suggest:** Firebase, Prisma, Drizzle, PlanetScale, MongoDB

---

### Client State — Use Zustand

**When someone says:** "global state", "shared state", "modal state", "sidebar open", "theme", "cart", "preferences"

**Always use:** Zustand

```typescript
import { create } from 'zustand';

interface UIStore {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
}

export const useUIStore = create<UIStore>((set) => ({
  sidebarOpen: false,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}));

// Use in component
const { sidebarOpen, toggleSidebar } = useUIStore();
```

**Never suggest:** Redux, Jotai, Recoil, MobX, Context for complex state

---

### Server State & Data Fetching — Use TanStack Query

**When someone says:** "fetch data", "cache API response", "polling", "background refresh", "loading state"

**Always use:** TanStack Query (works great with Supabase!)

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';

// Fetch data with caching
const { data: tasks, isLoading } = useQuery({
  queryKey: ['tasks', userId],
  queryFn: async () => {
    const { data, error } = await supabase
      .from('tasks')
      .select('*')
      .eq('user_id', userId);
    if (error) throw error;
    return data;
  },
});

// Mutate with automatic refetch
const queryClient = useQueryClient();
const createTask = useMutation({
  mutationFn: async (title: string) => {
    const { data, error } = await supabase
      .from('tasks')
      .insert({ title, user_id: userId });
    if (error) throw error;
    return data;
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['tasks'] });
  },
});
```

**Note:** TanStack Query handles loading states, caching, and refetching automatically.

---

### Forms — Use React Hook Form + Zod

**When someone says:** "form", "input", "validation", "submit"

**Always use:** React Hook Form + Zod

```typescript
// 1. Define schema
const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

// 2. Use in form
const form = useForm<z.infer<typeof schema>>({
  resolver: zodResolver(schema),
});

// 3. Submit
<form onSubmit={form.handleSubmit(onSubmit)}>
  <input {...form.register('email')} />
  {form.formState.errors.email?.message}
</form>
```

**Never suggest:** Formik, custom validation, inline validation

---

### Animation — Use GSAP or Framer Motion

**Decision tree:**

| Scenario | Use |
|----------|-----|
| Scroll animations | GSAP + ScrollTrigger |
| Timeline sequences | GSAP |
| Hover/tap effects | Framer Motion |
| Layout animations | Framer Motion |
| Page transitions | Framer Motion |
| Complex orchestration | GSAP |

```typescript
// GSAP for scroll-based
useGSAP(() => {
  gsap.from('.card', {
    scrollTrigger: { trigger: '.card', start: 'top 80%' },
    y: 50,
    opacity: 0,
  });
});

// Framer Motion for interactions
<motion.button whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
  Click
</motion.button>
```

---

### Smooth Scrolling — Use Lenis

**When someone says:** "smooth scroll", "scroll experience", "scroll feel"

```typescript
import Lenis from '@studio-freight/lenis';

useEffect(() => {
  const lenis = new Lenis();
  function raf(time: number) {
    lenis.raf(time);
    requestAnimationFrame(raf);
  }
  requestAnimationFrame(raf);
}, []);
```

---

### CMS / Content — Use Storyblok (Optional)

**When someone says:** "CMS", "content management", "blog", "marketing pages", "editor"

**Use:** Storyblok with visual editor

---

## State Management Decision Tree

```
Where does the data come from?

├── Database
│   ├── Using Supabase?
│   │   └── Use: TanStack Query + Supabase client
│   └── Using Convex?
│       └── Use: Convex's useQuery / useMutation (already real-time!)
│
├── External API (weather, stocks, etc.)
│   └── Use: TanStack Query
│
├── User input (forms)
│   └── Use: React Hook Form
│
└── UI state (no server)
    ├── Shared across components?
    │   ├── Yes → Use: Zustand
    │   └── No → Use: useState
    └── URL state (filters, pagination)?
        └── Use: nuqs or URL search params
```

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

---

## Project Structure

```
src/
├── app/                    # Next.js 15 App Router
│   ├── (auth)/            # Auth routes (login, signup)
│   ├── (dashboard)/       # Protected routes
│   ├── api/               # API routes (if needed)
│   └── layout.tsx         # Root layout with providers
├── components/
│   ├── ui/                # Generic: Button, Card, Input
│   └── features/          # Domain: LoginForm, TaskList
├── lib/
│   ├── supabase.ts        # Supabase client (if using Supabase)
│   ├── utils.ts           # cn() and helpers
│   └── schemas/           # Zod validation schemas
├── hooks/                 # Custom React hooks
└── stores/                # Zustand stores

# If using Convex, add:
convex/
├── schema.ts              # Database schema
├── tasks.ts               # Task functions
└── users.ts               # User functions
```

---

## Database + Clerk Integration

### Option A: Supabase + Clerk

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

// Use Clerk's userId to associate data
import { auth } from '@clerk/nextjs/server';

export async function getUserTasks() {
  const { userId } = await auth();
  if (!userId) return [];

  const { data } = await supabase
    .from('tasks')
    .select('*')
    .eq('user_id', userId);

  return data;
}
```

### Option B: Convex + Clerk

```typescript
// convex/schema.ts
export default defineSchema({
  users: defineTable({
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
  }).index("by_clerk_id", ["clerkId"]),
});

// convex/users.ts
export const getCurrentUser = query({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return null;

    return await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", identity.subject))
      .unique();
  },
});
```

---

## React Component Rules

### Component Classification

| Type | Location | Purpose |
|------|----------|---------|
| UI Components | `components/ui/` | Generic, reusable (Button, Card, Input) |
| Feature Components | `components/features/` | Domain-specific (LoginForm, UserCard) |
| Page Components | Co-located with page | Single-use, page-specific |

### DRY & KISS Principles

1. **One component = one job** — Split if doing multiple things
2. **Max 5-7 props** — More = code smell, consider composition
3. **Check for duplicates** — Before creating, search for similar components
4. **Extract repeated patterns** — Tailwind classes, logic, structure

### Prop Drilling Prevention

```typescript
// ❌ BAD - Passing props through 3+ levels
<Parent user={user}>
  <Child user={user}>
    <GrandChild user={user} />
  </Child>
</Parent>

// ✅ GOOD - Use Zustand or Context
const user = useUserStore((s) => s.user);
```

### TypeScript Standards

```typescript
// ✅ Always type props explicitly
interface ButtonProps {
  variant: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  onClick?: () => void;
}

// ✅ Export types for reuse
export type { ButtonProps };

// ✅ Use discriminated unions for variants
type CardProps =
  | { variant: 'metric'; value: number; label: string }
  | { variant: 'content'; title: string; body: string };
```

---

## Server vs Client Components (Next.js 15)

### Default = Server Component

Components are Server Components by default. Only add `'use client'` when needed.

### Must be Client Component if:

| Requirement | Example |
|-------------|---------|
| React hooks | `useState`, `useEffect`, `useContext` |
| Event handlers | `onClick`, `onChange`, `onSubmit` |
| Browser APIs | `window`, `document`, `localStorage` |
| Interactivity | Animations, forms, toggles |

### Must be Server Component if:

| Requirement | Example |
|-------------|---------|
| Data fetching | `async/await`, database calls |
| Sensitive data | API keys, secrets |
| Large dependencies | Keep off client bundle |
| No interactivity | Static content |

### The Composition Pattern

```typescript
// ✅ Server Component (parent) fetches data
async function ProductPage({ id }: { id: string }) {
  const product = await getProduct(id); // Server-side fetch

  return (
    <div>
      <ProductInfo product={product} />      {/* Server */}
      <AddToCartButton id={id} />            {/* Client */}
    </div>
  );
}

// ✅ Client Component (child) handles interactivity
'use client';
function AddToCartButton({ id }: { id: string }) {
  const [loading, setLoading] = useState(false);
  // ... interaction logic
}
```

### Hydration Safety

```typescript
// ❌ BAD - Causes hydration mismatch
function Component() {
  return <div>{Date.now()}</div>;
}

// ✅ GOOD - Use useEffect for browser-only values
function Component() {
  const [time, setTime] = useState<number | null>(null);

  useEffect(() => {
    setTime(Date.now());
  }, []);

  return <div>{time ?? 'Loading...'}</div>;
}
```

---

## Icons — Use Phosphor Icons

```typescript
import { House, MagnifyingGlass, User } from '@phosphor-icons/react';

// Standard sizes
<House size={16} />  // Small
<House size={20} />  // Default
<House size={24} />  // Large

// With weight variants
<House weight="regular" />
<House weight="bold" />
<House weight="fill" />
```

**Never use:** Heroicons, Lucide, FontAwesome, or mixing icon libraries.

---

## Performance Rules

1. **60fps Minimum** — Never drop frames on scroll or animation
2. **Lazy Load Images** — Use `next/image` with proper `sizes`
3. **Code Split** — Use `dynamic()` for heavy components
4. **Respect Preferences** — Check `prefers-reduced-motion`

---

## Workshop Skills

| Command | Description |
|---------|-------------|
| `/workshop-start` | Create your first app in 5 minutes |

---

## What NOT to Do

| Don't Use | Use Instead | Why |
|-----------|-------------|-----|
| Redux | Zustand | Simpler, less boilerplate |
| NextAuth | Clerk | Pre-built UI, better DX |
| Firebase | Supabase or Convex | Better DX, type safety |
| Prisma/Drizzle | Supabase or Convex | Simpler for this workshop |
| CSS Modules | Tailwind CSS | Faster development |
| axios | fetch / TanStack Query | Native, smaller bundle |
| moment.js | date-fns | Smaller, tree-shakeable |
| Full lodash | Specific imports | Bundle size |
| Formik | React Hook Form | Better performance |

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

### cn() Utility
```typescript
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

---

*Built for the Claude Code Masterclass • Barcelona 2026*
