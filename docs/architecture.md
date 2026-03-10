# Architecture

> **How to fill this in:** Run `/plan` in Claude Code and I'll help you map out your system architecture. Fill in each section as your decisions get made — this document grows with your project.

---

## System Overview

[One paragraph describing how the system works end-to-end.]

## Data Flow

```
User → [Auth layer] → [App layer] → [Database]
```

## Key Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Database | Convex | Real-time, serverless, TypeScript-native |
| Auth | Clerk | Best DX, handles edge cases |
| Payments | Stripe | Industry standard |
| Deployment | Vercel | Best Next.js DX |

## File Structure

```
src/
├── app/               # Next.js App Router pages
├── components/        # React components
│   ├── ui/           # Generic UI components
│   └── domain/       # Business logic components
├── lib/              # Utilities and helpers
└── hooks/            # React hooks
convex/               # Convex backend
├── schema.ts         # Database schema
└── *.ts              # Queries, mutations, actions
```

## Database Schema

[Document your main tables here as they're defined]

## External Services

| Service | Purpose | Env var |
|---------|---------|---------|
| Clerk | Auth | NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY |
| Convex | Database | NEXT_PUBLIC_CONVEX_URL |
| Stripe | Payments | STRIPE_SECRET_KEY |

## Open Questions

- [ ] [Unresolved technical decision]
