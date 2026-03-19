# Phase 04 - Dashboard

## Context Links
- [Plan Overview](./plan.md)
- [Phase 01 - Infrastructure](./phase-01-infrastructure.md)
- [Phase 03 - AI Engine](./phase-03-ai-engine.md)
- [Phase 05 - Auth & Billing](./phase-05-billing-auth.md)

## Overview
- **Priority**: P1
- **Status**: Pending
- **Effort**: 5 days
- **Depends on**: Phase 01, 03, 05
- Build the web dashboard: PR history with AI analysis, team velocity metrics, org settings

## Key Insights
- Next.js App Router + Server Components = fast initial load, minimal client JS
- Supabase Realtime can push new PR analyses to dashboard without polling
- shadcn/ui + Tailwind = production-quality UI without custom design system
- Keep pages to 3-4 max for MVP. Resist feature creep

## Requirements

### Functional
- Landing page with value prop + "Install GitHub App" CTA
- Dashboard home: team velocity summary (PRs merged, avg cycle time, avg risk)
- PR list: filterable by repo, author, risk score, date range
- PR detail: full AI analysis, risk breakdown, link to GitHub PR
- Org settings: manage repos, team members, billing
- Responsive design (works on mobile for quick checks)

### Non-Functional
- Dashboard loads in <2 seconds (LCP)
- PR list pagination (50 per page)
- Works in all modern browsers

## Architecture

### Page Structure
```
/ (landing page - public)
├── /login
├── /setup (post-installation)
├── /dashboard (protected)
│   ├── / (home - velocity overview)
│   ├── /prs (PR list with filters)
│   ├── /prs/[id] (PR detail)
│   └── /settings
│       ├── / (org settings)
│       ├── /repos (manage repos)
│       ├── /team (team members)
│       └── /billing (plan + usage)
```

### Component Architecture
```
src/components/
├── ui/                         # shadcn/ui primitives
│   ├── button.tsx
│   ├── card.tsx
│   ├── table.tsx
│   ├── badge.tsx
│   ├── select.tsx
│   ├── input.tsx
│   └── ... (installed via shadcn CLI)
├── dashboard/
│   ├── velocity-card.tsx       # Metric card (PRs merged, avg risk, etc.)
│   ├── pr-list-table.tsx       # PR table with sorting/filtering
│   ├── pr-risk-badge.tsx       # Color-coded risk score badge
│   ├── pr-detail-panel.tsx     # Full analysis display
│   ├── activity-chart.tsx      # Simple bar/line chart (last 4 weeks)
│   ├── repo-selector.tsx       # Repo filter dropdown
│   └── nav-sidebar.tsx         # Dashboard navigation
├── landing/
│   ├── hero-section.tsx
│   ├── feature-grid.tsx
│   └── pricing-section.tsx
└── layout/
    ├── dashboard-layout.tsx    # Sidebar + header + content
    └── auth-guard.tsx          # Redirect unauthenticated users
```

### Data Fetching Strategy

**Server Components** (default) for:
- Dashboard home metrics (aggregated queries)
- PR list (paginated, server-side filtering)
- Settings pages

**Client Components** only for:
- Interactive filters (repo selector, date picker)
- Real-time PR analysis status updates
- Charts (requires client-side rendering)

### Key Queries

**Dashboard Home - Velocity Metrics:**
```sql
-- PRs merged this week
SELECT COUNT(*) FROM pull_requests
WHERE repo_id IN (SELECT id FROM repositories WHERE org_id = $1)
AND merged_at >= NOW() - INTERVAL '7 days';

-- Average risk score this week
SELECT AVG(risk_score)::NUMERIC(3,1) FROM pull_requests
WHERE repo_id IN (SELECT id FROM repositories WHERE org_id = $1)
AND analyzed_at >= NOW() - INTERVAL '7 days';

-- Average cycle time (open to merge)
SELECT AVG(EXTRACT(EPOCH FROM (merged_at - created_at)) / 3600)::NUMERIC(5,1) as avg_hours
FROM pull_requests
WHERE repo_id IN (SELECT id FROM repositories WHERE org_id = $1)
AND merged_at >= NOW() - INTERVAL '7 days';
```

**PR List (paginated):**
```sql
SELECT pr.*, r.github_repo_name
FROM pull_requests pr
JOIN repositories r ON r.id = pr.repo_id
WHERE r.org_id = $1
AND ($2::TEXT IS NULL OR r.id = $2::UUID)           -- repo filter
AND ($3::INT IS NULL OR pr.risk_score >= $3)         -- min risk filter
ORDER BY pr.created_at DESC
LIMIT 50 OFFSET $4;
```

### Charts Library
- **Recharts** - lightweight, React-native, good enough for MVP
- Only 2 charts needed:
  1. Weekly PR volume (bar chart, last 8 weeks)
  2. Risk score distribution (horizontal bar or donut)

## Implementation Steps

1. **Landing page**
   - Hero section: headline, subheadline, "Install on GitHub" button
   - Feature grid: 3 cards (AI Summaries, Risk Scores, Team Velocity)
   - Pricing section: Free vs Pro comparison table
   - Simple, fast, static page (no data fetching)

2. **Install shadcn/ui components**
   - `npx shadcn@latest add button card table badge select input tabs avatar dropdown-menu separator sheet`
   - Create custom `pr-risk-badge.tsx` component (green/yellow/red based on score)

3. **Dashboard layout**
   - Sidebar navigation: Home, Pull Requests, Settings
   - Header with org switcher (future-proofing for multi-org) and user avatar
   - Mobile: collapsible sidebar via Sheet component
   - Auth guard: check Supabase session, redirect to `/login` if none

4. **Dashboard home page** (`src/app/(dashboard)/dashboard/page.tsx`)
   - Server Component fetching aggregated metrics
   - 4 velocity cards: PRs This Week, Avg Risk Score, Avg Cycle Time, Active Repos
   - Activity chart (last 8 weeks of PR volume)
   - Recent PRs table (last 10)

5. **PR list page** (`src/app/(dashboard)/dashboard/prs/page.tsx`)
   - Server-side paginated table
   - Client-side filter bar: repo dropdown, risk score range, date range
   - URL search params for filter state (shareable URLs)
   - Columns: PR title, repo, author, risk score, status, date

6. **PR detail page** (`src/app/(dashboard)/dashboard/prs/[id]/page.tsx`)
   - Full AI summary display
   - Risk score with visual indicator
   - Risk factors as tagged list
   - File change stats
   - Link to PR on GitHub
   - Re-analyze button (triggers new Inngest event)

7. **Settings pages**
   - Org settings: org name, avatar (read from GitHub)
   - Repos: list connected repos, toggle active/inactive
   - Team: list members (synced from GitHub org)
   - Billing: current plan, usage, upgrade/manage button (links to Stripe portal)

8. **Install Recharts**
   - `npm install recharts`
   - Build activity chart component
   - Build risk distribution component

## Todo List

- [ ] Build landing page (hero, features, pricing)
- [ ] Install shadcn/ui components needed
- [ ] Create dashboard layout with sidebar navigation
- [ ] Build auth guard / middleware for protected routes
- [ ] Implement dashboard home page with velocity cards
- [ ] Build PR list page with server-side pagination
- [ ] Build filter bar (repo, risk, date) with URL search params
- [ ] Build PR detail page with full analysis display
- [ ] Create risk badge component (color-coded)
- [ ] Install Recharts, build activity chart
- [ ] Build settings: org, repos, team, billing pages
- [ ] Add loading states (Suspense boundaries + skeletons)
- [ ] Add empty states for new orgs (no data yet)
- [ ] Mobile responsive pass on all pages
- [ ] Verify <2s LCP on dashboard pages

## Success Criteria

- Landing page renders statically, <1s load
- Dashboard shows correct metrics from DB
- PR list paginates correctly with filters
- PR detail shows full AI analysis
- Settings pages functional (repos toggle, billing link)
- All pages responsive on mobile
- Loading/empty states handled gracefully

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Slow dashboard queries | Medium | High | Add DB indexes on (org_id, created_at), (repo_id, merged_at) |
| UI complexity creep | High | Medium | Stick to 4 pages max. No custom design system. shadcn defaults |
| Chart rendering issues | Low | Low | Recharts is battle-tested. Fallback to simple number displays |
| Mobile usability | Medium | Medium | Test early on mobile, sidebar collapse via Sheet |

## Security Considerations
- All dashboard routes behind auth middleware (Supabase session check)
- RLS ensures users only see their org's data
- No sensitive data (tokens, keys) ever rendered client-side
- CSRF protection via Supabase auth cookies (SameSite=Lax)

## Next Steps
- After MVP launch, iterate on dashboard based on user feedback
- Phase 2 (Growth) adds: Slack notifications, technical debt scanner
- Consider Supabase Realtime for live-updating PR analysis status
