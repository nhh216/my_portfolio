---
title: "Phase 3 - Team Collaboration & Stripe Billing"
status: pending
priority: P1
effort: 1.5 weeks
---

# Phase 3: Collaboration & Billing

## Context Links
- [Plan Overview](./plan.md)
- [Phase 2](./phase-02-rag-pipeline.md)

## Overview
Enable team document sharing and implement Stripe freemium billing. Free users get 3 documents; Pro ($19/mo) gets unlimited. Teams can share document collections.

## Key Insights
- Keep team model simple: owner invites members via email; all members see shared docs
- Stripe Checkout handles PCI compliance; no card forms needed
- Enforce limits server-side in tRPC middleware, not just UI
- Webhook idempotency key prevents duplicate subscription events

## Requirements

**Functional:**
- Create teams, invite members by email
- Share documents with team (all members can view + chat)
- Free plan: 3 document limit, enforced on upload
- Pro plan: unlimited documents, $19/mo via Stripe
- Billing portal for plan management (upgrade/downgrade/cancel)
- Usage dashboard showing document count vs limit

**Non-functional:**
- Stripe webhook processing < 2s
- Plan changes reflected immediately in UI
- Invitation emails sent within 30s

## Architecture

**DB Additions:**
```sql
create table public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner_id uuid references public.profiles(id),
  created_at timestamptz default now()
);

create table public.team_members (
  team_id uuid references public.teams(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  role text default 'member' check (role in ('owner', 'member')),
  joined_at timestamptz default now(),
  primary key (team_id, user_id)
);

create table public.document_shares (
  document_id uuid references public.documents(id) on delete cascade,
  team_id uuid references public.teams(id) on delete cascade,
  shared_by uuid references public.profiles(id),
  shared_at timestamptz default now(),
  primary key (document_id, team_id)
);

-- Add stripe fields to profiles
alter table public.profiles add column stripe_subscription_id text;
alter table public.profiles add column plan_expires_at timestamptz;
```

## Key Files to Create

```
src/
├── server/
│   ├── routers/
│   │   ├── teams.ts                  # Team CRUD, invite, members
│   │   ├── sharing.ts               # Document sharing with teams
│   │   └── billing.ts               # Plan info, portal URL
│   ├── services/
│   │   ├── stripe.ts                # Stripe client, helpers
│   │   ├── plan-limiter.ts          # Enforce doc limits per plan
│   │   └── email.ts                 # Team invitation emails (Resend)
│   └── middleware/
│       └── plan-guard.ts            # tRPC middleware checking plan limits
├── app/
│   ├── (dashboard)/
│   │   ├── teams/
│   │   │   ├── page.tsx             # Team list
│   │   │   └── [id]/page.tsx        # Team detail + members
│   │   ├── billing/page.tsx         # Plan & usage dashboard
│   │   └── settings/page.tsx        # Account settings
│   └── api/
│       ├── stripe/webhook/route.ts  # Stripe webhook handler
│       └── stripe/checkout/route.ts # Create checkout session
├── components/
│   ├── team-invite-modal.tsx
│   ├── share-document-modal.tsx
│   ├── plan-badge.tsx
│   ├── usage-meter.tsx
│   └── upgrade-prompt.tsx           # Shown when hitting free limit
supabase/
└── migrations/003_teams_billing.sql
```

## Implementation Steps

1. **Stripe setup**: Create product + price in Stripe dashboard; configure webhook endpoint
2. **Checkout flow**: "Upgrade to Pro" -> Stripe Checkout -> webhook confirms -> update `profiles.plan`
3. **Plan limiter middleware**: tRPC middleware checks doc count vs plan limit before upload
4. **Billing portal**: Stripe Customer Portal for self-service management
5. **Teams CRUD**: Create team, invite by email, accept invitation
6. **Document sharing**: Share doc to team; update RLS to allow team member access
7. **Invitation emails**: Use Resend for transactional emails
8. **Usage dashboard**: Show doc count, plan status, upgrade CTA
9. **Upgrade prompt**: When free user hits 3-doc limit, show modal with Stripe link

## Todo List

- [ ] Set up Stripe product, price, and webhook
- [ ] Implement Stripe Checkout session creation
- [ ] Build webhook handler with idempotency
- [ ] Create plan limiter tRPC middleware
- [ ] Build billing/usage dashboard page
- [ ] Implement upgrade prompt on limit hit
- [ ] Create teams schema migration
- [ ] Build team CRUD endpoints
- [ ] Implement email invitations via Resend
- [ ] Add document sharing to teams
- [ ] Update RLS policies for team access
- [ ] Add Stripe Customer Portal integration

## Success Criteria
- Free user blocked at 4th upload with clear upgrade CTA
- Pro subscription activates within 10s of payment
- Team members can view and chat with shared documents
- Cancellation reverts to free plan at period end

## Risk Assessment
- **Webhook failures**: Implement retry queue; add manual "sync subscription" admin endpoint
- **RLS complexity with teams**: Test thoroughly; shared docs must not leak to non-members
- **Email deliverability**: Use Resend (high deliverability); add SPF/DKIM records
