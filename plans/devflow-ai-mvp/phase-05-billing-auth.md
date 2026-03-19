# Phase 05 - Auth & Billing

## Context Links
- [Plan Overview](./plan.md)
- [Phase 01 - Infrastructure](./phase-01-infrastructure.md)
- [Stripe Docs](https://docs.stripe.com)
- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)

## Overview
- **Priority**: P1
- **Status**: Pending
- **Effort**: 4 days
- **Depends on**: Phase 01 (can run in parallel with Phase 02)
- Implement GitHub OAuth login via Supabase Auth, multi-tenancy, Stripe billing with usage-based metering

## Key Insights
- Supabase Auth has built-in GitHub OAuth provider. Zero custom auth code needed
- Multi-tenancy via org_id foreign keys + RLS. No schema-per-tenant complexity
- Stripe Checkout handles PCI compliance. Never touch card numbers
- Usage-based billing via Stripe Metering API: report PR analyses, bill monthly
- Start with 2 plans: Free (50 PRs/mo) and Pro ($20/seat/mo, unlimited)

## Requirements

### Functional
- GitHub OAuth login (one-click via Supabase)
- Auto-create user record on first login
- Link user to org via GitHub org membership
- Stripe Checkout for upgrading to Pro
- Usage tracking: count PR analyses per org per month
- Billing portal: view invoices, update payment, cancel
- Free tier: 50 PR analyses/month, 1 repo
- Pro tier: unlimited analyses, unlimited repos, priority support

### Non-Functional
- Login flow <3 seconds end-to-end
- Billing webhook processing idempotent
- PCI compliant (never handle card data directly)

## Architecture

### Auth Flow
```
User clicks "Login with GitHub"
         │
    Supabase Auth ──► GitHub OAuth consent screen
         │
    Callback to /api/auth/callback
         │
    ┌────▼─────┐
    │  Upsert  │  Check if user exists in users table
    │   User   │  Create if new, update github_avatar if changed
    └────┬─────┘
         │
    ┌────▼─────┐
    │  Resolve │  Find orgs where user has GitHub App installed
    │   Orgs   │  Link user to org_members if not already
    └────┬─────┘
         │
    Redirect to /dashboard
```

### Billing Architecture
```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   DevFlow   │────►│    Stripe    │────►│   Webhook   │
│  Dashboard  │     │   Checkout   │     │   Handler   │
│ (upgrade)   │     │              │     │             │
└─────────────┘     └──────────────┘     └──────┬──────┘
                                                │
                                         Update org.plan
                                         in database
```

### Stripe Products & Prices
```
Product: DevFlow AI Pro
├── Price: $20/seat/month (recurring)
└── Meter: pr_analyses (usage-based, reported monthly)

Product: DevFlow AI Free
└── No price (free tier, enforced in application logic)
```

### Key Files to Create
```
src/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx              # Login page with GitHub button
│   │   └── api/auth/callback/route.ts  # OAuth callback handler
│   ├── api/stripe/
│   │   └── webhook/route.ts            # Stripe webhook endpoint
│   └── (dashboard)/dashboard/settings/
│       └── billing/page.tsx            # Billing settings page
├── lib/
│   ├── supabase/
│   │   ├── client.ts                   # Browser client
│   │   ├── server.ts                   # Server client
│   │   └── middleware.ts               # Auth middleware
│   ├── stripe/
│   │   ├── client.ts                   # Stripe SDK client
│   │   ├── checkout.ts                 # Create checkout session
│   │   ├── portal.ts                   # Create billing portal session
│   │   ├── usage.ts                    # Report usage to Stripe metering
│   │   └── webhooks.ts                 # Webhook event handlers
│   └── auth/
│       └── guards.ts                   # Auth + plan check utilities
├── middleware.ts                        # Next.js middleware (auth redirect)
```

### Multi-Tenancy Model

Simple org-based tenancy. All data scoped by `org_id`.

**RLS Policies:**
```sql
-- Users can only see their own orgs
CREATE POLICY "users_see_own_orgs" ON organizations
  FOR SELECT USING (
    id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid())
  );

-- Users can only see PRs from their orgs
CREATE POLICY "users_see_own_prs" ON pull_requests
  FOR SELECT USING (
    repo_id IN (
      SELECT r.id FROM repositories r
      JOIN org_members om ON om.org_id = r.org_id
      WHERE om.user_id = auth.uid()
    )
  );

-- Similar policies for repositories, digest_logs
```

### Usage Enforcement Logic
```typescript
async function checkUsageLimit(orgId: string): Promise<boolean> {
  const org = await getOrg(orgId);
  if (org.plan === 'pro') return true; // unlimited

  const monthStart = startOfMonth(new Date());
  const count = await countPRAnalyses(orgId, monthStart);
  return count < FREE_TIER_LIMIT; // 50
}
```

Called in the Inngest PR analysis function before running Claude API. If over limit, post a comment: "DevFlow AI: Free tier limit reached (50/50 analyses this month). Upgrade to Pro for unlimited."

## Implementation Steps

1. **Configure Supabase Auth with GitHub provider**
   - In Supabase Dashboard: Authentication > Providers > GitHub
   - Add GitHub OAuth App client ID + secret (from the same GitHub App)
   - Set redirect URL to `https://devflow.ai/api/auth/callback`

2. **Build auth utilities**
   - `src/lib/supabase/client.ts` - browser Supabase client
   - `src/lib/supabase/server.ts` - server-side client (cookies-based)
   - `src/middleware.ts` - Next.js middleware: check session, redirect to /login if missing

3. **Login page** (`src/app/(auth)/login/page.tsx`)
   - Clean page with DevFlow logo + "Sign in with GitHub" button
   - Uses `supabase.auth.signInWithOAuth({ provider: 'github' })`

4. **OAuth callback handler** (`src/app/(auth)/api/auth/callback/route.ts`)
   - Exchange code for session
   - Upsert user record in `users` table
   - Resolve org membership (query `organizations` by GitHub installation, match user's GitHub orgs)
   - Redirect to `/dashboard`

5. **Setup Stripe**
   - Create Stripe account + products/prices
   - Install `stripe` SDK
   - Create `src/lib/stripe/client.ts` with Stripe instance

6. **Checkout flow** (`src/lib/stripe/checkout.ts`)
   ```typescript
   async function createCheckoutSession(orgId: string, seats: number) {
     return stripe.checkout.sessions.create({
       customer: org.stripe_customer_id || undefined,
       line_items: [{ price: STRIPE_PRO_PRICE_ID, quantity: seats }],
       mode: 'subscription',
       success_url: `${BASE_URL}/dashboard/settings/billing?success=true`,
       cancel_url: `${BASE_URL}/dashboard/settings/billing`,
       metadata: { org_id: orgId },
     });
   }
   ```

7. **Stripe webhook handler** (`src/app/api/stripe/webhook/route.ts`)
   - Verify Stripe signature
   - Handle events:
     - `checkout.session.completed`: Update org plan to 'pro', store `stripe_customer_id` + `stripe_subscription_id`
     - `customer.subscription.updated`: Sync plan status
     - `customer.subscription.deleted`: Downgrade to 'free'
     - `invoice.payment_failed`: Flag org, send notification

8. **Billing portal** (`src/lib/stripe/portal.ts`)
   - Create Stripe billing portal session
   - Link from settings/billing page
   - Users manage payment methods, view invoices, cancel directly in Stripe

9. **Usage reporting** (`src/lib/stripe/usage.ts`)
   - After each PR analysis, report usage event to Stripe Meter
   - `stripe.billing.meterEvents.create({ event_name: 'pr_analyses', ... })`
   - This enables usage-based billing in future (Phase 2)
   - For MVP: just track count for enforcing free tier limit

10. **Billing settings page** (`src/app/(dashboard)/dashboard/settings/billing/page.tsx`)
    - Show current plan (Free/Pro)
    - Usage bar: "23/50 analyses used this month"
    - Upgrade button (Pro plan card with features)
    - Manage billing button (Stripe portal link)

## Todo List

- [ ] Configure GitHub OAuth in Supabase dashboard
- [ ] Build Supabase client/server utility files
- [ ] Create Next.js auth middleware
- [ ] Build login page with GitHub OAuth button
- [ ] Implement OAuth callback with user upsert + org resolution
- [ ] Write RLS policies for all tables
- [ ] Create Stripe account, products, prices
- [ ] Install Stripe SDK, create client
- [ ] Build checkout session creation
- [ ] Build Stripe webhook handler (signature verify + event handling)
- [ ] Build billing portal session creation
- [ ] Implement usage tracking (count analyses per org per month)
- [ ] Implement free tier enforcement in analysis pipeline
- [ ] Build billing settings page (plan, usage, upgrade, manage)
- [ ] Write tests for auth flow (mock Supabase)
- [ ] Write tests for webhook handler (mock Stripe events)
- [ ] End-to-end test: login → see dashboard → upgrade → Stripe checkout

## Success Criteria

- GitHub OAuth login works in <3 seconds
- New users auto-created in DB with correct org linkage
- RLS prevents cross-org data access
- Stripe Checkout completes, org upgrades to Pro
- Webhook correctly handles subscription lifecycle
- Free tier enforced at 50 analyses/month
- Billing page shows accurate usage and plan info

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| OAuth token expiry | Low | Medium | Supabase auto-refreshes tokens via middleware |
| Stripe webhook missed | Low | High | Stripe retries for 72hrs. Idempotent handlers. Manual sync button |
| RLS policy bugs | Medium | Critical | Thorough testing with multiple test users/orgs. Supabase RLS testing tools |
| Org resolution fails (user not in any installed org) | Medium | Medium | Show "no org found" page with instructions to install GitHub App |

## Security Considerations
- Never handle card data directly. Stripe Checkout is PCI-DSS compliant
- Stripe webhook signature verification on every request
- Supabase RLS enforces data isolation at DB level (defense in depth)
- Session cookies: HttpOnly, Secure, SameSite=Lax
- API routes validate session before any data access
- Stripe customer IDs stored in DB but never exposed to client
- Rate limit login attempts via Supabase built-in protection

## Next Steps
- Phase 2 (Growth) adds: team seat management, usage-based pricing tiers
- Consider adding Google/email login as alternative auth methods
- Enterprise SSO (SAML) planned for Phase 3
