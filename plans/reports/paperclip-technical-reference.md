# Paperclip AI - Technical Reference Guide

**Last Updated:** 2026-03-16
**Project:** [paperclipai/paperclip](https://github.com/paperclipai/paperclip)
**License:** MIT
**Requirements:** Node.js 20+, pnpm 9.15+

---

## Core Concepts

### Agent
A single worker in the company with:
- **Identity:** Name, role, title, status
- **Hierarchy:** Reports to one agent, manages multiple agents
- **Execution:** Defined by adapter (how it runs)
- **Budget:** Monthly token limit
- **Schedule:** Heartbeat cron expression + event triggers

### Adapter
The "how" an agent executes. Maps Paperclip to actual runtime:
- **Type:** Defines runtime environment
- **Config:** Runtime-specific settings
- **Examples:** Claude Code, Hermes, HTTP webhook, shell process

### Heartbeat
Execution trigger for an agent:
- **Scheduled:** Cron-based wakeup (e.g., `0 * * * *` = hourly)
- **Event-Based:** Task assignment or @-mention triggers execution
- **Duration:** Short execution window where agent performs work
- **Context:** Agent resumes same task across multiple heartbeats

### Company
Organizational container with:
- **Mission:** High-level goal statement
- **Agents:** Reporting structure
- **Projects:** Goals and tasks
- **Budget:** Total monthly spend limit

---

## Configuration Model

### Complete Agent JSON Structure

```json
{
  "id": "uuid",
  "companyId": "uuid",

  // Identity
  "name": "Agent Name",
  "role": "CEO",
  "title": "Chief Executive Officer",
  "description": "Reviews executives, checks metrics, reprioritizes",
  "status": "active",

  // Hierarchy
  "reportsTo": "board-agent-uuid",
  "reportingAgents": [
    "cto-agent-uuid",
    "cfo-agent-uuid"
  ],

  // Execution Configuration
  "adapterType": "claude_local",
  "adapterConfig": {
    "model": "claude-3-5-sonnet",
    "systemPrompt": "You are the CEO...",
    "contextWindow": 200000,
    "tools": ["browser", "shell", "file"]
  },

  // Runtime Settings
  "runtimeConfig": {
    "heartbeatSchedule": "0 * * * *",
    "timeoutSeconds": 300,
    "maxIterations": 50,
    "persistSession": true,
    "workingDirectory": "/tmp/agent-workspace"
  },

  // Budget & Cost Control
  "monthlyTokenBudget": 1000000,
  "currentMonthUsage": 450000,
  "totalSpent": 4500000,

  // Secrets (not stored directly, only references)
  "secrets": {
    "apiKey": "{{SECRET_REF:openai_key}}",
    "dbUrl": "{{SECRET_REF:postgres_connection}}"
  },

  // Metadata
  "createdAt": "2026-01-15T10:30:00Z",
  "updatedAt": "2026-03-16T14:22:00Z",
  "lastHeartbeat": "2026-03-16T14:20:00Z",
  "createdBy": "user-uuid",
  "tags": ["core-team", "executive"]
}
```

---

## Adapter Type Reference

### 1. Claude Code Adapter (`claude_local`)

**Use Case:** Local Claude Code integration
**Platform:** Claude Code IDE
**Execution Model:** Runs in Claude Code terminal

```json
{
  "adapterType": "claude_local",
  "adapterConfig": {
    "model": "claude-3-5-sonnet",
    "systemPrompt": "Custom instructions for this agent",
    "tools": [
      "browser",
      "shell",
      "file",
      "execute"
    ],
    "contextWindow": 200000,
    "cacheTokenBudget": 24000,
    "temperature": 0.7
  }
}
```

### 2. Hermes Adapter (`hermes_local`)

**Use Case:** Nous Research Hermes agent
**Platform:** Hermes (local)
**Execution Model:** CLI-based with session persistence

```json
{
  "adapterType": "hermes_local",
  "adapterConfig": {
    "model": "anthropic/claude-sonnet-4",
    "maxIterations": 50,
    "timeoutSec": 300,
    "persistSession": true,
    "enabledToolsets": [
      "terminal",
      "file",
      "web",
      "code",
      "vision"
    ],
    "customCliPath": "/usr/local/bin/hermes",
    "contextFiles": [
      "/path/to/instructions.md"
    ],
    "gitWorktreeIsolation": true,
    "memorySize": "large"
  }
}
```

### 3. HTTP Webhook Adapter (`http`)

**Use Case:** External agent, serverless, or cloud service
**Execution Model:** Fire-and-forget HTTP request

```json
{
  "adapterType": "http",
  "adapterConfig": {
    "webhookUrl": "https://agent-service.example.com/paperclip/heartbeat",
    "method": "POST",
    "authType": "bearer",
    "authToken": "{{SECRET_REF:webhook_token}}",
    "headers": {
      "X-Agent-ID": "{{AGENT_ID}}",
      "X-Company-ID": "{{COMPANY_ID}}"
    },
    "timeout": 300,
    "retryPolicy": {
      "maxRetries": 3,
      "backoffMultiplier": 2
    }
  }
}
```

### 4. Process Adapter (`process`)

**Use Case:** Shell scripts, Python, Node.js, any CLI tool
**Execution Model:** Spawn process, capture output, track status

```json
{
  "adapterType": "process",
  "adapterConfig": {
    "command": "/usr/bin/python3",
    "args": [
      "/path/to/agent.py",
      "--agent-id={{AGENT_ID}}",
      "--company-id={{COMPANY_ID}}"
    ],
    "workingDirectory": "/home/paperclip/agents",
    "shell": "/bin/bash",
    "env": {
      "PYTHONUNBUFFERED": "1",
      "AGENT_NAME": "{{AGENT_NAME}}",
      "API_KEY": "{{SECRET_REF:api_key}}"
    },
    "timeout": 600,
    "stdoutSize": 1048576
  }
}
```

### 5. OpenClaw Gateway (`openclaw_gateway`)

**Use Case:** OpenClaw agent platform
**Execution Model:** API call to OpenClaw

```json
{
  "adapterType": "openclaw_gateway",
  "adapterConfig": {
    "gatewayUrl": "https://api.openclaw.io",
    "agentId": "openclaw-agent-uuid",
    "apiKey": "{{SECRET_REF:openclaw_api_key}}",
    "apiVersion": "v1"
  }
}
```

### 6. Codex Adapter (`codex_local`)

**Use Case:** Codex IDE integration
**Execution Model:** Codex terminal session

```json
{
  "adapterType": "codex_local",
  "adapterConfig": {
    "sessionPath": "~/.codex/sessions",
    "model": "gpt-4",
    "timeout": 300
  }
}
```

### 7. OpenCode Adapter (`opencode_local`)

**Use Case:** OpenCode agent
**Platform:** OpenCode
**Execution Model:** Local OpenCode execution

```json
{
  "adapterType": "opencode_local",
  "adapterConfig": {
    "model": "gpt-4",
    "temperature": 0.7
  }
}
```

### 8. Cursor Adapter (`cursor`)

**Use Case:** Cursor IDE integration
**Platform:** Cursor Editor
**Execution Model:** Cursor terminal session

```json
{
  "adapterType": "cursor",
  "adapterConfig": {
    "projectPath": "/path/to/project"
  }
}
```

---

## Heartbeat Scheduling

### Cron Expression Format

```
┌──────────────── minute (0 - 59)
│ ┌────────────── hour (0 - 23)
│ │ ┌──────────── day of month (1 - 31)
│ │ │ ┌────────── month (1 - 12)
│ │ │ │ ┌──────── day of week (0 - 6)
│ │ │ │ │         [0 = Sunday, 6 = Saturday]
│ │ │ │ │
* * * * *

Allowed values per field:
- * (any value)
- N (specific value)
- N-M (range)
- */N (every N units)
- N,M,P (list of values)
- N-M/P (range with step)
```

### Common Schedules

```
# Every minute
* * * * *

# Every 5 minutes
*/5 * * * *

# Every hour
0 * * * *

# Every 2 hours
0 */2 * * *

# Daily at midnight
0 0 * * *

# Daily at 9 AM
0 9 * * *

# Weekdays at 9 AM (Mon-Fri)
0 9 * * 1-5

# First day of month at 1 AM
0 1 1 * *

# Every Sunday at 6 PM
0 18 * * 0

# Every 15 minutes during business hours (9 AM - 5 PM, Mon-Fri)
*/15 9-17 * * 1-5

# Last day of month at noon
0 12 L * *

# Every 30 seconds (note: some cron implementations don't support seconds)
# May need custom interval in runtimeConfig instead
```

### Event-Based Triggers (No Cron)

Even with heartbeat schedule set, agents also wake up for:
- **Task Assignment:** When a new task is assigned to the agent
- **@-Mention:** When the agent is mentioned in conversation/task
- **Manual Trigger:** Admin triggers heartbeat through UI

---

## Database Schema (Inferred)

### Agents Table
```sql
-- Inferred structure (actual schema in source code)
CREATE TABLE agents (
  id UUID PRIMARY KEY,
  company_id UUID NOT NULL REFERENCES companies(id),
  name VARCHAR(255) NOT NULL,
  role VARCHAR(100),
  title VARCHAR(255),
  description TEXT,
  status VARCHAR(50) DEFAULT 'active',
  adapter_type VARCHAR(100) NOT NULL,
  adapter_config JSONB NOT NULL,
  runtime_config JSONB,
  monthly_token_budget INTEGER,
  reports_to UUID REFERENCES agents(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_heartbeat TIMESTAMP,
  created_by UUID
);

-- Supporting relationship table
CREATE TABLE agent_reporting (
  agent_id UUID REFERENCES agents(id),
  reports_to_id UUID REFERENCES agents(id),
  PRIMARY KEY (agent_id)
);
```

### Heartbeat Logs Table
```sql
CREATE TABLE heartbeat_logs (
  id UUID PRIMARY KEY,
  agent_id UUID REFERENCES agents(id),
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  status VARCHAR(50), -- 'running', 'completed', 'failed'
  tokens_used INTEGER,
  cost DECIMAL,
  error_message TEXT,
  output_summary TEXT
);
```

---

## API Integration Points

### Authentication
```bash
# Example: Getting auth token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"..."}'
```

### Agent Endpoints (Planned/Inferred)

```bash
# List agents
GET /api/agents?companyId=<uuid>

# Get agent details
GET /api/agents/<agent-id>

# Create agent (planned CLI)
POST /api/agents \
  -H "Content-Type: application/json" \
  -d '{
    "companyId": "<uuid>",
    "name": "CEO",
    "adapterType": "claude_local",
    "adapterConfig": {...}
  }'

# Update agent
PATCH /api/agents/<agent-id> \
  -d '{"monthlyTokenBudget": 2000000}'

# Delete agent
DELETE /api/agents/<agent-id>

# Trigger heartbeat
POST /api/agents/<agent-id>/heartbeat

# Export organization
GET /api/companies/<company-id>/export

# Import organization
POST /api/companies/import \
  -F "file=@org-backup.json"
```

---

## Environment Variables

### Core Configuration

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/paperclip

# Server
NODE_ENV=development
PORT=3000
LOG_LEVEL=info

# Security
SESSION_SECRET=long-random-string
JWT_SECRET=another-long-random-string

# API Keys (for adapters)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-...

# External Services
PAPERCLIP_URL=http://localhost:3000
```

---

## Secret Management

### Pattern: Secret References

Instead of storing secrets directly in adapter config:

```json
{
  "adapterConfig": {
    "apiKey": "{{SECRET_REF:openai_key}}",
    "dbUrl": "{{SECRET_REF:postgres_url}}"
  }
}
```

### Storage
- **Local:** Secrets encrypted and stored in local Paperclip database
- **References:** Only `{{SECRET_REF:key_name}}` persisted in agent config
- **Access:** Secrets decrypted at runtime when agent executes

### Management (Planned)
```bash
# Set/update secret
paperclip secret set --key openai_key --value sk-...

# List secrets (no values)
paperclip secret list

# Rotate secret
paperclip secret rotate --key openai_key
```

---

## Troubleshooting

### Common Issues

**Issue:** Agent not executing on schedule
```bash
# Check agent status
paperclip agent get --agent-id <uuid>

# Check heartbeat logs
curl http://localhost:3000/api/agents/<agent-id>/heartbeat-logs
```

**Issue:** Budget exceeded
```
Check:
1. Agent's monthlyTokenBudget vs currentMonthUsage
2. View usage dashboard in UI
3. Reduce budget or wait for month reset
```

**Issue:** Adapter configuration error
```
Verify:
1. adapterType matches adapter in registry
2. adapterConfig has all required fields for that type
3. Secrets are properly referenced (use {{SECRET_REF:name}})
```

---

## Performance Considerations

### Token Budgeting
- **Daily Limit:** Divide monthly budget by 30
- **Per-Heartbeat:** Budget / (monthly heartbeats)
- **Warning:** 80% utilization triggers warning
- **Hard Stop:** At 100%, agent cannot execute

### Heartbeat Duration
- **Recommended:** 5-30 minutes for complex tasks
- **Timeout:** Configurable per adapter (default 300s)
- **Parallelism:** Multiple agents can execute simultaneously

### Database Scaling
- **Local:** Embedded PostgreSQL (suitable for < 100 agents)
- **Production:** External PostgreSQL with connection pooling
- **Optimization:** Proper indexing on company_id, agent_id, status

---

## Development & Contribution

### Local Development Setup

```bash
# Clone repository
git clone https://github.com/paperclipai/paperclip
cd paperclip

# Install dependencies
pnpm install

# Create database (auto-created on first run)
pnpm prisma migrate dev

# Start development server
pnpm dev

# Watch for changes
pnpm dev --watch
```

### Project Structure

```
paperclip/
├── server/
│   └── src/
│       ├── adapters/          # Agent adapter implementations
│       ├── api/               # API endpoints
│       ├── db/                # Database models (Prisma)
│       ├── services/          # Business logic
│       └── types/             # TypeScript types
├── web/                        # React frontend
├── docs/
│   └── guides/                # Developer guides
├── AGENTS.md                   # Agent documentation
└── .agents/                    # Example agent files
```

### Adding a Custom Adapter

1. Create adapter implementation in `server/src/adapters/`
2. Register in `server/src/adapters/registry.ts`
3. Define adapter config schema
4. Implement `execute()` and `testEnvironment()` functions
5. Add documentation

See [Hermes adapter](https://github.com/NousResearch/hermes-paperclip-adapter) for complete example.

---

## Resources

| Resource | Link |
|----------|------|
| **GitHub** | https://github.com/paperclipai/paperclip |
| **Documentation** | https://paperclip.ing/ |
| **Tutorial** | https://paperclipai.info/ |
| **Hermes Adapter** | https://github.com/NousResearch/hermes-paperclip-adapter |
| **Issues** | https://github.com/paperclipai/paperclip/issues |
| **Releases** | https://github.com/paperclipai/paperclip/releases |

---

## Version History

| Version | Date | Key Changes |
|---------|------|---|
| v0.3.1 | 2026-03+ | Latest stable |
| v0.3.0 | 2026-02 | Core functionality |
| Earlier | 2025 | Initial development |

---

**Last Updated:** March 16, 2026
**Accuracy Note:** Schema and API details are inferred from documentation and GitHub sources. Exact implementation details available in [source code](https://github.com/paperclipai/paperclip).
