---
title: "Phase 4 - Polish, Landing Page & Launch"
status: pending
priority: P1
effort: 1 week
---

# Phase 4: Polish & Launch

## Context Links
- [Plan Overview](./plan.md)
- [Phase 3](./phase-03-collaboration-billing.md)

## Overview
Final polish: error handling, loading states, landing page, SEO, analytics, and launch prep. Ship to production.

## Key Insights
- Landing page is the #1 conversion driver; keep it focused on one CTA
- Error boundaries prevent white screens; graceful degradation > crashes
- Sentry catches what tests miss; set up before launch, not after

## Requirements

**Functional:**
- Marketing landing page with feature highlights, pricing, CTA
- Global error boundaries and toast notifications
- Loading skeletons for all async operations
- SEO meta tags, Open Graph images
- Analytics (page views, sign-ups, uploads, questions asked)
- Onboarding flow: first-upload guided experience

**Non-functional:**
- Lighthouse score > 90 (performance, accessibility)
- Landing page LCP < 2.5s
- Zero unhandled promise rejections in prod

## Key Files to Create

```
src/
├── app/
│   ├── (marketing)/
│   │   ├── page.tsx                  # Landing page
│   │   ├── pricing/page.tsx          # Pricing page
│   │   └── layout.tsx                # Marketing layout (no sidebar)
│   ├── error.tsx                     # Global error boundary
│   ├── loading.tsx                   # Global loading state
│   └── not-found.tsx                 # 404 page
├── components/
│   ├── landing/
│   │   ├── hero-section.tsx
│   │   ├── features-section.tsx
│   │   ├── pricing-section.tsx
│   │   ├── testimonial-section.tsx
│   │   └── cta-section.tsx
│   ├── onboarding-wizard.tsx
│   ├── toast-provider.tsx
│   └── skeleton-loaders.tsx
├── lib/
│   ├── analytics.ts                  # PostHog or Plausible wrapper
│   └── sentry.ts                     # Sentry init
```

## Implementation Steps

1. **Error handling**: Add error boundaries at layout level; toast notifications for API errors
2. **Loading states**: Skeleton loaders for document list, chat messages, billing page
3. **Landing page**: Hero, features grid, pricing table, social proof, CTA
4. **SEO**: Meta tags, sitemap.xml, robots.txt, OG image
5. **Analytics**: PostHog (free tier) for product analytics; track key events
6. **Sentry**: Error monitoring with source maps
7. **Onboarding**: First-time user guided upload + first question
8. **Performance**: Image optimization, code splitting review, bundle analysis
9. **Launch checklist**: Domain, DNS, SSL (auto via Vercel), env vars, Stripe live mode

## Todo List

- [ ] Add global error boundaries
- [ ] Implement toast notification system
- [ ] Add skeleton loaders to all async views
- [ ] Build landing page (hero, features, pricing, CTA)
- [ ] Configure SEO meta tags and OG images
- [ ] Set up PostHog analytics with key events
- [ ] Integrate Sentry error monitoring
- [ ] Build first-time onboarding flow
- [ ] Run Lighthouse audit and fix issues
- [ ] Configure custom domain on Vercel
- [ ] Switch Stripe to live mode
- [ ] Final E2E testing pass
- [ ] Launch on Product Hunt / Indie Hackers

## Success Criteria
- Landing page converts > 5% visitors to sign-up
- Lighthouse performance score > 90
- Zero critical errors in first 48 hours post-launch
- Onboarding completion rate > 70%

## Risk Assessment
- **Launch day traffic spike**: Vercel auto-scales; Supabase free tier handles ~500 concurrent. Upgrade if needed.
- **Claude API cost at scale**: Monitor daily spend; set billing alerts at $50, $100, $200
- **First impressions**: Prioritize the upload->question->answer flow being flawless over feature breadth

## Launch Checklist

- [ ] All env vars set in Vercel production
- [ ] Stripe live mode with real prices
- [ ] Supabase production project (not dev)
- [ ] Custom domain with SSL
- [ ] Sentry DSN configured
- [ ] Analytics tracking verified
- [ ] RLS policies tested in production
- [ ] Backup strategy confirmed (Supabase daily backups)
- [ ] Support email set up
- [ ] Terms of Service and Privacy Policy pages
