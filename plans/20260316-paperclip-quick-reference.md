# Paperclip Quick Reference Guide

**Date**: 2026-03-16
**Purpose**: Practical reference for configuring and using Paperclip

---

## Quick Start

```bash
# Install and run
npx paperclipai onboard --yes

# Or manual setup
git clone https://github.com/paperclipai/paperclip.git
cd paperclip && pnpm install && pnpm dev

# Access UI
http://localhost:3100
```

---

## Configuration Checklist

### 1. Define Company Mission
```
"Build [product] to achieve [goal] by [timeline]"
Example: "Build AI note-taking app to $1M MRR by end of 2025"
```

### 2. Create Org Structure
```
CEO (reports_to: null)
├─ CTO (reports_to: ceo-id)
│  ├─ Backend Lead (reports_to: cto-id)
│  │  ├─ Backend Engineer 1
│  │  └─ Backend Engineer 2
│  └─ Frontend Lead (reports_to: cto-id)
└─ COO (reports_to: ceo-id)
```

### 3. Configure Each Agent

**Minimal config**:
```yaml
agents:
  - id: backend-engineer-1
    name: "Backend Engineer 1"
    title: "Senior Backend Engineer"
    reports_to: backend-lead-id
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/path/to/project"
```

**Full config**:
```yaml
agents:
  - id: backend-engineer-1
    name: "Backend Engineer 1"
    title: "Senior Backend Engineer"
    description: "Designs and implements backend services"
    reports_to: backend-lead-id

    # Budget
    monthlyBudgetTokens: 2000000
    budgetWarningThreshold: 80

    # Adapter
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/path/to/project"
        instructionsFilePath: "./agent-instructions.md"
        timeoutSec: 300
        maxTurnsPerRun: 10

    # Scheduling
    heartbeatIntervalMinutes: 60
    eventTriggers:
      - task_assigned
      - mentioned_directly

    # Permissions
    allowedTools: [read, write, bash, grep]
    allowedFilePatterns: ["src/**", "tests/**", "docs/**"]
    requiresApprovalFor:
      - file_write_requests
      - external_api_calls
```

### 4. Define Projects & Goals
```
Project: "Authentication System"
├─ Goal 1: "Implement OAuth2 provider"
├─ Goal 2: "Add 2FA support"
└─ Goal 3: "Security audit"

Each goal gets assigned tasks → agents complete tasks
```

---

## Adapter Types Quick Selector

### Local Development
**Use**: `claude_local`, `cursor`, `opencode_local`

**When**: Running agents locally in your IDE, fast iteration

**Config**:
```yaml
adapter:
  type: claude_local
  config:
    model: "claude-3-5-sonnet"  # or claude-haiku, claude-opus
    cwd: "/project/root"
    instructionsFilePath: "./instructions.md"
    timeoutSec: 300
```

### Production / Remote
**Use**: `openclaw_remote`, `http_webhook`

**When**: Running agents in separate servers, production deployment

**Config OpenClaw**:
```yaml
adapter:
  type: openclaw_remote
  config:
    endpoint: "https://openclaw.example.com"
    apiKey: "${OPENCLAW_API_KEY}"
```

**Config Webhook**:
```yaml
adapter:
  type: http_webhook
  config:
    endpoint: "https://my-agent.example.com/run"
    apiKey: "${CUSTOM_API_KEY}"
    method: "POST"
    timeout: 300
```

### Scripts
**Use**: `bash_script`, `python_script`

**When**: Simple automation, no agent intelligence needed

**Config**:
```yaml
adapter:
  type: bash_script
  config:
    scriptPath: "/path/to/script.sh"
    workingDir: "/path/to/work"
```

---

## Heartbeat Scheduling Guide

### Rule of Thumb
- **Frequent execution** (dev/execution roles): 15-60 minutes
- **Regular execution** (planning/review roles): 60-240 minutes
- **Rare execution** (executive roles): 240+ minutes

### Examples

```yaml
# Development agent - checks frequently
agents:
  - id: backend-dev
    heartbeatIntervalMinutes: 30

# Writing/content agent - works in batches
agents:
  - id: content-writer
    heartbeatIntervalMinutes: 120

# CEO - rare high-level decisions
agents:
  - id: ceo
    heartbeatIntervalMinutes: 480  # 8 hours
```

### Event-Based Wakeup
Even with long heartbeat intervals, agents wake immediately on:
- Task assignment
- Direct mention (@agent-name)
- Escalation from subordinate
- Custom webhook triggers

---

## Budget Allocation Patterns

### Token Budget by Role

| Role | Monthly Budget | Reasoning |
|---|---|---|
| Entry-level task | 100K - 500K | Simple, defined work |
| Mid-level engineer | 500K - 2M | Complex implementation |
| Senior engineer | 2M - 5M | Architectural decisions |
| CTO/CEO | 5M - 10M+ | Strategic, high-stakes |
| Writing/content | 500K - 2M | Batch processing |

### Budget Structure

```yaml
agents:
  # Low-cost role
  - id: task-processor
    monthlyBudgetTokens: 500000
    budgetWarningThreshold: 80

  # High-cost role
  - id: senior-engineer
    monthlyBudgetTokens: 5000000
    budgetWarningThreshold: 75  # Earlier warning
```

---

## Common Configuration Mistakes

### ❌ Flat Hierarchy (All report to CEO)
```yaml
# BAD: Bottleneck at CEO
- id: agent-1
  reports_to: ceo-id
- id: agent-2
  reports_to: ceo-id
- id: agent-3
  reports_to: ceo-id
```

✅ **Fix**: Create intermediate managers (CTO, COO, Leads)

### ❌ Too Long Heartbeat
```yaml
# BAD: Agent only checks every 24 hours
heartbeatIntervalMinutes: 1440
```

✅ **Fix**: Use 30-120 minutes; rely on event triggers for urgent work

### ❌ No Budget Limits
```yaml
# BAD: No safeguard against runaway costs
# (don't set monthlyBudgetTokens)
```

✅ **Fix**: Always set reasonable monthly budgets per agent role

### ❌ Too Permissive File Access
```yaml
# BAD: Can write anywhere
allowedFilePatterns: ["**/*"]
requiresApprovalFor: []  # No approval needed
```

✅ **Fix**: Restrict to project directories; require approval for writes

### ❌ Mission Statements Too Vague
```yaml
# BAD
mission: "Build great software"

# GOOD
mission: "Build AI-powered note-taking app with 10K DAU, $1M MRR, <100ms response time"
```

---

## File Structure in .paperclip/

After initialization, you'll have:

```
.paperclip/
├── instances/
│   └── default/
│       ├── secrets/
│       │   └── master.key  (local encryption key)
│       └── db/
│           └── paperclip.db  (embedded Postgres)
└── config.json  (basic config)
```

**Note**: Configuration typically done via web UI, not YAML files directly.

---

## CLI Commands Reference

### Agent Management
```bash
paperclip agent list           # List all agents
paperclip agent get <id>       # Get agent details
paperclip agent local-cli      # Run local CLI agent
```

### Diagnostics
```bash
paperclip doctor               # Validate config
```

### Development
```bash
pnpm dev                       # Start dev server
pnpm build                     # Build for production
npm start                      # Run production build
```

---

## Integration Points

### Web UI (Recommended)
- Configure agents, projects, goals
- Monitor task execution
- Track costs and budgets
- View audit trails

### API
- Programmatic agent creation/updates
- Task management
- Custom dashboards

### CLI
- Agent listing and inspection
- Doctor/validation commands
- Local agent execution

### Webhooks (Adapters)
- Connect custom agent runtimes
- Event-driven execution
- Custom tool integrations

---

## Troubleshooting

### Agent Not Executing Tasks
**Check**:
1. Budget not exceeded (`monthlyBudgetTokens`)
2. Heartbeat interval hasn't passed
3. Task assigned correctly
4. Agent has required tools/permissions

### High Token Consumption
**Check**:
1. `maxTurnsPerRun` not too high (default 10)
2. Agent instructions too verbose
3. Tools/file access inefficient
4. Consider `claude-haiku` for routine tasks

### File Write Permissions
**Note**: Agents need explicit approval by default
- Request approval for file writes
- Admin must approve in UI
- Consider adjusting `requiresApprovalFor` policy

### Session Context Lost
**Note**: Paperclip maintains persistent context across heartbeats
- Check agent's session status in UI
- Verify task wasn't reassigned
- Check task context/goal ancestry

---

## Advanced Topics

### Custom Adapter Development

Pattern:
```
Paperclip sends: { taskId, context, agentId }
         ↓
    Adapter executes agent in its runtime
         ↓
      Agent processes task
         ↓
    Adapter captures: { output, tokens, errors }
         ↓
  Adapter POSTs results to Paperclip API
```

Reference: [Hermes Paperclip Adapter](https://github.com/NousResearch/hermes-paperclip-adapter)

### Multi-Company Deployment

Single Paperclip instance can serve multiple organizations:
- Each company has isolated org charts
- Separate budgets per company
- Shared underlying infrastructure

### Approval Workflow

Operations requiring approval:
- Agent hiring/firing
- Strategy changes (CEO level)
- High-cost operations
- Sensitive file modifications
- External API calls

---

## Resources

- **GitHub**: [paperclipai/paperclip](https://github.com/paperclipai/paperclip)
- **Docs**: [docs/guides/agent-developer](https://github.com/paperclipai/paperclip/tree/master/docs/guides/agent-developer)
- **Tutorial**: [paperclipai.info](https://paperclipai.info/)
- **Concepts**: `/docs/start/core-concepts.md` in repo

---

**Last Updated**: 2026-03-16
