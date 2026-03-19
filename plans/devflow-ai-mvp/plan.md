---
title: "DevFlow AI - Phase 1 MVP"
description: "SaaS platform for AI-driven PR summaries, risk scores, and team velocity dashboards via GitHub integration"
status: pending
priority: P1
effort: 6w
branch: main
tags: [feature, backend, frontend, ai, infra, auth]
created: 2026-03-16
---

# DevFlow AI - Phase 1 MVP

## Overview

End-to-end SaaS delivering AI PR analysis via GitHub App. Users install in 60s, get AI summaries + risk scores on every PR, view team velocity on a dashboard, receive weekly email digests.

## Tech Stack (Opinionated)

- **Backend**: Next.js 15 App Router (monorepo, API routes + SSR)
- **Database**: PostgreSQL via Supabase (auth + DB + realtime)
- **AI**: Claude API (Anthropic) for PR analysis
- **Queue**: Inngest (serverless event-driven, no infra to manage)
- **Hosting**: Vercel (zero-config, preview deploys, edge functions)
- **Auth**: Supabase Auth + GitHub OAuth
- **Email**: Resend (developer-friendly transactional email)
- **Billing**: Stripe Checkout + Usage-based metering
- **Monitoring**: Sentry + Vercel Analytics

## Phases

| # | Phase | Status | Effort | Link |
|---|-------|--------|--------|------|
| 1 | Infrastructure & CI/CD | Pending | 3d | [phase-01](./phase-01-infrastructure.md) |
| 2 | GitHub Integration | Pending | 5d | [phase-02-github-integration](./phase-02-github-integration.md) |
| 3 | AI Engine | Pending | 4d | [phase-03-ai-engine](./phase-03-ai-engine.md) |
| 4 | Dashboard | Pending | 5d | [phase-04-dashboard](./phase-04-dashboard.md) |
| 5 | Auth & Billing | Pending | 4d | [phase-05-billing-auth](./phase-05-billing-auth.md) |

**Total estimated effort**: ~21 working days (4.2 weeks), leaving 1.8 weeks buffer for testing, polish, launch prep.

## Dependencies

```
Phase 1 (Infra) ──► Phase 2 (GitHub) ──► Phase 3 (AI Engine)
     │                                         │
     ▼                                         ▼
Phase 5 (Auth/Billing) ──────────────► Phase 4 (Dashboard)
```

- Phase 2 depends on Phase 1 (DB schema, hosting)
- Phase 3 depends on Phase 2 (webhook data to analyze)
- Phase 4 depends on Phases 3 + 5 (needs data + auth)
- Phase 5 can start in parallel with Phase 2

## Key Architectural Decisions

1. **Monorepo with Next.js** - Single deploy, shared types, fastest iteration speed for a small team
2. **Supabase over custom auth** - Auth, DB, row-level security out of the box. Saves 2+ weeks
3. **Inngest over BullMQ/SQS** - Serverless queue, no Redis/infra, built-in retries, perfect for Vercel
4. **Claude API over OpenAI** - Superior code reasoning, longer context window for large diffs
5. **Vercel over AWS** - Zero DevOps overhead, preview deploys, edge functions, scales automatically

## Success Metrics (MVP)

- GitHub App installs in <60 seconds
- AI summary posted as PR comment within 30 seconds of PR open
- Dashboard loads in <2 seconds
- Weekly digest emails delivered reliably
- Stripe checkout flow converts free-to-paid
