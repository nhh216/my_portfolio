# Phase 02 - GitHub Integration

## Context Links
- [Plan Overview](./plan.md)
- [Phase 01 - Infrastructure](./phase-01-infrastructure.md)
- [GitHub Apps Docs](https://docs.github.com/en/apps)

## Overview
- **Priority**: P1 (Critical Path)
- **Status**: Pending
- **Effort**: 5 days
- **Depends on**: Phase 01
- Build GitHub App: OAuth login, installation flow, webhook processing for PR events

## Key Insights
- GitHub App (not OAuth App) is the correct choice. Apps act as bots, get installation tokens per-org, support fine-grained permissions, and post as the app identity
- Webhook verification via HMAC-SHA256 is mandatory for security
- Installation tokens expire after 1 hour; must refresh on demand
- Rate limiting: 5000 requests/hour per installation. Sufficient for MVP

## Requirements

### Functional
- Users install DevFlow GitHub App in 60 seconds
- App receives webhooks for: `pull_request.opened`, `pull_request.synchronize`, `pull_request.closed`, `installation.created`, `installation.deleted`
- App can read PR diffs, file contents, post PR comments
- OAuth flow for user login (separate from app installation)

### Non-Functional
- Webhook processing <5s end-to-end
- Idempotent webhook handling (GitHub retries on failure)
- Graceful handling of rate limits

## Architecture

### GitHub App Configuration
```
App Name: DevFlow AI
Homepage URL: https://devflow.ai
Callback URL: https://devflow.ai/api/auth/callback/github
Setup URL: https://devflow.ai/setup (post-installation redirect)
Webhook URL: https://devflow.ai/api/webhooks/github

Permissions:
  Repository:
    - Pull requests: Read & Write (post comments)
    - Contents: Read (read diffs, files)
    - Metadata: Read
  Organization:
    - Members: Read

Events:
  - Pull request
  - Installation
```

### Webhook Processing Flow
```
GitHub ──webhook──► /api/webhooks/github
                         │
                    Verify HMAC signature
                         │
                    Parse event type
                         │
                    ┌─────┴──────┐
                    │            │
              installation   pull_request
                    │            │
              Upsert org    Enqueue to Inngest
              in DB         "pr.analyze" event
                              │
                         [Phase 3 handles]
```

### Key Files to Create
```
src/
├── app/api/webhooks/github/route.ts    # Webhook endpoint
├── lib/github/
│   ├── app.ts                          # GitHub App client (Octokit)
│   ├── webhooks.ts                     # Webhook verification + parsing
│   ├── installation.ts                 # Installation token management
│   ├── pull-request.ts                 # PR data fetching (diff, files, comments)
│   └── types.ts                        # GitHub-specific types
```

### Installation Token Caching Strategy
```typescript
// Simple in-memory cache with TTL. Tokens expire in 1hr, refresh at 50min.
const tokenCache = new Map<number, { token: string; expiresAt: number }>();

async function getInstallationToken(installationId: number): Promise<string> {
  const cached = tokenCache.get(installationId);
  if (cached && cached.expiresAt > Date.now() + 600_000) {
    return cached.token;
  }
  const token = await createInstallationToken(installationId);
  tokenCache.set(installationId, {
    token: token.token,
    expiresAt: new Date(token.expires_at).getTime(),
  });
  return token.token;
}
```

**Note**: In-memory cache is fine for Vercel serverless. Worst case: extra token refresh (cheap API call). No need for Redis at MVP scale.

## Implementation Steps

1. **Register GitHub App**
   - Go to GitHub Developer Settings > GitHub Apps > New
   - Configure permissions, events, URLs as specified above
   - Download private key (.pem file)
   - Note App ID and Client ID/Secret
   - Store private key as base64 in env var: `GITHUB_PRIVATE_KEY`

2. **Install Octokit**
   - `npm install @octokit/app @octokit/webhooks @octokit/rest`
   - Create `src/lib/github/app.ts` - initialize Octokit App instance

3. **Build webhook endpoint** (`src/app/api/webhooks/github/route.ts`)
   - POST handler that:
     - Reads raw body for HMAC verification
     - Verifies `x-hub-signature-256` header against `GITHUB_WEBHOOK_SECRET`
     - Parses `x-github-event` header
     - Routes to handler functions
     - Returns 200 immediately (processing happens async via Inngest)

4. **Handle `installation` events**
   - `installation.created`: Upsert organization in DB, store `installation_id`
   - `installation.deleted`: Mark org as deactivated (soft delete)
   - Fetch org details (name, avatar) via GitHub API

5. **Handle `pull_request` events**
   - `pull_request.opened` / `pull_request.synchronize`:
     - Upsert repo in DB if not exists
     - Upsert PR record with metadata (title, author, files changed, etc.)
     - Send Inngest event `"devflow/pr.opened"` with PR data
   - `pull_request.closed`:
     - Update PR state in DB, set `merged_at` if merged

6. **PR data fetching utilities** (`src/lib/github/pull-request.ts`)
   - `getPRDiff(installationId, owner, repo, prNumber)` - fetch diff via GitHub API
   - `getPRFiles(installationId, owner, repo, prNumber)` - list changed files
   - `postPRComment(installationId, owner, repo, prNumber, body)` - post AI summary as comment

7. **Setup URL handler** (`src/app/setup/page.tsx`)
   - Post-installation redirect page
   - Links GitHub installation to DevFlow org
   - Prompts user to complete signup if needed

8. **Testing with smee.io**
   - Use smee.io proxy for local webhook development
   - Add `WEBHOOK_PROXY_URL` env var for dev mode
   - Script in package.json: `"dev:webhooks": "smee -u $WEBHOOK_PROXY_URL -t http://localhost:3000/api/webhooks/github"`

## Todo List

- [ ] Register GitHub App on GitHub with correct permissions
- [ ] Store App ID, private key, webhook secret in env vars
- [ ] Install Octokit packages
- [ ] Create GitHub App client (`src/lib/github/app.ts`)
- [ ] Create installation token manager (`src/lib/github/installation.ts`)
- [ ] Build webhook route with HMAC verification
- [ ] Implement installation event handlers (create/delete)
- [ ] Implement pull_request event handlers (opened/synchronize/closed)
- [ ] Build PR data fetching utilities (diff, files, comments)
- [ ] Create post-installation setup page
- [ ] Setup smee.io for local development
- [ ] Write integration tests for webhook handlers
- [ ] Test full flow: install app, open PR, verify DB records

## Success Criteria

- GitHub App installable on a test org
- Webhooks received and verified successfully
- Installation creates org record in DB
- PR open creates PR record and triggers Inngest event
- PR diff retrievable via installation token
- Comments postable on PRs as the app

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Webhook delivery failures | Medium | Medium | Inngest retries, idempotent handlers, GitHub auto-retries |
| Rate limiting (5000/hr) | Low at MVP | High | Cache tokens, batch requests, monitor usage |
| Large PR diffs (>MB) | Medium | Medium | Truncate diff to 100KB, summarize file list for oversized PRs |
| Private key rotation | Low | High | Store as env var, document rotation procedure |

## Security Considerations
- HMAC-SHA256 verification on every webhook request (reject unsigned)
- Installation tokens scoped to specific org, short-lived (1hr)
- Private key stored as encrypted env var, never in code or logs
- Webhook endpoint rate-limited via Vercel to prevent abuse
- No raw GitHub tokens stored in DB; always fetch fresh installation tokens

## Next Steps
- Phase 3 (AI Engine) consumes the Inngest events dispatched here
- PR diff data feeds directly into Claude API for analysis
