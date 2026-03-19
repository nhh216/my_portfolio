# Phase 03 - AI Engine (PR Analysis Pipeline)

## Context Links
- [Plan Overview](./plan.md)
- [Phase 02 - GitHub Integration](./phase-02-github-integration.md)
- [Anthropic API Docs](https://docs.anthropic.com/en/docs)

## Overview
- **Priority**: P1 (Core Value Prop)
- **Status**: Pending
- **Effort**: 4 days
- **Depends on**: Phase 02
- Build the AI-powered PR analysis pipeline: receives PR events, fetches diff, calls Claude API, generates summary + risk score, posts as GitHub comment

## Key Insights
- Claude Sonnet 4 is the sweet spot: fast enough for real-time (<15s), smart enough for code reasoning, cheaper than Opus
- Structured output via system prompt + JSON schema gives reliable risk scores
- Inngest handles retries, concurrency limits, and dead-letter queues without infrastructure
- Diff truncation strategy critical: large PRs can blow context window and costs

## Requirements

### Functional
- Analyze every PR opened/updated within 30 seconds
- Generate: 3-5 bullet summary, risk score (1-10), risk factors list
- Post analysis as formatted GitHub comment on PR
- Handle large diffs gracefully (truncate + note)
- Retry on Claude API failures (rate limit, timeout)

### Non-Functional
- p95 analysis time <30 seconds
- Cost per analysis <$0.05 (Sonnet-class model)
- Graceful degradation if AI service down

## Architecture

### Analysis Pipeline Flow
```
Inngest event: "devflow/pr.opened"
         │
    ┌────▼─────┐
    │ Fetch PR  │  GitHub API: get diff + file list
    │   Data    │
    └────┬─────┘
         │
    ┌────▼─────┐
    │ Prepare   │  Truncate diff (100KB max)
    │  Prompt   │  Add file summary for truncated files
    └────┬─────┘
         │
    ┌────▼─────┐
    │  Claude   │  Call Anthropic API
    │   API     │  Structured JSON response
    └────┬─────┘
         │
    ┌────▼─────┐
    │  Store +  │  Save to DB + post GitHub comment
    │  Publish  │
    └──────────┘
```

### Key Files to Create
```
src/lib/
├── ai/
│   ├── client.ts              # Anthropic SDK client
│   ├── prompts.ts             # System + user prompt templates
│   ├── analyze-pr.ts          # Core analysis function
│   ├── format-comment.ts      # Format AI output as GitHub markdown
│   └── types.ts               # AI response types
├── inngest/
│   ├── client.ts              # Inngest client instance
│   └── functions/
│       ├── analyze-pr.ts      # PR analysis Inngest function
│       └── weekly-digest.ts   # Weekly email digest function
src/app/api/inngest/route.ts   # Inngest serve endpoint
```

### Claude Prompt Design

**System Prompt:**
```
You are DevFlow AI, a senior code reviewer. Analyze the pull request diff and provide:
1. A concise summary (3-5 bullets) of what this PR does
2. A risk score from 1 (trivial) to 10 (critical/dangerous)
3. A list of specific risk factors

Risk scoring guide:
- 1-3: Small changes, well-scoped, low blast radius
- 4-6: Moderate changes, some complexity, affects core paths
- 7-10: Large changes, touches critical systems, security implications, missing tests

Respond in JSON format matching the schema exactly.
```

**Response Schema:**
```typescript
interface PRAnalysis {
  summary: string[];          // 3-5 bullet points
  risk_score: number;         // 1-10
  risk_factors: string[];     // specific concerns
  suggested_reviewers: string[]; // file-path based suggestions
  complexity: 'low' | 'medium' | 'high';
}
```

### Diff Truncation Strategy
1. If total diff <100KB: send full diff
2. If total diff >100KB:
   - Include full diff for files <10KB each
   - For large files: include first 200 lines + file summary (name, lines added/deleted)
   - Prepend note: "Note: Some files truncated due to size. Full file list included."
3. Always include complete file list with change stats regardless of truncation

## Implementation Steps

1. **Install Anthropic SDK**
   - `npm install @anthropic-ai/sdk`
   - Create `src/lib/ai/client.ts` with singleton client

2. **Build prompt templates** (`src/lib/ai/prompts.ts`)
   - System prompt with role, scoring guide, JSON schema
   - User prompt template: PR title, description, author, file list, diff
   - Keep prompts in separate file for easy iteration

3. **Core analysis function** (`src/lib/ai/analyze-pr.ts`)
   ```typescript
   async function analyzePR(prData: PRData): Promise<PRAnalysis> {
     const diff = truncateDiff(prData.diff, MAX_DIFF_SIZE);
     const response = await anthropic.messages.create({
       model: 'claude-sonnet-4-20250514',
       max_tokens: 1024,
       system: SYSTEM_PROMPT,
       messages: [{ role: 'user', content: buildUserPrompt(prData, diff) }],
     });
     return parseAnalysisResponse(response);
   }
   ```

4. **Setup Inngest**
   - `npm install inngest`
   - Create `src/lib/inngest/client.ts` - Inngest client
   - Create `src/app/api/inngest/route.ts` - serve endpoint

5. **PR analysis Inngest function** (`src/lib/inngest/functions/analyze-pr.ts`)
   ```typescript
   export const analyzePRFunction = inngest.createFunction(
     {
       id: 'analyze-pr',
       concurrency: { limit: 10 },  // Max 10 concurrent analyses
       retries: 3,
     },
     { event: 'devflow/pr.opened' },
     async ({ event, step }) => {
       const prData = await step.run('fetch-pr-data', () =>
         fetchPRData(event.data.installationId, event.data.owner, event.data.repo, event.data.prNumber)
       );

       const analysis = await step.run('analyze', () =>
         analyzePR(prData)
       );

       await step.run('save-and-post', () => Promise.all([
         savePRAnalysis(event.data.prId, analysis),
         postPRComment(event.data.installationId, event.data.owner, event.data.repo, event.data.prNumber, formatComment(analysis)),
       ]));
     }
   );
   ```

6. **Format GitHub comment** (`src/lib/ai/format-comment.ts`)
   - Markdown template with DevFlow branding
   - Risk score with emoji indicators (green/yellow/red)
   - Collapsible details section for risk factors
   - Footer with link to dashboard

7. **Weekly digest Inngest function** (`src/lib/inngest/functions/weekly-digest.ts`)
   - Cron trigger: `"0 9 * * 1"` (Monday 9am UTC)
   - Per org: query PR data for past 7 days
   - Compute metrics: PRs merged, avg risk score, top contributors, velocity trend
   - Send email via Resend to org members

8. **Error handling**
   - Claude API rate limit: Inngest retries with exponential backoff
   - Invalid JSON response: retry once, fallback to "Analysis unavailable" comment
   - GitHub API failure: retry via Inngest, mark analysis_status as 'failed' after exhausting retries

## Todo List

- [ ] Install Anthropic SDK
- [ ] Create Anthropic client singleton
- [ ] Write system prompt and user prompt templates
- [ ] Implement diff truncation logic
- [ ] Build core `analyzePR` function with JSON parsing
- [ ] Install and configure Inngest
- [ ] Create Inngest serve endpoint
- [ ] Build PR analysis Inngest function with steps
- [ ] Build GitHub comment formatter (markdown template)
- [ ] Implement `savePRAnalysis` DB function
- [ ] Build weekly digest Inngest cron function
- [ ] Install Resend SDK, create email templates
- [ ] Write unit tests for prompt building and diff truncation
- [ ] Write integration test: mock diff → Claude → formatted comment
- [ ] End-to-end test: open PR on test repo → comment appears

## Success Criteria

- PR opened on test repo triggers analysis within 30 seconds
- AI comment appears on PR with summary, risk score, risk factors
- Risk scores are reasonable (small typo fix = 1-2, large refactor = 6-8)
- Large diffs handled gracefully without API errors
- Failed analyses retry automatically and eventually succeed or mark as failed
- Weekly digest email sends with correct metrics

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Claude API rate limits | Medium | High | Inngest concurrency limit (10), exponential backoff |
| Hallucinated risk scores | Medium | Medium | Strict JSON schema, scoring guide in prompt, validate 1-10 range |
| Cost blowup on large repos | Low | High | Diff truncation, per-org daily analysis cap (100 PRs free tier) |
| Prompt injection via PR content | Low | Medium | Sanitize PR titles/descriptions, separate system/user prompts |
| Anthropic API outage | Low | High | Graceful degradation: post "Analysis pending" comment, retry later |

## Security Considerations
- Anthropic API key stored as encrypted env var
- PR diffs sent to Claude contain potentially sensitive code - document this in privacy policy
- Never log full diffs or AI responses (may contain secrets from code)
- Prompt injection: PR titles/descriptions passed as user content, never as system prompt
- Rate limit Inngest concurrency to prevent cost spikes

## Next Steps
- Phase 4 (Dashboard) displays the analysis results stored in DB
- Iterate on prompts based on real-world PR analysis quality
- Consider caching analysis results for re-synced PRs (same commit = same analysis)
