---
title: "Phase 2 - RAG Pipeline: Embeddings, Search, Q&A"
status: pending
priority: P1
effort: 1.5 weeks
---

# Phase 2: RAG Pipeline

## Context Links
- [Plan Overview](./plan.md)
- [Phase 1](./phase-01-foundation.md)

## Overview
Core product value: chunking documents, generating embeddings, vector search, and Claude-powered Q&A with source citations. By end of phase, users can ask questions and get cited answers.

## Key Insights
- Chunk size of ~1000 tokens with 200-token overlap balances context vs precision
- Top-5 chunk retrieval keeps Claude prompt under 8K tokens (cost-effective)
- Streaming responses critical for perceived performance (Claude takes 2-5s)
- Citations = chunk index + page reference in metadata

## Requirements

**Functional:**
- Auto-chunk documents on upload (after text extraction)
- Generate and store embeddings per chunk
- Chat interface: ask questions about a document
- Streaming AI responses with typing indicator
- Source citations (clickable references to document sections)
- Conversation history per document

**Non-functional:**
- Answer latency < 5s (streaming first token < 1s)
- Relevant chunks in top-5 results for 90%+ of queries
- Embedding cost < $0.01 per document (avg 10 pages)

## Architecture

**RAG Flow:**
```
User Question
  -> Embed question (Embedding API)
  -> Vector similarity search (pgvector, top-5)
  -> Build prompt: system + context chunks + question
  -> Claude API (streaming)
  -> Parse response + extract citations
  -> Stream to client via SSE
```

**Claude Prompt Template:**
```
You are a document analysis assistant. Answer based ONLY on the provided context.
Cite sources using [1], [2] etc. If the answer isn't in the context, say so.

Context:
[1] {chunk_1_content} (Page {page_num})
[2] {chunk_2_content} (Page {page_num})
...

Question: {user_question}
```

**DB Additions:**
```sql
create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  document_id uuid references public.documents(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  title text,
  created_at timestamptz default now()
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade,
  role text check (role in ('user', 'assistant')),
  content text not null,
  citations jsonb default '[]',
  created_at timestamptz default now()
);

-- Vector similarity search index
create index on public.chunks using ivfflat (embedding vector_cosine_ops) with (lists = 100);
```

## Key Files to Create

```
src/
├── server/
│   ├── services/
│   │   ├── chunker.ts               # Text chunking with overlap
│   │   ├── embeddings.ts            # Embedding API client
│   │   ├── vector-search.ts         # pgvector similarity search
│   │   ├── rag-pipeline.ts          # Orchestrates chunk->embed->store
│   │   └── chat-service.ts          # Claude API streaming + citation parsing
│   └── routers/
│       ├── conversations.ts         # Conversation CRUD
│       └── chat.ts                  # Q&A endpoint (streaming)
├── app/
│   ├── (dashboard)/documents/[id]/
│   │   └── chat/page.tsx            # Chat interface for a document
│   └── api/chat/route.ts            # SSE streaming endpoint
├── components/
│   ├── chat-interface.tsx            # Chat UI with message list
│   ├── chat-message.tsx             # Single message with citations
│   ├── citation-badge.tsx           # Clickable citation reference
│   └── streaming-text.tsx           # Animated streaming text display
├── lib/
│   └── claude.ts                    # Claude API client wrapper
supabase/
└── migrations/002_conversations.sql
```

## Implementation Steps

1. **Chunking service**: Split raw text into ~1000 token chunks with 200 overlap; store page metadata
2. **Embedding service**: Batch embed chunks via API; store vectors in `chunks.embedding`
3. **Update upload flow**: After text extraction, auto-trigger chunk + embed pipeline
4. **Vector search**: pgvector cosine similarity query, return top-5 with scores
5. **Claude chat service**: Build RAG prompt, call Claude with streaming, parse citations
6. **SSE streaming endpoint**: Next.js route handler that streams Claude response to client
7. **Chat UI**: Message list, input box, streaming display, citation badges
8. **Conversation persistence**: Save Q&A pairs to `messages` table
9. **Processing status**: Show "Indexing..." while chunks are being embedded

## Todo List

- [ ] Implement text chunker with configurable size/overlap
- [ ] Build embedding service with batching
- [ ] Integrate chunking + embedding into upload pipeline
- [ ] Add pgvector similarity search function
- [ ] Build Claude RAG prompt builder
- [ ] Implement SSE streaming endpoint
- [ ] Create chat UI with streaming display
- [ ] Add citation parsing and display
- [ ] Create conversations table migration
- [ ] Persist conversation history
- [ ] Add "Indexing..." status during processing
- [ ] Test RAG quality with sample documents

## Success Criteria
- User uploads a 10-page PDF, asks a question, gets a cited answer in <5s
- Citations correctly reference the source chunks
- Conversation history persists across sessions

## Risk Assessment
- **Embedding API rate limits**: Batch with delays; show processing progress
- **Poor retrieval quality**: Tune chunk size; add keyword search fallback (hybrid search)
- **Claude hallucination**: Strong system prompt constraining to context only; "I don't know" for missing info
