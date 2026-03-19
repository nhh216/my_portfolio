---
title: "Phase 1 - Foundation: Auth, Storage, Text Extraction"
status: pending
priority: P1
effort: 2 weeks
---

# Phase 1: Foundation

## Context Links
- [Plan Overview](./plan.md)

## Overview
Stand up the core infrastructure: authentication, database schema, file upload, and document text extraction. By end of phase, users can sign up, upload documents, and see extracted text.

## Key Insights
- Supabase provides auth + storage + postgres in one service, reducing integration complexity
- PDF/Word parsing must happen server-side; Next.js API routes handle this
- Text extraction quality directly impacts RAG quality downstream

## Requirements

**Functional:**
- Email + Google OAuth sign-up/sign-in
- Upload PDF, DOCX, TXT files (max 20MB)
- Extract and store raw text from uploaded documents
- Document list view with upload status
- Delete documents

**Non-functional:**
- File upload < 5s for 10MB files
- Text extraction < 30s for 100-page PDFs
- Secure: users only see their own documents (RLS)

## Architecture

**DB Schema (Supabase PostgreSQL):**
```sql
-- users: managed by Supabase Auth (auth.users)

create table public.profiles (
  id uuid references auth.users primary key,
  email text not null,
  display_name text,
  plan text default 'free' check (plan in ('free', 'pro')),
  stripe_customer_id text,
  created_at timestamptz default now()
);

create table public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  title text not null,
  file_path text not null,
  file_type text not null,
  file_size_bytes bigint,
  raw_text text,
  status text default 'processing' check (status in ('processing','ready','error')),
  error_message text,
  created_at timestamptz default now()
);

create table public.chunks (
  id uuid primary key default gen_random_uuid(),
  document_id uuid references public.documents(id) on delete cascade,
  content text not null,
  chunk_index int not null,
  embedding vector(1536),
  metadata jsonb default '{}'
);

-- RLS policies
alter table public.profiles enable row level security;
alter table public.documents enable row level security;
alter table public.chunks enable row level security;
```

## Key Files to Create

```
src/
├── app/
│   ├── layout.tsx                    # Root layout with auth provider
│   ├── page.tsx                      # Landing/redirect
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── signup/page.tsx
│   ├── (dashboard)/
│   │   ├── layout.tsx                # Dashboard shell with sidebar
│   │   └── documents/
│   │       ├── page.tsx              # Document list
│   │       └── [id]/page.tsx         # Single document view
│   └── api/trpc/[trpc]/route.ts     # tRPC handler
├── server/
│   ├── trpc/router.ts               # Root router
│   ├── trpc/context.ts              # Auth context
│   ├── routers/documents.ts         # Document CRUD
│   └── services/
│       ├── text-extractor.ts        # PDF/DOCX/TXT parsing
│       └── file-storage.ts          # Supabase storage wrapper
├── lib/
│   ├── supabase/client.ts           # Browser client
│   ├── supabase/server.ts           # Server client
│   └── supabase/middleware.ts       # Auth middleware
├── components/
│   ├── ui/                          # shadcn/ui components
│   ├── document-upload.tsx          # Upload dropzone
│   ├── document-list.tsx
│   └── document-card.tsx
supabase/
├── migrations/001_initial_schema.sql
└── config.toml
```

## Implementation Steps

1. **Project scaffold**: `npx create-next-app@latest docuchat --typescript --tailwind --app`
2. **Install deps**: `supabase`, `@trpc/server`, `@trpc/client`, `@trpc/next`, `pdf-parse`, `mammoth`, `zod`, `shadcn/ui`
3. **Supabase setup**: Create project, enable pgvector extension, run initial migration
4. **Auth flow**: Supabase Auth with middleware for route protection
5. **tRPC setup**: Server context with Supabase auth, root router
6. **File upload**: Supabase Storage bucket with 20MB limit, RLS policy
7. **Text extraction service**: Parse PDF (`pdf-parse`), DOCX (`mammoth`), TXT (raw read)
8. **Document CRUD**: Upload -> store file -> extract text -> update status
9. **Dashboard UI**: Document list, upload modal, status indicators

## Todo List

- [ ] Scaffold Next.js project with TypeScript + Tailwind
- [ ] Configure Supabase project and local dev
- [ ] Create DB migration with schema above
- [ ] Implement Supabase Auth (email + Google)
- [ ] Set up tRPC with auth context
- [ ] Build file upload to Supabase Storage
- [ ] Implement text extraction (PDF, DOCX, TXT)
- [ ] Build document list and detail pages
- [ ] Add RLS policies for all tables
- [ ] Write unit tests for text extraction service

## Success Criteria
- User can sign up, log in, upload a PDF, and see extracted text
- RLS prevents cross-user data access
- Upload + extraction completes within 30s for a 100-page PDF

## Risk Assessment
- **PDF parsing failures**: Some PDFs are scanned images; add error state and user message. OCR is out of MVP scope.
- **Supabase storage limits**: Free tier = 1GB; sufficient for MVP. Monitor usage.
