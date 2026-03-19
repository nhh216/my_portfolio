# Phase 01 - Infrastructure & CI/CD

## Context Links
- [Plan Overview](./plan.md)

## Overview
- **Priority**: P1 (Critical Path)
- **Status**: Pending
- **Effort**: 3 days
- Foundation: monorepo setup, database schema, CI/CD pipeline, environment configuration

## Key Insights
- Next.js App Router is the fastest path to production for a startup. API routes + SSR + static pages in one deploy
- Supabase provides Postgres + Auth + Realtime + Storage. Eliminates need for separate auth service, ORM setup, migration tooling
- Vercel auto-scales, provides preview deploys per PR, edge functions for low-latency endpoints

## Requirements

### Functional
- Monorepo with shared TypeScript types
- PostgreSQL database with migration system
- CI/CD pipeline: lint, test, type-check, deploy
- Environment management (dev, staging, prod)

### Non-Functional
- <500ms API response times
- 99.9% uptime target
- Automated deployments on merge to main
- Preview deploys on every PR

## Architecture

### Project Structure
```
devflow-ai/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (auth)/             # Auth routes (login, callback)
│   │   ├── (dashboard)/        # Protected dashboard routes
│   │   ├── api/
│   │   │   ├── webhooks/       # GitHub webhook handlers
│   │   │   ├── inngest/        # Inngest function endpoint
│   │   │   └── stripe/         # Stripe webhook handler
│   │   ├── layout.tsx
│   │   └── page.tsx            # Landing page
│   ├── lib/
│   │   ├── supabase/           # Supabase client + server utils
│   │   ├── github/             # GitHub API + webhook utils
│   │   ├── ai/                 # Claude API integration
│   │   ├── stripe/             # Stripe helpers
│   │   ├── email/              # Resend email utils
│   │   └── inngest/            # Inngest client + functions
│   ├── components/             # Shared UI components
│   │   ├── ui/                 # Primitives (shadcn/ui)
│   │   └── dashboard/          # Dashboard-specific components
│   └── types/                  # Shared TypeScript types
├── supabase/
│   ├── migrations/             # SQL migrations
│   └── seed.sql                # Development seed data
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions CI
├── .env.local.example
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

### Database Schema (Core Tables)

```sql
-- Organizations (GitHub org or user account)
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  github_installation_id BIGINT UNIQUE NOT NULL,
  github_org_name TEXT NOT NULL,
  github_org_avatar_url TEXT,
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'team')),
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  github_username TEXT NOT NULL,
  github_avatar_url TEXT,
  email TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Org membership
CREATE TABLE org_members (
  org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  PRIMARY KEY (org_id, user_id)
);

-- Repositories tracked
CREATE TABLE repositories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  github_repo_id BIGINT UNIQUE NOT NULL,
  github_repo_name TEXT NOT NULL,
  github_repo_full_name TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Pull requests analyzed
CREATE TABLE pull_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  repo_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
  github_pr_id BIGINT NOT NULL,
  github_pr_number INT NOT NULL,
  title TEXT NOT NULL,
  author_github_username TEXT NOT NULL,
  state TEXT DEFAULT 'open',
  ai_summary TEXT,
  risk_score INT CHECK (risk_score BETWEEN 1 AND 10),
  risk_factors JSONB DEFAULT '[]',
  files_changed INT,
  lines_added INT,
  lines_deleted INT,
  analysis_status TEXT DEFAULT 'pending' CHECK (analysis_status IN ('pending', 'processing', 'completed', 'failed')),
  analyzed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  merged_at TIMESTAMPTZ,
  UNIQUE(repo_id, github_pr_number)
);

-- Weekly digest tracking
CREATE TABLE digest_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  sent_at TIMESTAMPTZ DEFAULT now(),
  period_start TIMESTAMPTZ NOT NULL,
  period_end TIMESTAMPTZ NOT NULL,
  metrics JSONB NOT NULL
);
```

### Tech Stack Specifics
| Tool | Version | Purpose |
|------|---------|---------|
| Next.js | 15.x | Fullstack framework |
| TypeScript | 5.x | Type safety |
| Supabase | latest | Auth + DB + Realtime |
| Tailwind CSS | 4.x | Styling |
| shadcn/ui | latest | Component library |
| Inngest | latest | Background jobs |
| Resend | latest | Transactional email |
| Vitest | latest | Testing |
| Biome | latest | Linting + formatting (faster than ESLint) |

## Implementation Steps

1. **Initialize Next.js project**
   - `npx create-next-app@latest devflow-ai --typescript --tailwind --app --src-dir`
   - Add Biome for linting: `npx @biomejs/biome init`
   - Install shadcn/ui: `npx shadcn@latest init`

2. **Setup Supabase**
   - Create Supabase project (dev + staging + prod)
   - Install `@supabase/supabase-js` and `@supabase/ssr`
   - Create server/client utility functions in `src/lib/supabase/`
   - Write initial migration with schema above
   - Setup Row Level Security policies

3. **Configure environment variables**
   - Create `.env.local.example` with all required vars
   - Setup Vercel environment variables for each environment
   - Variables: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `GITHUB_APP_ID`, `GITHUB_PRIVATE_KEY`, `GITHUB_WEBHOOK_SECRET`, `ANTHROPIC_API_KEY`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `RESEND_API_KEY`

4. **CI/CD Pipeline**
   - GitHub Actions workflow: type-check, lint, test on every PR
   - Vercel auto-deploy: preview on PR, production on merge to `main`
   - Branch protection: require CI pass + 1 review

5. **Monitoring setup**
   - Install Sentry: `@sentry/nextjs`
   - Configure Vercel Analytics
   - Add error boundary components

## Todo List

- [ ] Initialize Next.js 15 project with TypeScript + Tailwind
- [ ] Setup Biome linting and formatting
- [ ] Install and configure shadcn/ui
- [ ] Create Supabase project (dev environment)
- [ ] Write database migration with core schema
- [ ] Create Supabase client/server utility files
- [ ] Setup RLS policies for multi-tenancy
- [ ] Create `.env.local.example`
- [ ] Configure Vercel project and link repo
- [ ] Setup GitHub Actions CI workflow
- [ ] Install and configure Sentry
- [ ] Create seed data script for development
- [ ] Verify end-to-end: push to branch, CI runs, preview deploys

## Success Criteria

- `npm run build` succeeds with zero errors
- CI pipeline runs in <2 minutes
- Database migrations apply cleanly
- Preview deploy accessible on every PR
- All environment variables documented

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Supabase cold starts | Low | Medium | Use connection pooling (Supavisor), warm endpoints |
| Migration conflicts | Medium | Low | Squash migrations before prod, use Supabase branching |
| Env var leaks | Low | High | Never commit .env, use Vercel encrypted vars, audit CI logs |

## Security Considerations
- All secrets in Vercel encrypted environment variables, never in code
- Supabase RLS enforces multi-tenancy at database level
- Service role key only used server-side, never exposed to client
- CORS restricted to known domains

## Next Steps
- After infra is up, Phase 2 (GitHub Integration) can begin immediately
- Phase 5 (Auth/Billing) can start in parallel since it only needs Supabase
