---
title: "DocuChat MVP - AI Document Q&A SaaS"
description: "6-week MVP plan for AI-powered document Q&A with freemium monetization"
status: pending
priority: P1
effort: 6 weeks (4 phases)
branch: main
tags: [saas, ai, nextjs, claude-api, mvp]
created: 2026-03-16
---

# DocuChat MVP Plan

## Tech Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Frontend | Next.js 15 + TypeScript + Tailwind + shadcn/ui | SSR, App Router, fast UI dev |
| Backend | Next.js API Routes + tRPC | Single deployment, type-safe E2E |
| Database | PostgreSQL (Supabase) | Auth, RLS, realtime, generous free tier |
| Vector DB | pgvector (Supabase extension) | No extra service; co-located with data |
| File Storage | Supabase Storage (S3-compatible) | Integrated with auth/RLS |
| AI | Claude API (claude-sonnet-4-20250514) | Best cost/quality ratio for RAG |
| Embeddings | Voyage AI or OpenAI text-embedding-3-small | Cheap, high-quality embeddings |
| Payments | Stripe Checkout + Webhooks | Industry standard, fast integration |
| Deploy | Vercel + Supabase Cloud | Zero-ops, auto-scaling |
| Auth | Supabase Auth (email + Google OAuth) | Built-in, no extra service |

## Architecture Overview

```
User -> Next.js (Vercel) -> tRPC API Routes
                              |-> Supabase Auth
                              |-> Supabase Storage (files)
                              |-> Supabase PostgreSQL + pgvector
                              |-> Claude API (answers)
                              |-> Embedding API (chunking/indexing)
                              |-> Stripe (billing)
```

**RAG Pipeline:** Upload -> Extract text -> Chunk (1000 tokens, 200 overlap) -> Embed -> Store vectors -> Query: embed question -> cosine similarity search -> top-5 chunks -> Claude prompt -> cited answer.

## Phases

| Phase | Focus | Duration | Status |
|-------|-------|----------|--------|
| [Phase 1](./phase-01-foundation.md) | Auth, DB schema, file upload, text extraction | Week 1-2 | pending |
| [Phase 2](./phase-02-rag-pipeline.md) | Embedding, vector search, Q&A with citations | Week 2-3 | pending |
| [Phase 3](./phase-03-collaboration-billing.md) | Team sharing, Stripe billing, usage limits | Week 4-5 | pending |
| [Phase 4](./phase-04-polish-launch.md) | UI polish, error handling, landing page, launch | Week 5-6 | pending |

## Infrastructure & Deployment

- **Vercel**: Auto-deploy from `main` (prod) and PR previews (staging)
- **Supabase**: Single project; use migrations via `supabase db push`
- **Env management**: Vercel env vars for secrets (API keys, Stripe, Supabase)
- **Monitoring**: Vercel Analytics + Sentry for error tracking
- **CI**: GitHub Actions -- lint, type-check, unit tests on PR

## Key Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| PDF parsing quality varies | Bad answers | Use `pdf-parse` + fallback to `mammoth`; show raw text preview for user validation |
| Claude API latency (2-5s) | Poor UX | Stream responses; show typing indicator; cache repeated questions |
| pgvector scale limits | Slow search at scale | Sufficient for MVP (<100K vectors); migrate to Pinecone later if needed |
| Embedding cost spikes | Budget blow | Batch embeddings; track usage per user; set processing limits |
| Stripe webhook reliability | Lost payments | Idempotent handlers; webhook retry + manual sync endpoint |
| Large file processing | Timeouts on Vercel (60s) | Queue via Supabase Edge Functions or Inngest for async processing |

## Unresolved Questions

- Exact embedding model choice (Voyage vs OpenAI) -- benchmark cost/quality in Phase 2
- Whether to use Inngest or Supabase Edge Functions for async file processing
- Team invitation flow: email-based or link-based (decide in Phase 3)
